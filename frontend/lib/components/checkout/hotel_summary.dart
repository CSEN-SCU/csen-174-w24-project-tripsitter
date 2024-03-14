import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';

class HotelSummary extends StatelessWidget {
  final HotelGroup hotel;
  final double? price;
  const HotelSummary({required this.hotel, required this.price, super.key});

  @override
  Widget build(BuildContext context) {
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    bool split = Provider.of<bool>(context);
    return Column(
      children: [
        Text("${hotel.name} (${price == null ? "Unknown price" : "\$${price!.toStringAsFixed(2)}"}${split ? "" : " total"})"),
        if(hotel.pnr != null)
          Text("Confirmation Number: ${hotel.pnr}"),
        if(!split)
          Text(hotel.members.map((e) => profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
      ]
    );
  }
}