import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/providers/categries_colors_icons.dart';
// import 'package:expense_tracker/providers/fetch_expense_details_provider.dart';
import 'package:expense_tracker/screens/update_expense.dart';
import 'package:expense_tracker/widgets/common_widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ExpenseDetails extends ConsumerStatefulWidget {
  const ExpenseDetails({
    super.key,
    required this.expenseDetails,
    // this.identifier,
    // this.expenseId,
  });
  final QueryDocumentSnapshot<Map<String, dynamic>> expenseDetails;
  // final String? identifier;
  // final String? expenseId;

  @override
  ConsumerState<ExpenseDetails> createState() => _ExpenseDetailsState();
}

class _ExpenseDetailsState extends ConsumerState<ExpenseDetails> {
  final loggedUser = FirebaseAuth.instance.currentUser;
  Future<String> _getAddedBy(String id) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    return userDoc.data()!['name'];
  }

  @override
  void initState() {
    super.initState();
    // _fetchExpenseDetail();
  }

  // Future<void> _fetchExpenseDetail() async {
  //   try {
  //     print('fetching...');

  //     final data = await ref
  //         .read(fetchExpenseDetailsProvider.notifier)
  //         .fetchExpenseDetails(widget.identifier!, widget.expenseId!);
  //     print(data.data()!['title']);
  //   } catch (e) {
  //     setState(() {});
  //   }
  // }

  void _showConfirmDeleteDialog(String id) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Confirm Dialog'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure want to delete this expense'),
                SizedBox(height: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _deleteExpense(id);
                        Navigator.of(context).pop();
                      },
                      child: Text('Conform'),
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
            title: Text('Confirm Dialog'),
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

  void _deleteExpense(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('personalExpenses')
          .doc(id)
          .delete();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {});
    }
  }

  void _showUpdateExpenseDialog(String id) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return UpdateExpense(expenseId: id, identifier: 'PERSONAL');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryServices = ref.watch(categoryServiceProvider);
    final data = widget.expenseDetails.data();

    final title = data['title'] ?? '';
    final amount = data['amount'] ?? 0;
    final description = data['description'] ?? '';
    final category = data['category'] ?? 'Uncategorized';
    final rawDate = data['date'] as Timestamp?;
    final formattedDate =
        rawDate != null
            ? DateFormat('MMMM d, yyyy').format(rawDate.toDate())
            : 'Unknown Date';

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary,
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'Rs. $amount',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (description.isNotEmpty)
                Text(description, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        categoryServices.getCategoryIcon(category),
                        color: categoryServices.getCategoryColor(category),
                        size: 25,
                      ),
                      SizedBox(width: 10),
                      Text(category),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 25),
                      SizedBox(width: 10),
                      FutureBuilder<Object>(
                        future: _getAddedBy(data['userId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Loading added by...');
                          } else if (snapshot.hasError) {
                            return const Text('Error loading user');
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return const Text('Unknown user');
                          }

                          final userName = snapshot.data!;
                          return Text(
                            'Added by: $userName',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              if (data['userId'] == loggedUser!.uid && data['groupId'] == null)
                Column(
                  children: [
                    ElevatedButtonWidget(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showUpdateExpenseDialog(widget.expenseDetails.id);
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
                        _showConfirmDeleteDialog(widget.expenseDetails.id);
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
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
