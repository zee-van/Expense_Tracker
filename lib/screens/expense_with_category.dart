import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/providers/categries_colors_icons.dart';
import 'package:expense_tracker/screens/expense_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ExpenseWithCategoryScreen extends ConsumerStatefulWidget {
  const ExpenseWithCategoryScreen({super.key, required this.category});
  final String category;

  @override
  ConsumerState<ExpenseWithCategoryScreen> createState() =>
      _ExpenseWithCategoryScreenState();
}

class _ExpenseWithCategoryScreenState
    extends ConsumerState<ExpenseWithCategoryScreen> {
  final loggedUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final categoryServices = ref.watch(categoryServiceProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance
                  .collection('personalExpenses')
                  .where('category', isEqualTo: widget.category)
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
              return Center(child: Text('No expenses added'));
            }

            int totalExpenses = 0;

            for (final expense in myExpenses) {
              int amount = expense.data()['amount'];
              totalExpenses += amount;
            }
            return ListView(
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          Text(
                            'Total Expenses\n Rs.$totalExpenses',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                for (final myExpense in myExpenses)
                  ListTile(
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
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs.${myExpense.data()['amount']}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(color: Colors.red),
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd').format(
                            ((myExpense.data()['date']) as Timestamp).toDate(),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
