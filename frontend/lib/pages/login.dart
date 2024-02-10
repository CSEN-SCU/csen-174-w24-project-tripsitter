import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
      if (_user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In to TripSitter'),
      ),
      body: _user != null ? _userInfo() : _googleSignInButton(),
    );
  }

  Widget _googleSignInButton() {
    return Center(child: SizedBox(
      height: 50,
      child: SignInButton(
        Buttons.google,
        text: 'Login To TripSitter',
        onPressed: signInWithGoogle,
      ),
    ),);

  }

  Widget _userInfo() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 36
          ),
          children: [
            const TextSpan(
            style: TextStyle(
              color: Colors.white
            ),
            text: 'Hello: '),
            TextSpan(
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold
              ),
              text: _user?.displayName
            ),
          ]
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    if(kIsWeb) {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider.setCustomParameters({
        'login_hint': 'user@example.com'
      });

      // Once signed in, return the UserCredential
      if(kIsWeb) {
        return await FirebaseAuth.instance.signInWithPopup(googleProvider);
      }
      return await FirebaseAuth.instance.signInWithProvider(googleProvider);
    }
    else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }
}
