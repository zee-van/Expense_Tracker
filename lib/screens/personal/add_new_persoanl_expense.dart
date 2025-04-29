import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/data/categories.dart';
import 'package:expense_tracker/model/category.dart';
import 'package:expense_tracker/widgets/common_widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddNewPersoanlExpense extends StatefulWidget {
  const AddNewPersoanlExpense({
    super.key,
    required this.identifier,
    this.groupId,
  });
  final String identifier;
  final String? groupId;

  @override
  State<AddNewPersoanlExpense> createState() => _AddNewPersoanlExpenseState();
}

class _AddNewPersoanlExpenseState extends State<AddNewPersoanlExpense> {
  ExpenseCategory? _selectedCategory;
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

  Future<void> _saveExpense() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      try {
        setState(() {
          _isAdding = true;
        });
        final loggedUser = FirebaseAuth.instance.currentUser;
        if (widget.identifier == 'PERSONAL') {
          await FirebaseFirestore.instance.collection('personalExpenses').add({
            'userId': loggedUser!.uid,
            'title': _enteredTitle,
            'amount': int.tryParse(_amount),
            'description': _description,
            'category': _selectedCategory!.name,
            'date': _selectedDate,
          });
        }
        if (widget.identifier == 'GROUP') {
          await FirebaseFirestore.instance.collection('groupExpenses').add({
            'groupId': widget.groupId,
            'title': _enteredTitle,
            'amount': int.tryParse(_amount),
            'description': _description,
            'category': _selectedCategory!.name,
            'userId': loggedUser!.uid,
            'date': _selectedDate,
          });
        }

        setState(() {
          _isAdding = false;
          Navigator.of(context).pop();
        });
      } catch (e) {
        setState(() {
          _isAdding = false;
          Navigator.of(context).pop();
        });
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
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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
              Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Color(0xFFEB50A8).withAlpha(220),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: _saveExpense,
                  style: TextButton.styleFrom(
                    // padding: EdgeInsets.symmetric(vertical: ),
                    // backgroundColor: Color(0xFFEB50A8).withAlpha(220),
                  ),
                  child:
                      _isAdding
                          ? CircularProgressIndicator()
                          : Text(
                            'Add Expense',
                            style: TextStyle(color: Colors.black),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
