import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/checkout/trip_summary.dart';
import 'package:tripsitter/components/navbar.dart';

class ConfirmationPage extends StatelessWidget {
  final Trip trip;
  final List<UserProfile> profiles;

  const ConfirmationPage({required this.trip, required this.profiles,super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      return const Center(
        child: CircularProgressIndicator()
      );
    }
    bool split = trip.usingSplitPayments;
    String uid = user.uid;
    return Scaffold(
      appBar: const TripSitterNavbar(),
      body: Center(
        child: Column(
          children: [
            const Text("Thank you for your purchase!"),
            const Text("Your trip is confirmed!"),
            TripSummary(
              trip: trip,
              uid: uid,
              profiles: profiles,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName("/"));
              }, 
              child: const Text("Return to home")
            ),
          ]
        )
      ),
    );
  }
}