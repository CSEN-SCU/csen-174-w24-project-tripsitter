import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';

class FlightSummary extends StatelessWidget {
  final FlightGroup flight;
  final double? price;
  const FlightSummary({required this.flight, required this.price, super.key});

  @override
  Widget build(BuildContext context) {
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    bool split = Provider.of<bool>(context);
    return Column(
      children: [
        Text("${flight.departureAirport} -> ${flight.arrivalAirport} (${price == null ? "Unknown price" : "\$${price!.toStringAsFixed(2)}"}${split ? "" : " total"})"),
        if(flight.pnr != null)
          Text("Confirmation number: ${flight.pnr}"),
        if(!split)
          Text(flight.members.map((e) => profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
      ]
    );
  }
}