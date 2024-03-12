import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/map.dart';

const String mapboxToken = String.fromEnvironment("MAPBOX_ACCESS_TOKEN");

class EventsMap extends StatelessWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  final Function? setState;
  final double height;

  final List<TicketmasterEvent> events;

  const EventsMap(
      {required this.trip,
      required this.profiles,
      required this.setState,
      required this.events,
      required this.height,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 520, child: TripsitterMap(trip: trip, events: events));
  }
}
