
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/restaurants/restaurant_itinerary.dart';
import 'package:tripsitter/components/restaurants/restaurant_options.dart';

class SelectRestaurants extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;

  const SelectRestaurants(this.trip, this.profiles, {super.key});

  @override
  State<SelectRestaurants> createState() => _SelectRestaurantsState();
}

class _SelectRestaurantsState extends State<SelectRestaurants> {
  Map<String, GlobalKey> participantsPopupKeys = {};
  Map<String, List<String>> selectedParticipantsMap = {};
  Map<String, bool> participantsPopupOpenState = {};

  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context);
    if (isMobile) {
      return RestaurantsItinerary(
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
                  child: RestaurantsItinerary(
                    trip: widget.trip,
                    profiles: widget.profiles,
                    participantsPopupKeys: participantsPopupKeys,
                    selectedParticipantsMap: selectedParticipantsMap,
                    participantsPopupOpenState: participantsPopupOpenState,
                    setState: () => setState(() {}),
                  ))),
          SizedBox(
              width: constraints.maxWidth * 0.65,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RestaurantsOptions(
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
