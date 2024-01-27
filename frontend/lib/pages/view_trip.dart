import 'package:flutter/material.dart';
import 'package:tripsitter/components/map.dart';

class ViewTrip extends StatelessWidget {
  final String tripId;
  const ViewTrip(this.tripId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Trip'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('You are viewing the trip with ID $tripId'),

            SizedBox(
              height: 500,
              child: TripsitterMap()
            ),
          ],
        ),
      ),
    );
  }
}