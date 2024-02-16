import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/events/events_itinerary.dart';
import 'package:tripsitter/components/events/events_options.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectEvents extends StatelessWidget {
  final Trip trip;
  final List<UserProfile> profiles;

  const SelectEvents(this.trip, this.profiles, {super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context);
    if(isMobile) {
      return EventsItinerary(trip: trip, profiles: profiles);
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color.fromARGB(255, 127, 166, 198),
              width: constraints.maxWidth * 0.35,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: EventsItinerary(
                  trip: trip,
                  profiles: profiles,
                )
              )
            ),
            Container(
              width: constraints.maxWidth * 0.65,
              child: EventsOptions(
                trip: trip,
                profiles: profiles,
              )
            )
          ],
        );
      }
    );
  }
}