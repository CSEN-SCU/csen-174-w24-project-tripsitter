import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/pages/login.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);
    if(user == null) {
      return const LoginPage();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In to TripSitter'),
        backgroundColor: const Color.fromRGBO(196, 53, 53, 1),
      ),
      body: Center(
            child: ElevatedButton(
              onPressed: () {
                // Don't allow the user to go back to the login page
                Navigator.pushReplacementNamed(context, "/");
              },
              child: const Text("Sign in")),
              ),
    );
  }
}
