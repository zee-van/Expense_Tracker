import 'package:expense_tracker/widgets/common_widgets/button.dart';
import 'package:expense_tracker/widgets/common_widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/model/group_expense_name.dart';
import 'package:expense_tracker/providers/group_expense_name_provider.dart';

class GroupExpenseName extends ConsumerStatefulWidget {
  const GroupExpenseName({super.key});

  @override
  ConsumerState<GroupExpenseName> createState() => _GroupExpenseNameState();
}

class _GroupExpenseNameState extends ConsumerState<GroupExpenseName> {
  String _groupName = '';
  final _form = GlobalKey<FormState>();
  bool _isAdding = false;

  void _saveGroupExpenseName() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      try {
        final loggedUser = FirebaseAuth.instance.currentUser;
        final groupExpenseName = GroupExpenseNameData(
          admin: loggedUser!.uid,
          createdAt: DateTime.now(),
          groupName: _groupName,
          members: [loggedUser.uid],
        );
        setState(() {
          _isAdding = true;
        });
        await ref
            .watch(addGroupExpenseNameProvider.notifier)
            .addGroupExpenseName(groupExpenseName);

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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
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
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 20,
                top: 30,
              ),
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
                    ElevatedButtonWidget(
                      onTap: _saveGroupExpenseName,
                      label:
                          _isAdding ? CircularProgressIndicator() : Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
