import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tripsitter/classes/flights.dart';

import 'package:http/http.dart' as http;
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/hotels.dart';

class TripsitterApi {
  static const String baseUrl = '127.0.0.1:5001';
  static const String baseApiUrl = '/tripsitter-coen-174/us-central1/api';
  static const String searchFlightsUrl = '$baseApiUrl/search/flights';
  static const String searchAirlinesUrl = '$baseApiUrl/search/airlines';
  static const String searchAirportsUrl = '$baseApiUrl/search/airports';
  static const String searchHotelsUrl = '$baseApiUrl/search/hotels';
  static const String airlineLogoUrl = "$baseApiUrl/airline-logo";
  static const String eventsSearchUrl = "$baseApiUrl/search/events";

  static const String addUserUrl = '$baseApiUrl/trip/user';

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

  static Future<List<FlightItineraryRecursive>> getFlights(FlightsQuery query) async {
    Uri uri = Uri.http(baseUrl, searchFlightsUrl, query.toJson());
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<FlightOffer> offers = data.map((json) => FlightOffer.fromJson(json)).toList();
      return FlightItineraryRecursive.fromOffersList(offers);
    } else {
      throw Exception('Failed to load flights');
    }
  }

  static Future<List<TicketmasterEvent>> getEvents(TicketmasterQuery query) async {
    Map<String, dynamic> json = query.toJson();
    Uri uri = Uri.http(baseUrl, eventsSearchUrl, json);
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<TicketmasterEvent> events = data['events']?.map<TicketmasterEvent>((json) => TicketmasterEvent.fromJson(json)).toList() ?? [];
      return events;
    } else {
      throw Exception('Failed to load events');
    }
  }

  static Future<List<HotelOption>> getHotels(HotelQuery query) async {
    print( query.toJson());
    Uri uri = Uri.http(baseUrl, searchHotelsUrl, query.toJson());
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<HotelOption> offers = data.map((json) => HotelOption.fromJson(json)).toList();
      return offers;
    } else {
      throw Exception('Failed to load hotels');
    }
  }

  static Future<void> addUser(String email, String tripId) async {
    Uri uri = Uri.http(baseUrl, addUserUrl);
    http.Response response = await http.post(uri, body: jsonEncode({'email': email, 'tripId': tripId}), headers: {'Content-Type': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Failed to add user');
    }
  }

  static Future<void> removeUser(String uid, String tripId) async {
    Uri uri = Uri.http(baseUrl, addUserUrl);
    http.Response response = await http.delete(uri, body: jsonEncode({'uid': uid, 'tripId': tripId}), headers: {'Content-Type': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Failed to remove user');
    }
  }
}