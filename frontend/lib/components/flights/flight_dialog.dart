import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/helpers/formatters.dart';

class FlightDialog extends StatelessWidget {
  final FlightItinerary flight;
  const FlightDialog(this.flight, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.all(10), // Adjust padding for overall dialog
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: IntrinsicWidth(
            stepWidth: 300.0, // Minimum width of the content
            child: IntrinsicHeight(
              child: Padding(
                padding:
                    const EdgeInsets.all(20.0), // Padding around the content
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Flight Details",
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold)),
                    ...List.generate(flight.segments.length, (j) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Flight ${j + 1}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              "${flight.segments[j].departure.iataCode} - ${flight.segments[j].arrival.iataCode}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              "Operated by ${Airline.fromCode(flight.segments[j].airlineOperating)?.name ?? flight.segments[j].airlineOperating}"),
                          Text(
                              "${DateFormat.yMMMMd().add_jm().format(flight.segments[j].departure.at)} - ${DateFormat.yMMMMd().add_jm().format(flight.segments[j].arrival.at)}"),
                          Text(
                              "Duration: ${flight.segments[j].duration.toDuration().format()}"),
                          Text(
                              "Aircraft: ${flight.segments[j].aircraft.code.toPlaneName()}"),
                          SizedBox(height: 10),
                          if (j < flight.segments.length - 1) ...[
                            Text(
                                "Layover in ${flight.segments[j + 1].departure.iataCode}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(
                                "Duration: ${flight.segments[j + 1].departure.at.difference(flight.segments[j].arrival.at).format()}"),
                            SizedBox(height: 10),
                          ]
                        ],
                      );
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
