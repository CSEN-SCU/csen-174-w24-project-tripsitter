import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/map.dart';
import 'package:tripsitter/components/select_flight.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/components/navbar.dart';
import 'package:tripsitter/components/trip_dash.dart';
import 'package:tripsitter/components/trip_side_column.dart';
import 'package:tripsitter/pages/login.dart';

class ViewTrip extends StatelessWidget {
  final String tripId;
  const ViewTrip(this.tripId, {super.key});

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);
    if(user == null) {
      return const LoginPage();
    }
    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: Trip.getTripById(tripId),
          initialData: null,
        ),
      ],
      child: Scaffold(
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
                    width: constraints.maxWidth * 0.7,
                  ),
                  Container(
                    color: Color.fromARGB(255, 127, 166, 198),
                    width: constraints.maxWidth * 0.3,
                    child: TripSideColumn()
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
