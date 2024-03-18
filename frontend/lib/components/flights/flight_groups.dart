// ignore_for_file: use_build_context_synchronously

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/airport.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/checkout/flight_summary.dart';
import 'package:tripsitter/components/comments_popup.dart';
import 'package:tripsitter/components/flights/flight_dialog.dart';
import 'package:tripsitter/components/flights/flight_options.dart';
import 'package:tripsitter/components/mobile_wrapper.dart';
import 'package:tripsitter/helpers/locators.dart';
import 'package:google_fonts/google_fonts.dart';

class FlightGroups extends StatefulWidget {
  final List<UserProfile> profiles;
  final Trip trip;
  final FlightGroup? currentGroup;
  final Function setState;
  final Function(FlightGroup?) setCurrentGroup;

  const FlightGroups(
      {required this.trip,
      required this.profiles,
      required this.currentGroup,
      required this.setState,
      required this.setCurrentGroup,
      super.key});

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
    String destinationAirport =
        (await getNearestAirport(trip.destination, context)).iataCode;
    for (var profile in profiles) {
      FlightGroup? existingGroup = trip.flights.firstWhereOrNull(
        (element) => element.members.contains(profile.id),
      );
      if (existingGroup != null) {
        continue;
      }
      if (profile.hometown != null) {
        var nearestAirport =
            (await getNearestAirport(profile.hometown!, context)).iataCode;
        FlightGroup? existing = trip.flights.firstWhereOrNull(
          (element) => element.departureAirport == nearestAirport,
        );
        if (existing != null) {
          debugPrint("Adding ${profile.name} to existing flight group");
          await existing.addMember(profile.id);
        } else {
          debugPrint("Creating new flight group for ${profile.name}");
          await trip
              .addFlightGroup(nearestAirport, destinationAirport, [profile.id]);
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context);
    User? user = Provider.of<User?>(context);
    return Container(
      color: const Color.fromARGB(255, 200, 200, 200),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(children: [
          // Text('Flight Groups', style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
          Center(
            child: Text(
              'Flight Groups',
              style: GoogleFonts.kadwa(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
          ),
          groups.isEmpty
              ? const Text('No flight groups')
              : Column(
                  children: groups.map((group) {
                    return Container(
                      decoration: BoxDecoration(
                        color: group == currentGroup
                            ? Colors.blue[200]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: group == currentGroup
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                List<Airport> nearbyDepartureAirports =
                                    await getNearbyAirports(
                                        group.departureAirport, context);
                                debugPrint(nearbyDepartureAirports
                                    .map((e) => e.iataCode)
                                    .join(", "));
      
                                List<Airport> nearbyArrivalAirports =
                                    await getNearbyAirports(
                                        group.arrivalAirport, context);
                                debugPrint(nearbyArrivalAirports
                                    .map((e) => e.iataCode)
                                    .join(", "));
      
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                            title: const Text("Change Airports"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (nearbyDepartureAirports
                                                        .length >
                                                    1)
                                                  DropdownButtonFormField<
                                                      Airport>(
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText:
                                                          'Departure Airport',
                                                    ),
                                                    value: nearbyDepartureAirports
                                                        .firstWhere((a) =>
                                                            a.iataCode ==
                                                            group
                                                                .departureAirport),
                                                    items: nearbyDepartureAirports
                                                        .map((Airport value) {
                                                      return DropdownMenuItem<
                                                          Airport>(
                                                        value: value,
                                                        child: Text(
                                                            "${value.name} (${value.iataCode})"),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (Airport? value) async {
                                                      if (value == null) return;
                                                      await group
                                                          .setDepartureAirport(
                                                              value.iataCode);
                                                      setState(() {});
                                                      widget.setState();
                                                      if (mounted) {
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                  ),
                                                if (nearbyArrivalAirports.length >
                                                    1)
                                                  DropdownButtonFormField<
                                                      Airport>(
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText:
                                                          'Arrival Airport',
                                                    ),
                                                    value: nearbyArrivalAirports
                                                        .firstWhere((a) =>
                                                            a.iataCode ==
                                                            group.arrivalAirport),
                                                    items: nearbyArrivalAirports
                                                        .map((Airport value) {
                                                      return DropdownMenuItem<
                                                          Airport>(
                                                        value: value,
                                                        child: Text(
                                                            "${value.name} (${value.iataCode})"),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (Airport? value) async {
                                                      if (value == null) return;
                                                      await group
                                                          .setArrivalAirport(
                                                              value.iataCode);
                                                      setState(() {});
                                                      widget.setState();
                                                      if (mounted) {
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                  ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Done"))
                                            ]));
                              },
                            ),
                            title: Text(
                                "${group.departureAirport} - ${group.arrivalAirport}"),
                            subtitle: Text(group.members
                                .map((e) =>
                                    profiles
                                        .firstWhereOrNull(
                                            (profile) => profile.id == e)
                                        ?.name ??
                                    "")
                                .join(', ')),
                            onTap: isMobile ? null : () {
                              widget.setCurrentGroup(group);
                              widget.setState();
                            },
                            // trailing: IconButton(
                            //   icon: const Icon(Icons.delete),
                            //   onPressed: () async {
                            //     if(group == currentGroup) {
                            //       widget.setCurrentGroup(null);
                            //     }
                            //     await trip.removeFlightGroup(group);
                            //     widget.setState();
                            //   },
                            // ),
                          ),
                          for (FlightOffer offer in group.options)
                            ListTile(
                              // selected: group.selected == offer,
                              // selectedColor: Colors.green[200],
                              leading: Radio<FlightOffer>(
                                value: offer,
                                groupValue: group.selected,
                                onChanged: (FlightOffer? value) async {
                                  if (value == null) return;
                                  await group.selectOption(value);
                                  setState(() {});
                                  widget.setState();
                                },
                              ),
                              subtitle: Text("\$${offer.price.total}"),
                              title: Row(
                                  children: offer.itineraries
                                      .map((itinerary) => Expanded(
                                          child: FlightItinerarySummary(
                                              itinerary, false)))
                                      .toList()),
      
                              // Text(offer.itineraries.map((i) {
                              //   return "${Airline.fromCode(i.segments.first.carrierCode)?.name ?? i.segments.last.carrierCode}: ${DateFormat('MMM d, yyyy').format(i.segments.first.departure.at)} ${DateFormat(DateFormat.HOUR_MINUTE).format(i.segments.first.departure.at)} - ${DateFormat(DateFormat.HOUR_MINUTE).format(i.segments.last.arrival.at)}";
                              // }).join(",\n")),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return FlightDialog(
                                              offer.itineraries.first);
                                        },
                                      );
                                    },
                                  ),
                                  CommentsPopup(
                                    comments: offer.comments,
                                    profiles: widget.profiles,
                                    myUid: user!.uid,
                                    removeComment: (TripComment comment) async {
                                      offer.removeComment(comment);
                                      await trip.save();
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    addComment: (String comment) async {
                                      offer.addComment(TripComment(
                                          comment: comment,
                                          uid: user.uid,
                                          date: DateTime.now()));
                                      await trip.save();
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      await group.removeOption(offer);
                                      widget.setState();
                                    },
                                  ),
                                ],
                              ),
                              // trailing: IconButton(
                              //   icon: Icon(Icons.add),
                              //   onPressed: () async {
                              //     await group.selectOption(offer);
                              //     widget.setState();
                              //   },
                              // )
                              onTap: isMobile ? null : () {
                                widget.setCurrentGroup(group);
                                widget.setState();
                              },
                            ),
                          if (isMobile)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return MobileWrapper(
                                      title: "Flight Options",
                                      child: FlightOptions(
                                        trip: widget.trip,
                                        profiles: widget.profiles,
                                        currentGroup: group,
                                        setState: () => setState(() {}),
                                      ),
                                    );
                                  }));
                                },
                                child: const Text("Add flight options"),
                              ),
                            )
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ]),
      ),
    );
  }
}
