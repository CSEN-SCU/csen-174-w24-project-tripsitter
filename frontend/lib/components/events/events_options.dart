import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/events/event_info_dialog.dart';
import 'package:tripsitter/components/events/events_map.dart';
import 'package:tripsitter/components/events/select_events.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/popups/checkbox_popup.dart';
import 'package:google_fonts/google_fonts.dart';

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

class _EventsOptionsState extends State<EventsOptions>
    with TickerProviderStateMixin {
  List<TicketmasterEvent> events = [];
  Trip get trip => widget.trip;

  late AnimationController controller;

  bool isLoaded = true;

  bool mapSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    isLoaded = false;
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    super.initState();
    super.initState();
    getEvents();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

    isLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    // Initialize a counter variable before mapping the events to TableRows
    int rowIndex = 0;

    return ListView(
      children: [
        // Text("Choose Activities",
        //     style: Theme.of(context)
        //         .textTheme
        //         .displayMedium
        //         ?.copyWith(fontWeight: FontWeight.bold)),
        Wrap(
          children: [
            Text("Choose Activities", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.fromLTRB(80, 10, 0, 0),
              child: Text("Toggle Map Mode",
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        decoration: TextDecoration.none,
                        fontSize: 12,
                      )),
            ),
            Switch(
              value: mapSelected,
              onChanged: (bool value) {
                setState(() {
                  mapSelected = value;
                });
              },
            ),
          ],
        ),
        !isLoaded
            ? Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: controller.value,
                    strokeWidth: 20,
                    semanticsLabel: 'Circular progress indicator',
                  ),
                ),
              )
            : mapSelected
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return EventsMap(
                          height: constraints.maxHeight - 50,
                          trip: trip,
                          profiles: widget.profiles,
                          events: events,
                          setState: widget.setState,
                        );
                      },
                    ),
                  )
                : Table(
                    columnWidths: const <int, TableColumnWidth>{
                        0: FixedColumnWidth(75),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FixedColumnWidth(50),
                        4: FixedColumnWidth(150),
                      },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: events
                        .map((event) => TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: event.images.isEmpty
                                    ? Icon(Icons.star)
                                    : Image.network(event.images.first.url,
                                        height: 50),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(event.prices.isEmpty
                                    ? event.name
                                    : "${event.name}\nFrom \$${event.prices.map((p) => p.min).reduce(min)}/person"),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    '${event.venues.firstOrNull?.name}\nStarts ${event.startTime.localDate} ${event.startTime.localTime}'),
                              )),
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
                                          ? null
                                          : () async {
                                              await trip.addActivity(
                                                  event,
                                                  widget.profiles
                                                      .map((e) => e.id)
                                                      .toList());
                                              setState(() {});
                                              if (widget.setState != null) {
                                                widget.setState!();
                                              }
                                            },
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  selected
                                                      ? Color.fromARGB(
                                                          255, 127, 166, 198)
                                                      : Colors.grey[300]!)),
                                      child: Text(
                                          'Select${selected ? 'ed' : ''}',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    );
                                  }),
                                ),
                              ),
                            ]))
                        .toList()),
      ],
    );
  }
}
