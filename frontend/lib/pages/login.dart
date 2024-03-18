import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tripsitter/helpers/styles.dart';

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
      if(mounted) {
        setState(() {
          _user = event;
        });
      }
      if (_user == null) {
        debugPrint('User is currently signed out!');
      } else {
        debugPrint('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            "assets/skyline.png",
          ),
        ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Tripsitter", style: sectionHeaderStyle.copyWith(fontSize: 50)),
                Image.asset("assets/tripsitter_logo.png", width: 200, height: 200,),
                Container( child: _user != null ? _userInfo() : _googleSignInButton()),
                Container(height: 100)
              ],
            )
          ),
        ],
      ),
    );
  }

  Widget _googleSignInButton() {
    return Center(child: SizedBox(
      height: 50,
      child: SignInButton(
        Buttons.google,
        text: 'Log In/Sign Up',
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
    final prefs = await SharedPreferences.getInstance();
    if(kIsWeb) {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope(gcal.CalendarApi.calendarEventsScope);
      googleProvider.setCustomParameters({
        'login_hint': 'user@example.com'
      });

      // Once signed in, return the UserCredential
      UserCredential cred = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      prefs.setString('gcalToken', cred.credential?.accessToken ?? "");
      return cred;
    }
    else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: <String>[gcal.CalendarApi.calendarEventsScope],
      ).signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      prefs.setString('gcalToken', credential.accessToken ?? "");

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }
}
