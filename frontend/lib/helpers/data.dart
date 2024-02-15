import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/airport.dart';
import 'package:tripsitter/classes/city.dart';

List<City>? _citiesCache = null;

Future<void> _loadCities(BuildContext context) async {
    var result = await DefaultAssetBundle.of(context).loadString(
    "assets/worldcities.csv",
    );
    List<List<dynamic>> list = CsvToListConverter().convert(result, eol: "\n");
    list.removeAt(0);
    _citiesCache = list.map((e) => City.fromArray(e)).toList();
}

Future<List<City>> getCities(BuildContext context) async {
  if (_citiesCache == null) {
    await _loadCities(context);
  }
  return _citiesCache ?? [];
}

List<Airport>? _airportsCache = null;

Future<void> _loadAmadeusAirports(BuildContext context) async {
  var result = await DefaultAssetBundle.of(context).loadString(
    "assets/airports.csv",
  );
  List<List<dynamic>> list = CsvToListConverter().convert(result, eol: "\n");
  list.removeAt(0);
  _airportsCache = list.map((e) => Airport.fromArray(e)).toList();
}

Future<List<Airport>> getAirports(BuildContext context) async {
  if (_airportsCache == null) {
    await _loadAmadeusAirports(context);
  }
  return _airportsCache ?? [];
}
