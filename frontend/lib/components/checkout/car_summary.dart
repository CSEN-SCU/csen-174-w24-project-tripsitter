import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';

class CarSummary extends StatelessWidget {
  final RentalCarGroup rentalCar;
  final double? price;
  const CarSummary({required this.rentalCar, required this.price, super.key});

  @override
  Widget build(BuildContext context) {
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    bool split = Provider.of<bool>(context);
    return Column(
      children: [
        Text("${rentalCar.name} (${price == null ? "Unknown price" : "\$${price!.toStringAsFixed(2)}"}${split ? "" : " total"})"),
        if(!split)
          Text(rentalCar.members.map((e) => profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
      ]
    );
  }
}