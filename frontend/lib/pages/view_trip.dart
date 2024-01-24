import 'package:flutter/material.dart';

class ViewTrip extends StatelessWidget {
  final String tripId;
  const ViewTrip(this.tripId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Another page'),
      ),
      body: Center(
        child: Text('You are viewing the trip with ID $tripId'),
      ),
    );
  }
}