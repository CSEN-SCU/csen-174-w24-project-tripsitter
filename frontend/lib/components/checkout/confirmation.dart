import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/checkout/trip_summary.dart';
import 'package:tripsitter/components/navbar.dart';
import 'package:tripsitter/helpers/styles.dart';

class ConfirmationPage extends StatelessWidget {
  final Trip trip;
  final List<UserProfile> profiles;

  const ConfirmationPage({required this.trip, required this.profiles,super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 20)
      );
    }
    String uid = user.uid;
    return Scaffold(
      appBar: const TripSitterNavbar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 650,
          ),
          child: ListView(
            children: [
              Center(child: Text("Your trip is confirmed!", style: sectionHeaderStyle.copyWith(fontSize: 30))),
              const Text(""),
              TripSummary(
                trip: trip,
                uid: uid,
                profiles: profiles,
                showSplit: false,
                showBooking: true,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                }, 
                child: const Text("Return to home")
              ),
            ]
          ),
        )
      ),
    );
  }
}