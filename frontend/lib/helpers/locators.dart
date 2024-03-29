import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/airport.dart';
import 'package:tripsitter/classes/city.dart';
import 'package:tripsitter/helpers/data.dart';

Future<Airport> getNearestAirport(City city, BuildContext context) async {
  List<Airport> airports = await getAirports(context);
  airports = airports.where((element) => element.scale < 6).toList();
  airports.sort((a, b) {
    double aDist = distance(city.lat, city.lon, a.lat, a.lon);
    double bDist = distance(city.lat, city.lon, b.lat, b.lon);
    return aDist.compareTo(bDist);
  });
  return airports.first;
}

Future<List<Airport>> getNearbyAirports(String code, BuildContext context) async {
  List<Airport> airports = await getAirports(context);

  Airport? a = airports.firstWhereOrNull((element) => element.iataCode == code);
  if(a == null) {return [];}
  return airports.where((b) => distance(a.lat, a.lon, b.lat, b.lon) < 100).toList();
}

// returns distance in miles
double distance(double lat1, double lon1, double lat2, double lon2) {
  double R = 3958.8; // radius in miles
  double dLat = toRad(lat2 - lat1);
  double dLon = toRad(lon2 - lon1);
  double l1 = toRad(lat1);
  double l2 = toRad(lat2);

  var a = sin(dLat / 2) * sin(dLat / 2) +
      sin(dLon / 2) * sin(dLon / 2) * cos(l1) * cos(l2);
  var c = 2 * atan2(sqrt(a), sqrt(1 - a));
  var d = R * c;
  return d;
}

double toRad(double value) {
  return value * pi / 180;
}
