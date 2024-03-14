import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/helpers/formatters.dart';

class FlightDialog extends StatelessWidget {
  final FlightItineraryRecursive flight;
  const FlightDialog(this.flight,{super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Flight Details"),
      content: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          for (int j = 0; j < flight.segments.length; j++) ...[
            Text("Flight ${j + 1}"),
            Text(
                "${flight.segments[j].departure.iataCode} - ${flight.segments[j].arrival.iataCode}"),
            Text(
                "Operated by ${Airline.fromCode(flight.segments[j].airlineOperating)?.name ?? flight.segments[j].airlineOperating}"),
            Text(
                "${DateFormat.yMMMMd().add_jm().format(flight.segments[j].departure.at)} - ${DateFormat.yMMMMd().add_jm().format(flight.segments[j].departure.at)}"),
            Text(
                "Duration: ${flight.segments[j].duration.toDuration().format()}"),
            Text(
                "Aircraft: ${flight.segments[j].aircraft.code.toPlaneName()}"),
            Container(height: 10),
            if (j < flight.segments.length - 1) ...[
              Text(
                  "Layover in ${flight.segments[j + 1].departure.iataCode}"),
              Text(
                  "Duration: ${flight.segments[j + 1].departure.at.difference(flight.segments[j].arrival.at).format()}"),
              Container(height: 10),
            ]
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        )
      ],
    );
  }
}