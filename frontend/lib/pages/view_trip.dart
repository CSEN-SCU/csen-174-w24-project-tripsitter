import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/components/trip_dash.dart';

class ViewTrip extends StatelessWidget {
  final String tripId;
  const ViewTrip(this.tripId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TripSitter',
          style: GoogleFonts.kadwa(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset('tripsitter_logo.png'),
        ),
        backgroundColor: HexColor("#C6D6FF"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Set the height of the border
          child: Container(
            color: const Color.fromARGB(
                255, 128, 128, 128), // Set the color of the border
            height: 1.0, // Set the height of the border
          ),
        ),
      ),
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
