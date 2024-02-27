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

class SelectEvents extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;

  const SelectEvents(this.trip, this.profiles, {super.key});

  @override
  State<SelectEvents> createState() => _SelectEventsState();
}

class _SelectEventsState extends State<SelectEvents> {
  Map<String, GlobalKey> participantsPopupKeys = {};
  Map<String, List<String>> selectedParticipantsMap = {};
  Map<String, bool> participantsPopupOpenState = {};

  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context);
    if (isMobile) {
      return EventsItinerary(
        trip: widget.trip,
        profiles: widget.profiles,
        participantsPopupKeys: participantsPopupKeys,
        selectedParticipantsMap: selectedParticipantsMap,
        participantsPopupOpenState: participantsPopupOpenState,
      );
    }
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    bottomLeft: Radius.circular(25.0)),
                color: Color.fromARGB(255, 200, 200, 200),
              ),
              width: constraints.maxWidth * 0.35,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: EventsItinerary(
                    trip: widget.trip,
                    profiles: widget.profiles,
                    participantsPopupKeys: participantsPopupKeys,
                    selectedParticipantsMap: selectedParticipantsMap,
                    participantsPopupOpenState: participantsPopupOpenState,
                    setState: () => setState(() {}),
                  ))),
          Container(
              width: constraints.maxWidth * 0.65,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: EventsOptions(
                  trip: widget.trip,
                  profiles: widget.profiles,
                  participantsPopupKeys: participantsPopupKeys,
                  selectedParticipantsMap: selectedParticipantsMap,
                  participantsPopupOpenState: participantsPopupOpenState,
                  setState: () => setState(() {}),
                ),
              ))
        ],
      );
    });
  }
}
