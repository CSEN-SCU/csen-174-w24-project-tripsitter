

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tripsitter/classes/flights.dart';

import 'package:http/http.dart' as http;

class TripsitterApi {
  static const String baseUrl = '127.0.0.1:5001';
  static const String baseApiUrl = '/tripsitter-coen-174/us-central1/api';
  static const String searchFlightsUrl = '$baseApiUrl/search/flights';
  static const String searchAirlinesUrl = '$baseApiUrl/search/airlines';
  static const String searchAirportsUrl = '$baseApiUrl/search/airports';
  static const String airlineLogoUrl = "$baseApiUrl/airline-logo";

  static Image getAirlineImage(String iata) {
    return Image.network('http://$baseUrl$airlineLogoUrl?iata=$iata', width: 50, height: 50);
  }

  static Future<List<AirportInfo>> getAirports(String query) async {
    Uri uri = Uri.http(baseUrl, searchAirportsUrl, {'query': query});
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<AirportInfo> airports = data.map((json) => AirportInfo.fromJson(json)).toList();
      return airports;
    } else {
      throw Exception('Failed to load airports');
    }
  }

  static Future<List<AirlineInfo>> getAirlines(String query) async {
    Uri uri = Uri.http(baseUrl, searchAirlinesUrl, {'query': query});
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<AirlineInfo> airlines = data.map((json) => AirlineInfo.fromJson(json)).toList();
      return airlines;
    } else {
      throw Exception('Failed to load airlines');
    }
  }

  static Future<List<FlightItinerary>> getFlights(FlightsQuery query) async {
    Uri uri = Uri.http(baseUrl, searchFlightsUrl, query.toJson());
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<FlightItinerary> flights = data.map((json) => FlightItinerary.fromJson(json)).toList();
      return flights;
    } else {
      throw Exception('Failed to load flights');
    }
  }


}