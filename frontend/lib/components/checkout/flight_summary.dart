import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/styles.dart';

class FlightSummary extends StatelessWidget {
  final FlightGroup flight;
  final double? price;
  const FlightSummary({required this.flight, required this.price, super.key});

  @override
  Widget build(BuildContext context) {
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    bool split = Provider.of<bool>(context);
    if (flight.selected == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    "${flight.departureAirport} → ${flight.arrivalAirport}${flight.pnr != null ? " (Confirmation: ${flight.pnr})" : ""}",
                    style: summaryHeaderStyle),
                Row(
                    children: flight.selected?.itineraries
                            .map((itinerary) => Expanded(
                                child: FlightItinerarySummary(itinerary, true)))
                            .toList() ??
                        [])
              ]),
        ),
        if (!split)
          Expanded(
              flex: 1,
              child: Column(
                children: flight.members
                    .map((e) =>
                        profiles
                            .firstWhereOrNull((profile) => profile.id == e)
                            ?.name ??
                        "")
                    .map((e) => Text(e))
                    .toList(),
              )),
        SizedBox(
          width: 130,
          child: Center(
              child: Text(price == null
                  ? "Unknown price"
                  : "\$${price!.toStringAsFixed(2)}")),
        )
      ]),
    );
  }
}

class FlightItinerarySummary extends StatelessWidget {
  final DateFormat dateFormatter = DateFormat("E, MMM d, y");
  final DateFormat timeFormatter = DateFormat("h:mm a");
  final FlightItinerary it;
  final bool displayPlanes;
  FlightItinerarySummary(this.it, this.displayPlanes, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateFormatter.format(it.segments.first.departure.at)),
          Text(
              "${timeFormatter.format(it.segments.first.departure.at)} - ${timeFormatter.format(it.segments.last.arrival.at)}${(it.segments.first.departure.at.day != it.segments.last.arrival.at.day || it.segments.first.departure.at.year != it.segments.last.arrival.at.year || it.segments.first.departure.at.month != it.segments.last.arrival.at.month) ? " (+1)" : ""}"),
          if (displayPlanes)
            Text(it.segments
                .map((e) =>
                    "${Airline.fromCode(e.carrierCode)?.name ?? e.carrierCode} ${e.number}")
                .join(", "))
          else
            Text(it.segments
                .map((e) =>
                    Airline.fromCode(e.carrierCode)?.name ?? e.carrierCode)
                .toSet()
                .join(", "))
        ],
      ),
    );
  }
}
