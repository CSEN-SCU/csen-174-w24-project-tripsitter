import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';

class ActivitySummary extends StatelessWidget {
  final Activity activity;
  final double? price;
  const ActivitySummary({required this.activity, required this.price, super.key});

  @override
  Widget build(BuildContext context) {
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    bool split = Provider.of<bool>(context);
    return Column(
      children: [
        Text("${activity.event.name} (${price == null ? "Unknown price" : "\$${price!.toStringAsFixed(2)}"}${split ? "" : " total"})"),
        if(!split)
          Text(activity.participants.map((e) => profiles.firstWhere((profile) => profile.id == e).name).join(", ")),
      ]
    );
  }
}