import 'package:flutter/material.dart';
import 'package:tripsitter/components/select_flight.dart';

class ViewTrip extends StatelessWidget {
  final String tripId;
  const ViewTrip(this.tripId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Trip'),
      ),
      body: SingleChildScrollView(child: SelectFlight()),
      // body: Center(
      //   child: Text('You are viewing the trip with ID $tripId'),
      // ),
    );
  }
}