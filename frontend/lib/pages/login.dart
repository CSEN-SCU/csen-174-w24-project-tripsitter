import 'package:flutter/material.dart';

bool loggedIn = true;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In to TripSitter'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            loggedIn = true;
            // Don't allow the user to go back to the login page
            Navigator.pushReplacementNamed(context, "/");
          }, 
          child: Text("Sign in")
        )
      ),
    );
  }
}