import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/pages/create_trip.dart';
import 'package:tripsitter/pages/profile_page.dart';
import 'package:tripsitter/pages/update_Profile.dart';
import 'package:tripsitter/pages/view_trip.dart';
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
  Stripe.publishableKey = const String.fromEnvironment('STRIPE_PK_TEST');
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Handler homeHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const ProfilePage();
  });
  Handler newTripHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const CreateTrip();
  });
  Handler updateProfileHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return UpdateProfile();
  });
  Handler viewTrip = Handler(
    handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      // if constraints.maxWidth > 600 { go to desktop }
      return ViewTrip(params["id"][0]);
    },
  );

  router.define("/profile", handler: updateProfileHandler);
  router.define("/", handler: homeHandler, transitionType: TransitionType.none);
  router.define("/trip/:id",
      handler: viewTrip, transitionType: TransitionType.none);
  router.define("/new",
      handler: newTripHandler, transitionType: TransitionType.none);
  router.notFoundHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return ProfilePage();
  });

  runApp(const MyApp());
}

final router = FluroRouter();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    Airline.cacheAirlines(context);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      bool isMobile = constraints.maxWidth < 750;
      return MultiProvider(
        providers: [
          StreamProvider<User?>.value(
              value: FirebaseAuth.instance.authStateChanges(),
              initialData: null),
          Provider<bool>.value(
            value: isMobile,
          ),
        ],
        child: Builder(builder: (context) {
          User? user = Provider.of<User?>(context);
          if (user == null) {
            return MaterialApp(
              onGenerateRoute: router.generator,
              title: 'TripSitter',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: HexColor("#C6D6FF"), brightness: Brightness.light),
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
                    seedColor: HexColor("#C6D6FF"), brightness: Brightness.light),
                useMaterial3: true,
              ),
            ),
          );
        }),
      );
    });
  }
}
