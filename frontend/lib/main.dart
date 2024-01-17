import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tripsitter/pages/another_page.dart';
import 'package:tripsitter/pages/home.dart';
import 'package:tripsitter/pages/login.dart';
import 'firebase_options.dart';
import 'package:fluro/fluro.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Handler homeHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const HomePage();
  });
  Handler loginHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const LoginPage();
  });
  Handler anotherHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const AnotherPage();
  });

  router.define("/", handler: homeHandler);
  router.define("/another", handler: anotherHandler);
  router.define("/login", handler: loginHandler);
  router.notFoundHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return HomePage();
  });
  
  runApp(const MyApp());
}

final router = FluroRouter();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
          StreamProvider<User?>.value(
              value: FirebaseAuth.instance.authStateChanges(),
              initialData: null),
        ],
      child: MaterialApp(
        onGenerateRoute: router.generator,
        title: 'TripSitter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
          useMaterial3: true,
        ),
      ),
    );
  }
}
