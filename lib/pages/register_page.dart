import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _ConfirmpasswordTextController = TextEditingController();

  //sign user up

  void signUp() async {
    // shpow loading circle
    showDialog(
      context: context,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    // make sure password match
    if (_passwordTextController.text != _ConfirmpasswordTextController.text) {
      //pop loading circle
      Navigator.pop(context);

      //show error to user
      displayMessage("Password don't match");
      return;
    }
    // try creating the user
    try {
      // create the user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailTextController.text,
              password: _passwordTextController.text);

      // after creating the user, create a new document in cloud Firestore called Users
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email!)
          .set({
        'username':
            _emailTextController.text.split('@')[0], // initial user name
        'bio': 'Empty bio'
      });

      // pop the circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop loading circle
      Navigator.pop(context);

      //show error to user
      displayMessage(e.code);
    }
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo
                  Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  SizedBox(
                    height: 50,
                  ),

                  // welcome back message
                  Text(
                    'Let\'s create an account for you',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(
                    height: 30,
                  ),

                  // email text field
                  MyTextField(
                      controller: _emailTextController,
                      hintText: 'Email',
                      obscureText: false),

                  SizedBox(
                    height: 10,
                  ),

                  // password text field
                  MyTextField(
                      controller: _passwordTextController,
                      hintText: 'Password',
                      obscureText: true),
                  SizedBox(
                    height: 10,
                  ),

                  //cnfirm password text field
                  MyTextField(
                      controller: _ConfirmpasswordTextController,
                      hintText: 'Confirm Password',
                      obscureText: true),

                  SizedBox(
                    height: 20,
                  ),

                  // sign up button
                  MyButton(onTap: signUp, text: 'Sign up'),

                  SizedBox(
                    height: 20,
                  ),

                  // go to register page

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a member?',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Log in',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
