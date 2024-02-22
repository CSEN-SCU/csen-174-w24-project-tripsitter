import 'package:flutter/material.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/flights/flight_groups.dart';
import 'package:tripsitter/components/flights/flight_options.dart';

class SelectFlight extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  const SelectFlight(this.trip, this.profiles,{super.key});

  @override
  State<SelectFlight> createState() => _SelectFlightState();
}

class _SelectFlightState extends State<SelectFlight> {
  @override
  void initState() {
    super.initState();
  }

  FlightGroup? currentGroup;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), bottomLeft: Radius.circular(25.0)),
                color: Color.fromARGB(255, 200, 200, 200),
              ),
              width: constraints.maxWidth * 0.35,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlightGroups(
                  trip: widget.trip,
                  profiles: widget.profiles,
                  currentGroup: currentGroup,
                  setCurrentGroup: (FlightGroup? group) {
                    setState(() {
                      currentGroup = group;
                    });
                  }, 
                  setState: () {
                    setState(() {});
                  },
                ),
              )
            ),
            Container(
              width: constraints.maxWidth * 0.65,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlightOptions(
                  trip: widget.trip,
                  profiles: widget.profiles,
                  currentGroup: currentGroup,
                  setState: () => setState((){}),
                ),
              )
            )
          ],
        );
      }
    );
  }
}
