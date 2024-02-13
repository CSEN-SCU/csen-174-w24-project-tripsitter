import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/api.dart';

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
    return ListView(
      children: events.map((event) => ListTile(
        title: Text(event.name),
        isThreeLine: true,
        subtitle: Text('${event.venues.firstOrNull?.name}\n${event.startTime.localDate} ${event.startTime.localTime}'),
      )).toList(),
    );
  }
}