import 'package:flutter/material.dart';
import 'package:tripsitter/components/select_flight.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/components/navbar.dart';
import 'package:tripsitter/components/trip_dash.dart';

class ViewTrip extends StatelessWidget {
  final String tripId;
  const ViewTrip(this.tripId, {super.key});

  @override
  Widget build(BuildContext context) {
    print("TRIP $tripId");
    return Scaffold(
      appBar: const TripSitterNavbar(),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Container(
          color: const Color.fromRGBO(232, 232, 232, 1),
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: TripDashBoard(),
                  width: constraints.maxWidth * 0.8,
                ),
                Container(
                  color: Color.fromARGB(255, 127, 166, 198),
                  width: constraints.maxWidth * 0.2,
                  child: const Center(
                    child: Text('Right Side'),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
