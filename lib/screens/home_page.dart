import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/providers/categries_colors_icons.dart';
import 'package:expense_tracker/screens/category_bar_chart.dart';
import 'package:expense_tracker/screens/category_page.dart';
import 'package:expense_tracker/screens/expense_details.dart';
import 'package:expense_tracker/screens/group/group_expense_list.dart';
import 'package:expense_tracker/screens/group/group_expense_name.dart';
import 'package:expense_tracker/screens/monthly_expenses_filter.dart';
import 'package:expense_tracker/screens/personal/add_new_persoanl_expense.dart';
import 'package:expense_tracker/screens/personal/profile_page.dart';
import 'package:expense_tracker/widgets/login_register.dart';
import 'package:expense_tracker/widgets/common_widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomePageScreen extends ConsumerStatefulWidget {
  const HomePageScreen({super.key});

  @override
  ConsumerState<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends ConsumerState<HomePageScreen> {
  int _currentIndex = 0;
  User? loggedUser = FirebaseAuth.instance.currentUser;
  String? _username = '';
  bool _isChart = true;
  String? _selectedMonth;
  List<String> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  void _updateCurrentUser(dynamic user) {
    setState(() {
      loggedUser = user;
      _fetchCurrentUser();
    });
  }

  void _fetchCurrentUser() async {
    try {
      if (loggedUser != null) {
        final user =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(loggedUser!.uid)
                .get();
        setState(() {
          _username = user.data()!['name'];
        });
      }
    } catch (e) {
      setState(() {
        loggedUser = null;
      });
    }
  }

  void _loginDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: LoginRegister(onLoginSucces: _updateCurrentUser),
        );
      },
    );
  }

  void _logoutDialog() {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text('Conform Logout'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure want to logout!'),
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
                        _conformLogout();
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text('Conform Logout'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure want to logout!'),
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
                        _conformLogout();
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

  void _conformLogout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      loggedUser = null;
    });
  }

  void _showModelForAddExpense(String identifier) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        if (identifier == 'EXPENSE') {
          return AddNewPersoanlExpense();
        }
        if (identifier == 'GROUP_NAME') {
          return GroupExpenseName();
        }
        return AddNewPersoanlExpense();
      },
    );
  }

  void extractMonths(List<QueryDocumentSnapshot> expenses) {
    final uniqueMonths = <String>{};

    for (final expense in expenses) {
      final timestamp = expense['date'] as Timestamp;
      final date = timestamp.toDate();
      final formattedMonth = DateFormat('MMMM yyyy').format(date);
      uniqueMonths.add(formattedMonth);
    }

    setState(() {
      _availableMonths = uniqueMonths.toList()..sort((a, b) => b.compareTo(a));
      _selectedMonth ??=
          _availableMonths.isNotEmpty ? _availableMonths.first : null;
    });
  }

  List<QueryDocumentSnapshot> filterExpensesByMonth(
    List<QueryDocumentSnapshot> expenses,
  ) {
    if (_selectedMonth == null) return expenses;

    return expenses.where((expense) {
      final date = (expense['date'] as Timestamp).toDate();
      final monthYear = DateFormat('MMMM yyyy').format(date);
      return monthYear == _selectedMonth;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoryServices = ref.watch(categoryServiceProvider);
    Widget content = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Container(
          alignment: Alignment.center,
          width: 350,
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary,
                blurRadius: 2,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Our App!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Sign in to access personalized features and sync your data securely.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButtonWidget(
                label: Text(
                  'Get Started',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onTap: _loginDialog,
              ),
            ],
          ),
        ),
      ),
    );
    if (loggedUser != null) {
      content = StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('personalExpenses')
                .where('userId', isEqualTo: loggedUser!.uid)
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
            return Center(
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary,
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Add Your Expense Here!',
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'You haven\'t add your personal expense yet!!!.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    ElevatedButtonWidget(
                      onTap: () {
                        _showModelForAddExpense('EXPENSE');
                      },
                      label: Text('Add New Personal Expense'),
                    ),
                  ],
                ),
              ),
            );
          }

          int totalExpenses = 0;

          for (final expense in myExpenses) {
            int amount = expense.data()['amount'];

            totalExpenses += amount;
          }

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(30),
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
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Text(
                            'Rs. $totalExpenses',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineLarge!.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: _isChart ? Color(0xFFEB50A8) : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isChart = !_isChart;
                              });
                            },
                            child: Text(
                              'Chart',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: !_isChart ? Color(0xFFEB50A8) : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButtonWidget(
                            onTap: () {
                              setState(() {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (ctx) => MonthlyExpensesFilter(
                                          id: loggedUser!.uid,
                                        ),
                                  ),
                                );
                              });
                            },
                            label: Text(
                              'Filter',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _isChart
                        ? StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('personalExpenses')
                                  .where('userId', isEqualTo: loggedUser!.uid)
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
                            return Column(
                              children: [
                                Container(
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
                                ),
                              ],
                            );
                          },
                        )
                        : Text('Filter'),
                  ],
                ),
              ),
              for (final myExpense in myExpenses)
                Container(
                  margin: EdgeInsets.only(top: 4, left: 4, right: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withAlpha(30),
                        Theme.of(context).colorScheme.primary.withAlpha(40),
                        Theme.of(context).colorScheme.primary.withAlpha(50),
                      ],
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (ctx) => ExpenseDetails(
                                expenseDetails: myExpense,
                                // identifier: 'PERSONAL',
                                // expenseId: myExpense.id,
                              ),
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
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            ((myExpense.data()['date']) as Timestamp).toDate(),
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
      );
    }
    if (loggedUser != null && _currentIndex == 2) {
      content = GroupExpenseListScreen();
    }
    if (loggedUser != null && _currentIndex == 1) {
      content = CategoryPageScreen();
    }
    if (loggedUser != null && _currentIndex == 3) {
      content = ProfilePageScreen();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEB50A8),
        title: Text('Expense Tracker'),
        actions: [
          loggedUser != null
              ? TextButtonWidget(
                onTap: () {
                  _logoutDialog();
                },
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 25),
                    SizedBox(width: 5),
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
              : TextButtonWidget(
                onTap: () {
                  _loginDialog();
                },
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 25),
                    SizedBox(width: 5),
                    Text(
                      'Login',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
      body: content,
      floatingActionButton:
          loggedUser != null
              ? FloatingActionButton(
                backgroundColor: Color(0xFFEB50A8),
                onPressed: () {
                  if (_currentIndex == 2) {
                    _showModelForAddExpense('GROUP_NAME');
                    return;
                  }
                  _showModelForAddExpense('EXPENSE');
                },
                child: Icon(Icons.add),
              )
              : null,
      bottomNavigationBar:
          loggedUser != null
              ? BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                showUnselectedLabels: true,
                selectedItemColor: Color.fromARGB(255, 255, 0, 144),

                onTap: (value) {
                  setState(() {
                    _currentIndex = value;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'My Expenses',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.category),
                    label: 'Categories',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.group),
                    label: 'Group Expenses',
                  ),
                  loggedUser != null
                      ? BottomNavigationBarItem(
                        icon: CircleAvatar(
                          child:
                              _username != ''
                                  ? Text(
                                    _username![0].toUpperCase(),
                                    style:
                                        _currentIndex == 3
                                            ? TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                255,
                                                0,
                                                144,
                                              ),
                                              fontSize: 20,
                                            )
                                            : null,
                                  )
                                  : CircularProgressIndicator(),
                        ),
                        label: 'You',
                      )
                      : BottomNavigationBarItem(
                        icon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                ],
              )
              : null,
    );
  }
}
