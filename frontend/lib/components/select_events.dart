import 'package:flutter/material.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/helpers/api.dart';

class SelectEvents extends StatefulWidget {
  const SelectEvents({super.key});

  @override
  State<SelectEvents> createState() => _SelectEventsState();
}

class _SelectEventsState extends State<SelectEvents> {
  List<TicketmasterEvent> events = [];
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEvents();
  }

  Future<void> getEvents() async {
    List<TicketmasterEvent> call = await TripsitterApi.getEvents(TicketmasterQuery(
      query: "Rockies",
      lat: 37.7749,
      long: -122.4194,
      startDateTime: DateTime.now(),
      endDateTime: DateTime.now().add(Duration(days: 30)),
    ));

    setState(() {
      events = call;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: events.map((event) => ListTile(
          title: Text(event.name),
          isThreeLine: true,
          subtitle: Text('${event.venues.firstOrNull?.name}\n${event.startTime.localDate} ${event.startTime.localTime}'),
        )).toList(),
      ),
    );
  }
}