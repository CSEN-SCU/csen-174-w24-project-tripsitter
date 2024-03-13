import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';

class MobileWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  final Trip? trip;
  final List<UserProfile>? profiles;
  const MobileWrapper({required this.title, this.trip, this.profiles, required this.child,super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<String>.value(value: title),
        if(trip != null)
          Provider<Trip?>.value(value: trip),
        if(profiles != null)
          Provider<List<UserProfile>>.value(value: profiles!),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: child,
      ),
    );
  }
}