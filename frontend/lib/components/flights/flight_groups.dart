import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/locators.dart';

class FlightGroups extends StatefulWidget {

  final List<UserProfile> profiles;
  final Trip trip;
  final FlightGroup? currentGroup;
  final Function setState;
  final Function(FlightGroup?) setCurrentGroup;
  
  const FlightGroups({required this.trip, required this.profiles, required this.currentGroup, required this.setState, required this.setCurrentGroup, super.key});

  @override
  State<FlightGroups> createState() => _FlightGroupsState();
}

class _FlightGroupsState extends State<FlightGroups> {

  Trip get trip => widget.trip;
  List<UserProfile> get profiles => widget.profiles;
  FlightGroup? get currentGroup => widget.currentGroup;
  List<FlightGroup> get groups => trip.flights;

  @override
  void initState() {
    super.initState();
    createFlightGroups();
  }

  Future<void> createFlightGroups() async {
  String destinationAirport = await getNearestAirport(trip.destination, context);
  for (var profile in profiles) {
    FlightGroup? existingGroup = trip.flights.firstWhereOrNull(
      (element) => element.members.contains(profile.id),
    );
    if (existingGroup != null) {
      continue;
    }
    if (profile.hometown != null) {
      var nearestAirport = await getNearestAirport(profile.hometown!, context);
      FlightGroup? existing = trip.flights.firstWhereOrNull(
        (element) => element.departureAirport == nearestAirport,
      );
      if (existing != null) {
        print("Adding ${profile.name} to existing flight group");
        await existing.addMember(profile.id);
      } else {
        print("Creating new flight group for ${profile.name}");
        await trip.addFlightGroup(nearestAirport, destinationAirport, [profile.id]);
      }
    }
  }
  if(mounted) {
    setState(() {   
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Text('Flight Groups', style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
          groups.isEmpty ? const Text('No flight groups') : Column(
            children: groups.map((group) {
              return ListTile(
                title: Text("${group.departureAirport} - ${group.arrivalAirport}"),
                subtitle: Text(group.members.map((e) => profiles.firstWhere((profile) => profile.id == e).name ).join(', ')),
                onTap: () {
                  widget.setCurrentGroup(group);
                  widget.setState();
                },
                selected: currentGroup == group,
              );
            }).toList(),
          ),
        ]
      ),
    );
  }
}