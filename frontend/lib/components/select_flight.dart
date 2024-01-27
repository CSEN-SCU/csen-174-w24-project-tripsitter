import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/formatters.dart';

class SelectFlight extends StatefulWidget {
  const SelectFlight({super.key});

  @override
  State<SelectFlight> createState() => _SelectFlightState();
}

class _SelectFlightState extends State<SelectFlight> {

  List<FlightItinerary> flights = [];

  List<FlightItinerary> selected = [];

  int currentDepth = 0;

  void selectFlight(FlightItinerary flight) {
    setState(() {
      selected.add(flight);
      currentDepth++;
      flights = flight.next;
    });
  }

  @override
  void initState() {
    super.initState();

    FlightsQuery query = FlightsQuery(
      origin: 'LAX',
      destination: 'SFO',
      departureDate: DateTime(2024, 6, 1),
      returnDate: DateTime(2024, 6, 5),
      adults: 1,
    );
    TripsitterApi.getFlights(query).then((flights) {
      setState(() {
        flights.sort((a,b) => a.duration.compareTo(b.duration));
        this.flights = flights;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Select ${currentDepth == 0 ? "Outbound" : "Return"} Flight"),
        DataTable(
          columns: [
            DataColumn(label: Text("Price/Airline")),
            DataColumn(label: Text("Time")),
            DataColumn(label: Text("Stops")),
          ],
          rows: flights.map((flight) => DataRow(
            onSelectChanged: (bool? selected) {
              if (selected == true) {
                selectFlight(flight);
              }
            },
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${flight.next.isNotEmpty ? "From " : ""}\$${flight.minPrice}"),
                    // Text("Offered by ${flight.offeredBy.toSet().join(", ")}"),
                    Text("Operated by ${flight.segments.map((s) => s.airlineOperating).toSet().join(", ")}"),
                  ],
                ),
              ),
              DataCell(
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat.jm().format(flight.segments.first.departureTime)+" - "+DateFormat.jm().format(flight.segments.last.arrivalTime)),
                      Text(flight.duration.format())
                    ],
                  ),
                ),
              ),
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(flight.segments.length == 1 ? "Nonstop" : "${(flight.segments.length-1).toString()} stop${flight.segments.length > 2 ? "s" : ""}"),
                    // list all segment arrivalIataCodes in all but the first segment
                    flight.segments.length == 1 ? Text("") : Text("Stops in "+flight.segments.sublist(1).map((s) => s.arrivalAirport).join(", ")), 
                  ],
                ),
              ),
            ]
          )).toList(),
        ),
      ],
    );
  }
}