import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
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
                    ...trip.activities.map((activity) => Builder(
                      builder: (context) {
                        bool remove = widget.profiles.every((profile) => activity.participants.contains(profile.id));
                        return Card(
                          child: ListTile(
                              title: Text(activity.event.name),
                              isThreeLine: true,
                              visualDensity: VisualDensity(vertical: 4), // to expand
                              subtitle: Text('${activity.event.venues.firstOrNull?.name}\n${activity.event.startTime.localDate} ${activity.event.startTime.localTime}'),
                              trailing: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await trip.removeActivity(activity);
                                      setState(() {});
                                    },
                                    child: const Text('Remove'),
                                  ),
                                  SizedBox(height: 3),
                                  PopupMenuButton<UserProfile>(
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        PopupMenuItem(
                                          value: UserProfile(id: "id", name: "name", email: "email", hometown: null, numberTrips: 0, joinDate: DateTime.now()),
                                          child: Text("${remove ? "Remove" : "Add"} all", style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        ...widget.profiles.map((UserProfile profile) => PopupMenuItem(
                                        value: profile,
                                        child: Row(
                                          children: [
                                            if(activity.participants.contains(profile.id))
                                              Icon(Icons.check),
                                            if(!activity.participants.contains(profile.id))
                                              Icon(Icons.add),
                                            Text(profile.name),
                                          ],
                                        ),
                                      )).toList()
                                      ];
                                    },
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Participants"),
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5),
                                      )
                                    ),
                                    onSelected: (UserProfile profile) async {
                                      print("Selected $profile");
                                      if(profile.id == "id") {
                                        print("ADD/REMOVE ALL");
                                        for(UserProfile profile in widget.profiles) {
                                          if(!remove && !activity.participants.contains(profile.id)) {
                                            await activity.addParticipant(profile.id);
                                          }
                                          else if(remove && activity.participants.contains(profile.id)) {
                                            await activity.removeParticipant(profile.id);
                                          }
                                        }
                                      }
                                      else {
                                        print("Adding ${profile.name}");
                                        if(activity.participants.contains(profile.id)) {
                                          await activity.removeParticipant(profile.id);
                                        } else {
                                          await activity.addParticipant(profile.id);
                                        }
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            //   trailing: PopupMenuButton<UserProfile?>(
                            //         itemBuilder: (BuildContext context) {
                            //           return [
                            //             const PopupMenuItem(
                            //               child: Text("Add all", style: TextStyle(fontWeight: FontWeight.bold)),
                            //               value: null,
                            //             ),
                            //             ...widget.profiles.map((UserProfile profile) => PopupMenuItem(
                            //             child: Text(profile.name),
                            //             value: profile,
                            //           )).toList()
                            //           ];
                            //         },
                            //         child: Text("Add participants"),
                            //         onSelected: (UserProfile? profile) async {
                            //           if(profile == null) {
                            //             // add all
                          
                            //           }
                            //           else {
                            //             await activity.addParticipant(profile.id);
                            //           }
                            //           setState(() {});
                            //         },
                            //       ),
                            ),
                        );
                      }
                    )).toList(),
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