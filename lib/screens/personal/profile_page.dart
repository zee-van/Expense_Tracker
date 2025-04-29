import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/screens/home_page.dart';
import 'package:expense_tracker/widgets/common_widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  State<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  final loggedUser = FirebaseAuth.instance.currentUser;
  TextEditingController? nameController;
  TextEditingController? emailController;
  DateTime? createdAt;
  final _form = GlobalKey<FormState>();
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final loggedUserData =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(loggedUser!.uid)
              .get();
      setState(() {
        nameController = TextEditingController(
          text: loggedUserData.data()!['name'],
        );
        emailController = TextEditingController(
          text: loggedUserData.data()!['email'],
        );
        final timestamp = loggedUserData.data()!['createdAt'] as Timestamp;
        createdAt = timestamp.toDate().toLocal();
      });
    } catch (e) {
      setState(() {});
    }
  }

  void _updateProfile() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      final userDocument = FirebaseFirestore.instance
          .collection('users')
          .doc(loggedUser!.uid);
      try {
        setState(() {
          isUpdating = true;
        });
        await userDocument.update({'name': nameController!.text});
        setState(() {
          isUpdating = false;
        });
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => HomePageScreen()),
          );
        }
      } catch (e) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(10),
              Theme.of(context).colorScheme.primary.withAlpha(15),
              Theme.of(context).colorScheme.primary.withAlpha(10),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Please try to change username only!'),
            SizedBox(height: 20),
            InputField(
              text: 'Name',
              validator: (nameController) {
                if (nameController == null || nameController.isEmpty) {
                  return 'Provide the name please';
                }
                return null;
              },
              controller: nameController,
            ),
            SizedBox(height: 20),
            InputField(text: 'Email', controller: emailController),
            SizedBox(height: 20),
            Container(
              child:
                  createdAt != null
                      ? Text(
                        'Joined On: ${DateFormat('yyyy-MM-dd – HH:mm').format(createdAt!)}',
                      )
                      : CircularProgressIndicator(),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: _updateProfile,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFEB50A8).withAlpha(200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    _updateProfile();
                  },
                  child:
                      isUpdating
                          ? CircularProgressIndicator()
                          : Text('Save', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
