// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbma_portal/Accounts/student_dashboard.dart';
import 'package:pbma_portal/pages/admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInMobile extends StatefulWidget {
  final VoidCallback closeSignInCardCallback;

  const SignInMobile({super.key, required this.closeSignInCardCallback});

  @override
  State<SignInMobile> createState() => _SignInMobileState();
}

class _SignInMobileState extends State<SignInMobile> {
  bool _obscureText = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  void _togglePasswordVisibility(bool isPressed) {
    setState(() {
      _obscureText = !isPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10)
      ),
      child: Card(
        elevation: 10,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.topRight,
                child: IconButton(onPressed: widget.closeSignInCardCallback, 
                icon: Icon(Icons.close_outlined)),
              ),
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/PBMA.png',
                  width: screenWidth / 2,
                  height: screenHeight / 2.5,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 52.0),
                  child: Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: screenHeight / 14,
                width: screenWidth / 1.44,
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey.shade300),
                  controller: _emailController,
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Icon(Icons.email_outlined),
                  ),
                  placeholder: 'Email',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: screenHeight / 14,
                width: screenWidth / 1.44,
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey.shade300),
                  controller: _passwordController,
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Icon(Icons.lock_outline),
                  ),
                  placeholder: 'Password',
                  obscureText: _obscureText,
                  suffix: Container(
                    margin: EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTapDown: (_) => _togglePasswordVisibility(true),
                      onTapUp: (_) => _togglePasswordVisibility(false),
                      onTapCancel: () => _togglePasswordVisibility(false),
                      child: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Checkbox(
                      activeColor: Colors.blueAccent,
                      checkColor: Colors.white,
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),
                  Text('Remember Me'),
                  SizedBox(
                    width: 100,
                  ),
                  TextButton(onPressed: () {}, child: Text('Forgot Password?'))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: screenHeight / 16,
                width: screenWidth / 1.44,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Colors.deepPurpleAccent),
                      elevation: WidgetStateProperty.all<double>(5),
                      shape: WidgetStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _checkEmailandPasswords();
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }



  void _checkEmailandPasswords() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (password.isEmpty || email.isEmpty) {
      _showDialog('Empty Fields', 'Please fill in both fields.');
      return;
    }

    RegExp regex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_-]).{8,}$',
    );

    if (!regex.hasMatch(password)) {
      _showDialog('Weak Password',
          'Password must contain at least 8 characters, including uppercase letters, lowercase letters, numbers, and symbols.');
      return;
    }
    RegExp emailRegex = RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]");

    if (!emailRegex.hasMatch(email)) {
      _showDialog('Invalid Mobile Number or Email',
          'Please Enter Valid Mobile Number or Email');
      return;
    }
    _signIn();
  }

  Future<void> _signIn() async {
    try {
      final String email = _emailController.text.trim();
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        final QuerySnapshot userDocs = await FirebaseFirestore.instance
        .collection('users')
        .where('email_Address', isEqualTo: email)
        .get();

        if (userDocs.docs.isNotEmpty) {
          final accountType = (userDocs.docs.first.data()
              as Map<String, dynamic>?)?['accountType'];
              if (accountType == "admin") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          } else if (accountType == "student") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StudentDashboard()),
            );
        } else {
          _showDialog('Login Failed', 'Account type is not recognized.');
        }
      } else {
        _showDialog('User Not Found', 'User document not found.');
      }

      _saveRememberMe(true, email);
    }
  } catch (error) {
    String errorMessage = 'An error occurred. Please try again later.';
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Invalid password.';
          break;
        default:
          errorMessage = 'Authentication error: ${error.message}';
      }
    } else {
      errorMessage = 'Unexpected error: ${error.toString()}';
    }
    
    _showDialog('Login Failed', errorMessage);
  }
}

  void _showDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
    if (_rememberMe) {
      List<String>? rememberedEmails = prefs.getStringList('rememberedEmails');
      if (rememberedEmails != null && rememberedEmails.isNotEmpty) {
        _emailController.text =
            rememberedEmails.last;
      }
    }
  }

  void _saveRememberMe(bool value, [String? email]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _rememberMe = value;
    if (_rememberMe) {
      List<String> rememberedEmails =
          prefs.getStringList('rememberedEmails') ?? [];
      if (!rememberedEmails.contains(email)) {
        rememberedEmails
            .add(email!);
        prefs.setStringList('rememberedEmails', rememberedEmails);
      }
    } else {
      prefs.remove('rememberedEmails');
    }
    prefs.setBool('rememberMe', _rememberMe);
  }
}
