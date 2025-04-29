import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/widgets/common_widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginRegister extends StatefulWidget {
  const LoginRegister({super.key, required this.onLoginSucces});

  final void Function(dynamic) onLoginSucces;

  @override
  State<LoginRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  bool _isLogin = true;
  bool _isCreating = false;
  final _form = GlobalKey<FormState>();
  String _enteredName = '';
  String _enteredEmail = '';
  String _enteredPassword = '';

  Future<void> _saveUser() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }

    _form.currentState!.save();
    try {
      setState(() {
        _isCreating = true;
      });
      if (_isLogin) {
        final userCrediential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _enteredEmail,
              password: _enteredPassword,
            );
        final user = userCrediential.user;
        if (user != null) {
          widget.onLoginSucces(user);
        }
        setState(() {
          _isCreating = false;
        });
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Color(0xFFEB50A8).withAlpha(220),
                content: Text(
                  'Logged in Successful.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
            Navigator.of(context).pop();
          }
        });
      } else {
        final userData = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _enteredEmail,
              password: _enteredPassword,
            );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userData.user!.uid)
            .set({
              'name': _enteredName,
              'email': _enteredEmail,
              'profilePicture': '',
              'createdAt': Timestamp.now(),
              'groups': [],
            });

        final user = userData.user;
        if (user != null) {
          widget.onLoginSucces(user);
        }
        setState(() {
          _isCreating = false;
        });

        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Color(0xFFEB50A8).withAlpha(220),
                content: Text(
                  'Your account has been Regitered Successfully.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
            Navigator.of(context).pop();
          }
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-email') {
        // .. throw some error.
      }
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text('Something went wrong! Please try again.'),
          ),
        );
        setState(() {
          _isCreating = false;
        });
        Future.delayed(Duration(milliseconds: 1000), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLogin ? 'Login' : 'Register',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(
                  _isLogin
                      ? 'Welcome back! good to see you'
                      : 'You are now going to be a member!',
                ),
                SizedBox(height: 30),
                if (!_isLogin)
                  Container(
                    decoration: BoxDecoration(
                      // color: const Color.fromARGB(137, 189, 182, 182),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InputField(
                      text: 'Username',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length < 3) {
                          return 'Username must be atleast 3 character long';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredName = value!;
                      },
                    ),
                  ),
                if (!_isLogin) SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    // color: const Color.fromARGB(137, 189, 182, 182),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InputField(
                    text: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email must not be empty';
                      }
                      if (!RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      ).hasMatch(value.trim())) {
                        return 'Invalid email address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredEmail = value!;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    // color: const Color.fromARGB(137, 189, 182, 182),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InputField(
                    text: 'Password',
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 6) {
                        return 'Password must be at least 6 character long';
                      }
                      return null;
                    },
                    hideText: true,
                    onSaved: (value) {
                      _enteredPassword = value!;
                    },
                  ),
                ),
                SizedBox(height: 30),
                if (_isCreating)
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFEB50A8).withAlpha(220),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CircularProgressIndicator(),
                  ),
                if (!_isCreating)
                  Container(
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Color(0xFFEB50A8).withAlpha(220),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: _saveUser,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        // backgroundColor: Color(0xFFEB50A8).withAlpha(220),
                      ),
                      child: Text(
                        _isLogin ? 'Login' : 'Register',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ),
                if (!_isCreating) SizedBox(height: 10),
                if (!_isCreating)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? 'I don\'t have an account'
                            : 'Already have an account',
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child:
                            _isCreating
                                ? CircularProgressIndicator()
                                : Text(
                                  _isLogin ? 'Register' : 'Login',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 253, 6, 146),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
