import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/events/event_info_dialog.dart';
import 'package:tripsitter/components/events/select_events.dart';
import 'package:tripsitter/helpers/api.dart';

class EventsOptions extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  final Function? setState;
  const EventsOptions({required this.trip, required this.profiles, this.setState, super.key});

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
    List<TicketmasterEvent> call = await TripsitterApi.getEvents(TicketmasterQuery(
      lat: trip.destination.lat,
      long: trip.destination.lon,
      startDateTime: trip.startDate,
      endDateTime: trip.endDate,
    ));

    setState(() {
      events = call;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text("Choose Activites", style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
        if(events.isNotEmpty)
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(75),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FixedColumnWidth(50),
              4: FixedColumnWidth(150),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: events.map((event) => TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: event.images.isEmpty ? Icon(Icons.star) : Image.network(event.images.first.url, height: 50),
                  )
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(event.prices.isEmpty ? event.name :"${event.name}\nFrom \$${event.prices.map((p) => p.min).reduce(min)}/person"),
                  )
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${event.venues.firstOrNull?.name}\nStarts ${event.startTime.localDate} ${event.startTime.localTime}'),
                  )
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
                      }
                    ),
                  )
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(
                      builder: (context) {
                        bool selected =  trip.activities.map((e) => e.event.id).contains(event.id);
                        return ElevatedButton(
                          onPressed: selected ? null : () async {
                            await trip.addActivity(event, widget.profiles.map((e) => e.id).toList());
                            setState(() {});
                            if(widget.setState != null) {
                              widget.setState!();
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(selected ? Color.fromARGB(255, 127, 166, 198) : Colors.grey[300]!)
                          ),
                          child: Text('Select${selected ? 'ed' : ''}', style: TextStyle(color: Colors.black)),
                        );
                      }
                    ),
                  ),
                ),
              ]
            )).toList()
          ),
      ],
    );
  }
}