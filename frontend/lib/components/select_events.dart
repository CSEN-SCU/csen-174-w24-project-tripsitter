import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectEvents extends StatefulWidget {
  final Trip trip;

  const SelectEvents(this.trip,{super.key});

  @override
  State<SelectEvents> createState() => _SelectEventsState();
}

class _SelectEventsState extends State<SelectEvents> {
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: constraints.maxWidth * 0.65,
              child: ListView(
                children: [
                  Text("Choose Activites", style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TableCell(
                            child: event.images.isEmpty ? Icon(Icons.star) : Image.network(event.images.first.url, height: 50),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TableCell(
                            child: Text(event.prices.isEmpty ? event.name :"${event.name}\nFrom \$${event.prices.map((p) => p.min).reduce(min)}/person")
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TableCell(
                            child: Text('${event.venues.firstOrNull?.name}\nStarts ${event.startTime.localDate} ${event.startTime.localTime}')
                          ),
                        ),
                        TableCell(
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
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TableCell(
                            child: Builder(
                              builder: (context) {
                                bool selected =  trip.activities.map((e) => e.id).contains(event.id);
                                return ElevatedButton(
                                  onPressed: selected ? null : () async {
                                    
                                    await trip.addActivity(event);
                                    setState(() {});
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
              )
            ),
            Container(
              color: Color.fromARGB(255, 127, 166, 198),
              width: constraints.maxWidth * 0.35,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Itinerary', style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ListView(
                        children: trip.activities.map((event) => ListTile(
                          title: Text(event.name),
                          isThreeLine: true,
                          subtitle: Text('${event.venues.firstOrNull?.name}\n${event.startTime.localDate} ${event.startTime.localTime}'),
                          trailing: ElevatedButton(
                            onPressed: () async{
                              await trip.removeActivity(event);
                              setState(() {});
                            },
                            child: const Text('Remove'),
                          ),
                        )).toList(),
                      ),
                    ),
                  ]
                ),
              )
            ),
          ],
        );
      }
    );
  }
}

class EventPopup extends StatelessWidget {
  final TicketmasterEvent event;
  const EventPopup(this.event,{super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(event.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Starts ${event.startTime.localDate} ${event.startTime.localTime}'),
          // Text('Ends ${event.endTime.localDate} ${event.endTime.localTime}'),
          Text('At ${event.venues.firstOrNull?.name}'),
          if(event.ticketLimit != null && event.ticketLimit! > 0)
            ...[
              Container(height: 30),
              Text("Ticket Limit: ${event.ticketLimit}"),
            ],
          if(event.info.infoStr != null && event.info.infoStr!.isNotEmpty)
            ...[
              Container(height: 30),
              Text("INFO:"+(event.info.infoStr ?? '')),
            ],
          if(event.prices.isNotEmpty)
            ...[
              Container(height: 30),
              Text("Prices:"),
              ...event.prices.map((e) => Text("${e.type}: \$${e.min} - \$${e.max}")),
            ],
          // seatmap image
          if(event.seatmapUrl != null)
            ...[
              Container(height: 30),
              Image.network(event.seatmapUrl!, height: 300),
              Container(height: 30)
            ],
          ElevatedButton(
            onPressed: () {
              if(event.url == null) return;
              Uri uri = Uri.parse(event.url!);
              launchUrl(uri);
            },
            child: const Text('View Event on Ticketmaster'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}