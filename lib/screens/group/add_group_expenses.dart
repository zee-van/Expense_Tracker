import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/providers/categries_colors_icons.dart';
import 'package:expense_tracker/screens/category_bar_chart.dart';
import 'package:expense_tracker/screens/expense_details.dart';
import 'package:expense_tracker/screens/monthly_expenses_filter.dart';
import 'package:expense_tracker/screens/group/add_new_group_expense.dart';
import 'package:expense_tracker/screens/update_expense.dart';
import 'package:expense_tracker/widgets/common_widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddGroupExpensesScreen extends ConsumerStatefulWidget {
  const AddGroupExpensesScreen({super.key, required this.groupDetails});
  final QueryDocumentSnapshot<Map<String, dynamic>> groupDetails;

  @override
  ConsumerState<AddGroupExpensesScreen> createState() =>
      _AddGroupExpensesScreenState();
}

class _AddGroupExpensesScreenState
    extends ConsumerState<AddGroupExpensesScreen> {
  final loggedUser = FirebaseAuth.instance.currentUser;

  bool _isChart = true;
  void _showModelForAddGroupExpense() {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return AddNewGroupExpense(groupId: widget.groupDetails.id);
      },
    );
  }

  void _showUpdateDeleteExpense(
    QueryDocumentSnapshot<Map<String, dynamic>> expense,
  ) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      expense.data()['title'],
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 30),
                    ElevatedButtonWidget(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showUpdateExpenseDialog(expense.id);
                      },
                      label: Row(
                        children: [
                          SizedBox(width: 20),
                          Icon(Icons.update, color: Colors.white, size: 25),
                          SizedBox(width: 10),
                          Text('Update', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                    ElevatedButtonWidget(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showConfirmDeleteDialog(expense.id);
                      },
                      label: Row(
                        children: [
                          SizedBox(width: 20),
                          Icon(Icons.delete, color: Colors.white, size: 25),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmDeleteDialog(String id) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Conform Dialog'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure want to delete this expense'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButtonWidget(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      label: Text('Cancel'),
                    ),
                    SizedBox(width: 10),
                    OutlinedButtonWidget(
                      onTap: () {
                        _deleteExpense(id);
                        Navigator.of(context).pop();
                      },
                      label: Text('Conform'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Conform Dialog'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure want to delete this expense'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButtonWidget(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      label: Text('Cancel'),
                    ),
                    SizedBox(width: 10),
                    OutlinedButtonWidget(
                      onTap: () {
                        _deleteExpense(id);
                        Navigator.of(context).pop();
                      },
                      label: Text('Conform'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _showUpdateExpenseDialog(String id) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return UpdateExpense(expenseId: id);
      },
    );
  }

  Future<String> getUserName(String id) async {
    String name = '';
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      name = userDoc.data()!['name'];
      return name;
    } catch (e) {
      setState(() {});
    }
    return name;
  }

  void _deleteExpense(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('groupExpenses')
          .doc(id)
          .delete();
    } catch (e) {
      setState(() {});
    }
  }

  Future<String> _getUserFirstNameCharacter(String userId) async {
    String charName = '';
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      charName = userDoc.data()!['name'][0];
    } catch (e) {
      setState(() {});
    }
    return charName;
  }

  @override
  Widget build(BuildContext context) {
    final categoryServices = ref.watch(categoryServiceProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupDetails['groupName'])),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('groupExpenses')
                .where('groupId', isEqualTo: widget.groupDetails.id)
                .snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshots.hasError) {
            return Center(child: Text('Someting went wrong'));
          }
          final myExpenses = snapshots.data!.docs;
          if (myExpenses.isEmpty) {
            return Center(child: Text('No expenses added'));
          }
          int totalExpenses = 0;
          for (final expense in myExpenses) {
            int amount = expense.data()['amount'];
            totalExpenses += amount;
          }

          final Map<String, int> userExpenses = {};

          for (final doc in myExpenses) {
            final data = doc.data();
            final String addedBy = data['userId'];
            final int amount = data['amount'];

            if (userExpenses.containsKey(addedBy)) {
              userExpenses[addedBy] = userExpenses[addedBy]! + amount;
            } else {
              userExpenses[addedBy] = amount;
            }
          }
          return ListView(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(60),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,

                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Expenses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade900,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Rs. $totalExpenses',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color:
                                _isChart
                                    ? Color(0xFFEB50A8).withAlpha(220)
                                    : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isChart = !_isChart;
                              });
                            },
                            child: Text('Chart'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color:
                                !_isChart
                                    ? Color(0xFFEB50A8).withAlpha(220)
                                    : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (ctx) => MonthlyExpensesFilter(
                                          id: widget.groupDetails.id,
                                          identifier: 'GROUP',
                                        ),
                                  ),
                                );
                              });
                            },
                            child: Text('Filter'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          userExpenses.entries.map((entry) {
                            final userId = entry.key;
                            final total = entry.value;
                            return FutureBuilder<String>(
                              future: getUserName(userId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text('Loading user...');
                                } else if (snapshot.hasError) {
                                  return Text('Error loading user');
                                } else {
                                  final name = snapshot.data ?? 'Unknown';
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                      horizontal: 6,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '$name\'s Expense',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          'Rs. $total',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('groupExpenses')
                              .where(
                                'groupId',
                                isEqualTo: widget.groupDetails.id,
                              )
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          );
                        }
                        final List<QueryDocumentSnapshot> docs =
                            snapshot.data!.docs;

                        Map<String, double> categoryTotals = {};

                        for (var doc in docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final category = data['category'] as String;
                          final amount = (data['amount'] as num).toDouble();

                          if (categoryTotals.containsKey(category)) {
                            categoryTotals[category] =
                                categoryTotals[category]! + amount;
                          } else {
                            categoryTotals[category] = amount;
                          }
                        }
                        return Container(
                          margin: EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(30),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          height: 200,
                          child: CategoryBarChart(data: categoryTotals),
                        );
                      },
                    ),
                  ],
                ),
              ),

              for (final myExpense in myExpenses)
                Container(
                  margin: EdgeInsets.only(top: 4, left: 4, right: 4),
                  decoration: BoxDecoration(
                    gradient:
                        myExpense.data()['userId'] != loggedUser!.uid
                            ? LinearGradient(
                              colors: [
                                Colors.red.withAlpha(20),
                                Colors.red.withAlpha(80),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : LinearGradient(
                              colors: [
                                Color(0xFFEB50A8).withAlpha(80),
                                Color(0xFFEB50A8).withAlpha(20),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (ctx) =>
                                  ExpenseDetails(expenseDetails: myExpense),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      child: Icon(
                        categoryServices.getCategoryIcon(
                          myExpense.data()['category'],
                        ),
                        color: categoryServices.getCategoryColor(
                          myExpense.data()['category'],
                        ),
                      ),
                    ),
                    title: Text(myExpense.data()['title']),
                    subtitle: Text(
                      myExpense.data()['description'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Rs.${myExpense.data()['amount']}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd').format(
                                ((myExpense.data()['date']) as Timestamp)
                                    .toDate(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 5),
                        myExpense.data()['userId'] != loggedUser!.uid
                            ? CircleAvatar(
                              child: FutureBuilder<String>(
                                future: _getUserFirstNameCharacter(
                                  myExpense.data()['userId'],
                                ),
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<String> snapshot,
                                ) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error');
                                  } else if (snapshot.hasData) {
                                    return Text(snapshot.data![0]);
                                  } else {
                                    return Text('');
                                  }
                                },
                              ),
                            )
                            : CircleAvatar(
                              // backgroundColor: Color(0xFFEB50A8),
                              child: IconButton(
                                onPressed: () {
                                  _showUpdateDeleteExpense(myExpense);
                                },
                                icon: Icon(Icons.more_vert),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 70),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFEB50A8),
        onPressed: () {
          _showModelForAddGroupExpense();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
