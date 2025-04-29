import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/widgets/common_widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupExpenseName extends StatefulWidget {
  const GroupExpenseName({super.key});

  @override
  State<GroupExpenseName> createState() => _GroupExpenseNameState();
}

class _GroupExpenseNameState extends State<GroupExpenseName> {
  String _groupName = '';
  final _form = GlobalKey<FormState>();
  bool _isAdding = false;

  void _saveGroupExpenseName() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      try {
        final loggedUser = FirebaseAuth.instance.currentUser;
        setState(() {
          _isAdding = true;
        });
        await FirebaseFirestore.instance.collection('groups').add({
          'groupName': _groupName,
          'admin': loggedUser!.uid,
          'members': [loggedUser.uid],
          'createdAt': Timestamp.now(),
        });
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
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 30),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create New Expense Group',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  InputField(
                    text: 'Group Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Groupname mustn\'t be empty';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _groupName = value!;
                    },
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Color(0xFFEB50A8).withAlpha(220),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: _saveGroupExpenseName,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        // backgroundColor: Color(0xFFEB50A8).withAlpha(220),
                      ),
                      child:
                          _isAdding
                              ? CircularProgressIndicator()
                              : Text(
                                'Add',
                                style: TextStyle(color: Colors.black),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
