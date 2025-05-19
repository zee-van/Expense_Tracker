import 'package:expense_tracker/data/categories.dart';
import 'package:expense_tracker/model/category.dart';
import 'package:expense_tracker/model/expense_data.dart';
import 'package:expense_tracker/providers/add_personal_expense_provider.dart';
import 'package:expense_tracker/widgets/common_widgets/button.dart';
import 'package:expense_tracker/widgets/common_widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddNewPersoanlExpense extends ConsumerStatefulWidget {
  const AddNewPersoanlExpense({super.key});

  @override
  ConsumerState<AddNewPersoanlExpense> createState() =>
      _AddNewPersoanlExpenseState();
}

class _AddNewPersoanlExpenseState extends ConsumerState<AddNewPersoanlExpense> {
  ExpenseCategory? _selectedCategory;
  final loggedUser = FirebaseAuth.instance.currentUser;

  String _enteredTitle = '';
  String _amount = '';
  String _description = '';
  final _form = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  bool _isAdding = false;

  void _datePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: now,
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _addPersonalExpense() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      try {
        final personalExpense = PersonalExpenseData(
          amount: int.parse(_amount),
          category: _selectedCategory!.name,
          date: _selectedDate,
          description: _description,
          title: _enteredTitle,
          userId: loggedUser!.uid,
        );
        setState(() {
          _isAdding = true;
        });
        await ref
            .watch(addPersonalExpenseProvider.notifier)
            .addPersonalExpense(personalExpense);

        setState(() {
          _isAdding = false;
          Navigator.of(context).pop();
        });
      } catch (e) {
        setState(() {});
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add Your Expense',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'Track your spending and stay on budget!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              InputField(
                text: 'Expense Title',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Provide the meaningful name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredTitle = value!;
                },
              ),
              SizedBox(height: 10),
              InputField(
                text: 'Amount',
                validator: (value) {
                  if (value == null || value.isEmpty || value.contains('-')) {
                    return 'Provide the valid amount';
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return 'Provide a valid positive number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = value!;
                },
              ),
              SizedBox(height: 10),
              InputField(
                text: 'Description(optional)',
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton(
                    value: _selectedCategory,
                    hint: Text('Select Item'),
                    items:
                        expenseCategories.map((ExpenseCategory category) {
                          return DropdownMenuItem<ExpenseCategory>(
                            value: category,
                            child: Row(
                              children: [
                                Icon(category.icon, color: category.color),
                                SizedBox(width: 8),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      IconButton(
                        onPressed: _datePicker,
                        icon: Icon(Icons.calendar_month),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40),
              ElevatedButtonWidget(
                onTap: _addPersonalExpense,
                label:
                    _isAdding
                        ? CircularProgressIndicator()
                        : Text('Add Expense', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
