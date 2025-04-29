import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/data/categories.dart';
import 'package:expense_tracker/model/category.dart';
import 'package:expense_tracker/widgets/common_widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateExpense extends StatefulWidget {
  const UpdateExpense({super.key, required this.expenseId, this.identifier});
  final String expenseId;
  final String? identifier;

  @override
  State<UpdateExpense> createState() => _UpdateExpenseState();
}

class _UpdateExpenseState extends State<UpdateExpense> {
  ExpenseCategory? _selectedCategory;
  String _enteredTitle = '';
  String _amount = '';
  String _description = '';
  final _form = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _fetchExpenseDetails();
  }

  Future<void> _fetchExpenseDetails() async {
    try {
      if (widget.identifier == 'PERSONAL') {
        final expenseDoc =
            await FirebaseFirestore.instance
                .collection('personalExpenses')
                .doc(widget.expenseId)
                .get();
        String categoryName = expenseDoc.data()!['category'];

        final matchedCategory = expenseCategories.firstWhere(
          (cat) => cat.name == categoryName,
          orElse: () => expenseCategories.first,
        );

        final Timestamp firebaseTimestamp = expenseDoc.data()!['date'];
        final DateTime fetchedDate = firebaseTimestamp.toDate();

        setState(() {
          _enteredTitle = expenseDoc.data()!['title'];
          _amount = '${expenseDoc.data()!['amount']}';
          _description = expenseDoc.data()!['description'];
          _selectedCategory = matchedCategory;
          _selectedDate = fetchedDate;
        });
      } else {
        final expenseDoc =
            await FirebaseFirestore.instance
                .collection('groupExpenses')
                .doc(widget.expenseId)
                .get();
        String categoryName = expenseDoc.data()!['category'];

        final matchedCategory = expenseCategories.firstWhere(
          (cat) => cat.name == categoryName,
          orElse: () => expenseCategories.first,
        );

        final Timestamp firebaseTimestamp = expenseDoc.data()!['date'];
        final DateTime fetchedDate = firebaseTimestamp.toDate();

        setState(() {
          _enteredTitle = expenseDoc.data()!['title'];
          _amount = '${expenseDoc.data()!['amount']}';
          _description = expenseDoc.data()!['description'];
          _selectedCategory = matchedCategory;
          _selectedDate = fetchedDate;
        });
      }
    } catch (e) {
      setState(() {});
    }
  }

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

  void _updateExpense() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      try {
        _form.currentState!.save();
        if (widget.identifier == 'PERSONAL') {
          setState(() {
            _isAdding = true;
          });
          final expenseDocToUpdate = FirebaseFirestore.instance
              .collection('personalExpenses')
              .doc(widget.expenseId);
          await expenseDocToUpdate.update({
            'title': _enteredTitle,
            'category': _selectedCategory?.name,
            'description': _description,
            'amount': int.tryParse(_amount),
            'date': Timestamp.fromDate(_selectedDate),
          });
          setState(() {
            _isAdding = false;
            Navigator.of(context).pop();
          });
        } else {
          setState(() {
            _isAdding = true;
          });
          final expenseDocToUpdate = FirebaseFirestore.instance
              .collection('groupExpenses')
              .doc(widget.expenseId);
          await expenseDocToUpdate.update({
            'title': _enteredTitle,
            'category': _selectedCategory?.name,
            'description': _description,
            'amount': int.tryParse(_amount),
            'date': Timestamp.fromDate(_selectedDate),
          });
          setState(() {
            _isAdding = false;
            Navigator.of(context).pop();
          });
        }
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
                      'Update Your Expense',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'Track your expense spending and stay on budget!',
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
                controller: TextEditingController(text: _enteredTitle),
                onSaved: (value) {
                  _enteredTitle = value!;
                },
              ),
              SizedBox(height: 10),
              InputField(
                text: 'Amount',
                keyboardType: TextInputType.number,
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
                controller: TextEditingController(text: _amount),
                onSaved: (value) {
                  _amount = value!;
                },
              ),
              SizedBox(height: 10),
              InputField(
                text: 'Description(optional)',
                controller: TextEditingController(text: _description),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _selectedCategory == null
                      ? CircularProgressIndicator()
                      : DropdownButton(
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
                  onPressed: _updateExpense,
                  style: TextButton.styleFrom(),
                  child:
                      _isAdding
                          ? CircularProgressIndicator()
                          : Text(
                            'Update Expense',
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
