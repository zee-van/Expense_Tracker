import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/widgets/common_widgets/input_field.dart';
import 'package:flutter/material.dart';

class AddMemberToGroup extends StatefulWidget {
  const AddMemberToGroup({super.key, required this.groupId});
  final String groupId;

  @override
  State<AddMemberToGroup> createState() => _AddMemberToGroupState();
}

class _AddMemberToGroupState extends State<AddMemberToGroup> {
  bool _isAdding = false;
  final _form = GlobalKey<FormState>();
  String _emailName = '';
  String _showMessage = '';

  void _addMemberToGroup() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      try {
        setState(() {
          _isAdding = true;
        });
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: _emailName)
                .get();
        if (userDoc.docs.isEmpty) {
          setState(() {
            _showMessage = 'Email not found';
            _isAdding = false;
          });
        } else {
          final userIdToAdd = userDoc.docs.first.id;
          final groupToUpdate = FirebaseFirestore.instance
              .collection('groups')
              .doc(widget.groupId);
          await groupToUpdate.update({
            'members': FieldValue.arrayUnion([userIdToAdd]),
          });
          setState(() {
            _showMessage = 'Added Successfully';
            _isAdding = false;
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Color(0xFFEB50A8).withAlpha(220),
                    content: Text(
                      'Added Successfully',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
                Navigator.of(context).pop();
              }
            });
          });
        }
      } catch (e) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Add New Member',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                InputField(
                  text: 'Email',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email mustn\'t be empty';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _emailName = value!;
                  },
                ),
                if (_showMessage != '')
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      _showMessage,
                      style:
                          _showMessage == 'Added Successfully'
                              ? TextStyle(color: Colors.green)
                              : TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Color(0xFFEB50A8).withAlpha(220),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      _addMemberToGroup();
                    },
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
    );
  }
}
