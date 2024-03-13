// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/trip_center_console.dart';
import 'package:google_fonts/google_fonts.dart';

class TripDashBoard extends StatelessWidget {
  const TripDashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    Color accentColor = Color.fromRGBO(138, 138, 138, 1);
    Trip? trip = Provider.of<Trip?>(context);
    if (trip == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
        color: Color.fromARGB(255, 255, 255, 255),
        width: 75.0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Container(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 20.0),
                      Text(
                        trip.name,
                        style: GoogleFonts.kadwa(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Padding(
                        padding: EdgeInsets.only(top: 3.0),
                        child: Icon(
                          Icons.pin_drop_outlined,
                          size: 26,
                          color: accentColor,
                        ),
                      ),
                      Text(
                        "${trip.destination.name}, ${trip.destination.country}",
                        style: TextStyle(
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                          color: accentColor,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 80.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(25.0),
                                  ),
                                  color: HexColor("#DFE8FF"),
                                ),
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    SizedBox(width: 30.0),
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: Text(
                                        DateFormat('MMM d')
                                            .format(trip.startDate),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 15),
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_double_arrow_right_rounded,
                                      color: Colors.black,
                                      size: 36,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: Text(
                                        DateFormat('MMM d')
                                            .format(trip.endDate),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 15),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: TripCenterConsole(
                  trip,
                  constraints.maxWidth,
                  constraints.maxHeight * 0.9,
                )),
              ],
            );
          },
        ));
  }
}
