import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/pages/create_trip.dart';
import 'package:tripsitter/pages/view_trip.dart';
import 'package:tripsitter/pages/view_flights.dart';
import 'package:tripsitter/pages/home.dart';
import 'package:tripsitter/pages/login.dart';
import 'package:url_strategy/url_strategy.dart';
import 'firebase_options.dart';
import 'package:fluro/fluro.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripsitter/no_animation_page_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  print("STRIPE KEY: ${const String.fromEnvironment('STRIPE_PK_TEST')}");
  // Stripe.publishableKey = const String.fromEnvironment('STRIPE_PK_TEST');
  // await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Handler homeHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const HomePage();
  });
  Handler newTripHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const CreateTrip();
  });
  Handler viewTrip = Handler(
    handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      // if constraints.maxWidth > 600 { go to desktop }
      return ViewTrip(params["id"][0]);
    },
  );
  Handler viewFlights = Handler(
    handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      // if constraints.maxWidth > 600 { go to desktop }
      return ViewFlights(params["id"][0]);
    },
  );

  router.define("/", handler: homeHandler, transitionType: TransitionType.none);
  router.define("/trip/:id/flights",
      handler: viewFlights, transitionType: TransitionType.none);
  router.define("/trip/:id",
      handler: viewTrip, transitionType: TransitionType.none);
  router.define("/new",
      handler: newTripHandler, transitionType: TransitionType.none);
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
    Airline.cacheAirlines(context);
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
            value: FirebaseAuth.instance.authStateChanges(), initialData: null),
      ],
      child: Builder(builder: (context) {
        User? user = Provider.of<User?>(context);
        if (user == null) {
          return MaterialApp(
            onGenerateRoute: router.generator,
            title: 'TripSitter',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple, brightness: Brightness.light),
              useMaterial3: true,
            ),
            home: const LoginPage(),
          );
        }
        return MultiProvider(
          providers: [
            StreamProvider<UserProfile?>.value(
              initialData: null,
              value: UserProfile.getProfile(user.uid),
            )
          ],
          child: MaterialApp(
            onGenerateRoute: router.generator,
            title: 'TripSitter',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple, brightness: Brightness.light),
              useMaterial3: true,
            ),
          ),
        );
      }),
    );
  }
}
