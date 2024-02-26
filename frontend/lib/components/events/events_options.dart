import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/events/event_info_dialog.dart';
import 'package:tripsitter/components/events/select_events.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/popups/checkbox_popup.dart';

class EventsOptions extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  final Map<String, GlobalKey> participantsPopupKeys;
  final Map<String, List<String>> selectedParticipantsMap;
  final Map<String, bool> participantsPopupOpenState;
  final Function? setState;

  const EventsOptions({
    required this.trip,
    required this.profiles,
    required this.participantsPopupKeys,
    required this.selectedParticipantsMap,
    required this.participantsPopupOpenState,
    this.setState,
    super.key,
  });

  @override
  State<EventsOptions> createState() => _EventsOptionsState();
}

class _EventsOptionsState extends State<EventsOptions> {
  List<TicketmasterEvent> events = [];
  Trip get trip => widget.trip;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEvents();
  }

  Future<void> getEvents() async {
    print("Getting events for trip ${trip.id}");
    List<TicketmasterEvent> call =
        await TripsitterApi.getEvents(TicketmasterQuery(
      lat: trip.destination.lat,
      long: trip.destination.lon,
      startDateTime: trip.startDate,
      endDateTime: trip.endDate,
    ));

    // After fetching events, initialize GlobalKeys for each
    setState(() {
      events = call;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize a counter variable before mapping the events to TableRows
    int rowIndex = 0;

    return ListView(
      children: [
        Text("Choose Activities",
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        if (events.isNotEmpty)
          Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(75),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FixedColumnWidth(50),
                4: FixedColumnWidth(150),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: events.map((event) {
                // Determine the background color based on the row index
                Color bgColor = rowIndex % 2 == 0
                    ? Colors.grey[200]! // Light gray color
                    : Colors.white; // White color

                // Increment the row index for the next iteration
                rowIndex++;

                return TableRow(
                    decoration: BoxDecoration(
                        color: bgColor), // Apply the background color here
                    children: [
                      TableCell(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: event.images.isEmpty
                            ? Icon(Icons.star)
                            : Image.network(event.images.first.url, height: 50),
                      )),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: event.name,
                                  style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold, // Make text bold
                                      color: Colors
                                          .black), // Ensure text color is consistent
                                ),
                                TextSpan(
                                  text: event.prices.isEmpty
                                      ? ''
                                      : "\nFrom \$${event.prices.map((p) => p.min).reduce(min)}/person",
                                  style: TextStyle(
                                      fontWeight:
                                          FontWeight.normal, // Regular text
                                      color: Colors
                                          .black), // Ensure text color is consistent
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${event.venues.firstOrNull?.name ?? "Venue TBA"}\n${event.startTime.getFormattedDate()}\nStarts ${event.startTime.getFormattedTime()}',
                          ),
                        ),
                      ),
                      TableCell(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                            icon: Icon(Icons.info),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return EventPopup(event);
                                },
                              );
                            }),
                      )),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Builder(builder: (context) {
                            bool selected = trip.activities
                                .map((e) => e.event.id)
                                .contains(event.id);
                            return ElevatedButton(
                              onPressed: selected
                                  ? () async {
                                      var activityToRemove = trip.activities
                                          .firstWhere(
                                              (a) => a.event.id == event.id);
                                      await trip
                                          .removeActivity(activityToRemove);
                                      String eventId =
                                          activityToRemove.event.id;
                                      widget.participantsPopupKeys
                                          .remove(eventId);
                                      widget.selectedParticipantsMap
                                          .remove(eventId);
                                      widget.participantsPopupOpenState
                                          .remove(eventId);
                                      setState(() {});
                                      if (widget.setState != null) {
                                        widget.setState!();
                                      }
                                    }
                                  : () async {
                                      await trip.addActivity(
                                        event,
                                        widget.profiles
                                            .map((e) => e.id)
                                            .toList(),
                                      );

                                      String eventId = event.id;
                                      widget.participantsPopupKeys[eventId] =
                                          GlobalKey();
                                      widget.selectedParticipantsMap[eventId] =
                                          widget.profiles
                                              .map((e) => e.id)
                                              .toList();
                                      widget.participantsPopupOpenState[
                                          eventId] = false;
                                      setState(() {});
                                      if (widget.setState != null) {
                                        widget.setState!();
                                      }
                                    },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(selected
                                          ? Color.fromARGB(255, 127, 166, 198)
                                          : Colors.grey[300]!)),
                              child: Text('Select${selected ? 'ed' : ''}',
                                  style: TextStyle(color: Colors.black)),
                            );
                          }),
                        ),
                      ),
                    ]);
              }).toList()),
      ],
    );
  }
}
