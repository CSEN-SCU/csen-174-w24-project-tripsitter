import 'package:flutter/material.dart';

bool loggedIn = true;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In to TripSitter'),
        backgroundColor: Color.fromRGBO(196, 53, 53, 1),
      ),
      body: Center(
          child: ElevatedButton(
              onPressed: () {
                loggedIn = true;
                // Don't allow the user to go back to the login page
                Navigator.pushReplacementNamed(context, "/");
              },
              child: Text("Sign in"))),
    );
  }
}
