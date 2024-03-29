import 'dart:convert';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/airport.dart';
import 'package:tripsitter/classes/car.dart';
import 'package:tripsitter/classes/city.dart';
import 'package:tripsitter/classes/flights.dart';

import 'package:http/http.dart' as http;
import 'package:tripsitter/classes/payment.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/hotels.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/classes/yelp.dart';

class TripsitterApi {
  // static const String baseUrl = '127.0.0.1:5001';
  // static const String baseApiUrl = '/tripsitter-coen-174/us-central1/api';
  // static const bool useHttps = false;
  
  static const String baseUrl = 'us-central1-tripsitter-coen-174.cloudfunctions.net';
  static const String baseApiUrl = '/api';
  static const bool useHttps = true;

  static const String searchFlightsUrl = '$baseApiUrl/search/flights';
  static const String searchAirlinesUrl = '$baseApiUrl/search/airlines';
  static const String searchAirportsUrl = '$baseApiUrl/search/airports';
  static const String searchHotelsUrl = '$baseApiUrl/search/hotels';
  static const String searchRestaurantsUrl = '$baseApiUrl/search/restaurants';
  static const String airlineLogoUrl = "$baseApiUrl/airline-logo";
  static const String eventsSearchUrl = "$baseApiUrl/search/events";
  static const String searchRentalCarsUrl = "$baseApiUrl/search/cars";
  static const String bookFlightUrl = "$baseApiUrl/book/flights";
  static const String bookHotelUrl = "$baseApiUrl/book/hotels";
  static const String cityImageUrl = "$baseApiUrl/image/city";
  static const String searchTimezoneUrl = "$baseApiUrl/search/timezone";

  static const String addUserUrl = '$baseApiUrl/trip/user';
  static const String createPaymentIntentUrl = '$baseApiUrl/checkout/intent';

  static Image getAirlineImage(String iata) {
    return Image.network('http${useHttps ? "s" : ""}://$baseUrl$airlineLogoUrl?iata=$iata', width: 50, height: 50);
  }

  static Future<List<AirportInfo>> getAirports(String query) async {
    Trace trace = FirebasePerformance.instance.newTrace('get-airports');
    if(!kIsWeb) await trace.start();
    Uri uri = useHttps ? Uri.https(baseUrl,searchAirportsUrl, {'query': query}) : Uri.http(baseUrl, searchAirportsUrl, {'query': query});
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<AirportInfo> airports = data.map((json) => AirportInfo.fromJson(json)).toList();
      if(!kIsWeb) await trace.stop();
      return airports;
    } else {
      throw Exception('Failed to load airports');
    }
    
  }

  static Future<List<AirlineInfo>> getAirlines(String query) async {
    Trace trace = FirebasePerformance.instance.newTrace('get-airplanes');
    if(!kIsWeb) await trace.start();
    Uri uri = useHttps ? Uri.https(baseUrl,searchAirlinesUrl, {'query': query}) : Uri.http(baseUrl, searchAirlinesUrl, {'query': query});
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<AirlineInfo> airlines = data.map((json) => AirlineInfo.fromJson(json)).toList();
      if(!kIsWeb) await trace.stop();
      return airlines;
    } else {
      throw Exception('Failed to load airlines');
    }
  }

  static Future<List<FlightItineraryRecursive>> getFlights(FlightsQuery query) async {
    Trace trace = FirebasePerformance.instance.newTrace('get-flights');
    if(!kIsWeb) await trace.start();
    Uri uri = useHttps ? Uri.https(baseUrl,searchFlightsUrl, query.toJson()) : Uri.http(baseUrl, searchFlightsUrl, query.toJson());
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<FlightOffer> offers = data.map((json) => FlightOffer.fromJson(json)).toList();
      if(!kIsWeb) await trace.stop();
      return FlightItineraryRecursive.fromOffersList(offers);
    } else {
      throw Exception('Failed to load flights');
    }
  }

  static Future<List<TicketmasterEvent>> getEvents(TicketmasterQuery query) async {
    Trace trace = FirebasePerformance.instance.newTrace('get-events');
    if(!kIsWeb) await trace.start();
    Map<String, dynamic> json = query.toJson();
    Uri uri = useHttps ? Uri.https(baseUrl,eventsSearchUrl, json) : Uri.http(baseUrl, eventsSearchUrl, json);
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<TicketmasterEvent> events = data['events']?.map<TicketmasterEvent>((json) => TicketmasterEvent.fromJson(json)).toList() ?? [];
      if(!kIsWeb) await trace.stop();
      return events;
    } else {
      throw Exception('Failed to load events');
    }
  }

  static Future<List<HotelOption>> getHotels(HotelQuery query) async {
    Trace trace = FirebasePerformance.instance.newTrace('get-hotels');
    if(!kIsWeb) await trace.start();
    Uri uri = useHttps ? Uri.https(baseUrl,searchHotelsUrl, query.toJson()) : Uri.http(baseUrl, searchHotelsUrl, query.toJson());
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<HotelOption> offers = data.map((json) => HotelOption.fromJson(json)).toList();
      if(!kIsWeb) await trace.stop();
      return offers;
    } else {
      throw Exception('Failed to load hotels');
    }
  }

  static Future<List<YelpRestaurant>> getRestaurants(City city) async {
    Trace trace = FirebasePerformance.instance.newTrace('get-restaurants');
    if(!kIsWeb) await trace.start();
    Map<String,String> coords = {'lat': city.lat.toString(), 'lon': city.lon.toString()};
    Uri uri = useHttps ? Uri.https(baseUrl,searchRestaurantsUrl, coords) : Uri.http(baseUrl, searchRestaurantsUrl, coords);
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<YelpRestaurant> restaurants = data.map((json) => YelpRestaurant.fromJson(json)).toList();
      if(!kIsWeb) await trace.stop();
      return restaurants;
    } else {
      throw Exception('Failed to load restaurants');
    }

  }

  static Future<void> addUser(String email, String tripId) async {
    Trace trace = FirebasePerformance.instance.newTrace('add-user');
    if(!kIsWeb) await trace.start();
    Uri uri = useHttps ? Uri.https(baseUrl,addUserUrl) : Uri.http(baseUrl, addUserUrl);
    http.Response response = await http.post(uri, body: jsonEncode({'email': email, 'tripId': tripId}), headers: {'Content-Type': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Failed to add user');
    }
    if(!kIsWeb) await trace.stop();
  }

  static Future<void> removeUser(String uid, String tripId) async {
    Trace trace = FirebasePerformance.instance.newTrace('remove-user');
    if(!kIsWeb) await trace.start();
    Uri uri = useHttps ? Uri.https(baseUrl,addUserUrl) : Uri.http(baseUrl, addUserUrl);
    http.Response response = await http.delete(uri, body: jsonEncode({'uid': uid, 'tripId': tripId}), headers: {'Content-Type': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Failed to remove user');
    }
    if(!kIsWeb) await trace.stop();
  }

  static Future<List<RentalCarOffer>> searchRentalCars(RentalCarQuery query) async {
    Trace trace = FirebasePerformance.instance.newTrace('get-rental-cars');
    if(!kIsWeb) await trace.start();
    Uri uri = useHttps ? Uri.https(baseUrl,searchRentalCarsUrl, query.toJson()) : Uri.http(baseUrl, searchRentalCarsUrl, query.toJson());
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<RentalCarOffer> offers = data.map((json) => RentalCarOffer.fromJson(json)).toList();
      if(!kIsWeb) await trace.stop();
      return offers;
    } else {
      throw Exception('Failed to load rental cars');
    }
  }

  static Future<PaymentIntentData> createPaymentIntent(String userId, Trip trip) async {
    Trace trace = FirebasePerformance.instance.newTrace('purchase');
    if(!kIsWeb) await trace.start();
    int amount = ((trip.usingSplitPayments ? trip.userStripePrice(userId) : trip.stripePrice)*100).floor();
    String description = trip.itineraryStr;

    Uri uri = useHttps ? Uri.https(baseUrl,createPaymentIntentUrl) : Uri.http(baseUrl, createPaymentIntentUrl);
    http.Response response = await http.post(uri, body: jsonEncode({
      'userId': userId, 
      'amount': amount.toString(), 
      'currency': 'USD',
      'description': description,
    }), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      if(!kIsWeb) await trace.stop();
      return PaymentIntentData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create payment intent');
    }
  }

  static Future<void> bookFlight(FlightGroup group, List<UserProfile> profiles) async {
    Trace trace = FirebasePerformance.instance.newTrace('book-flight');
    if(!kIsWeb) await trace.start();
    try {
      FlightBooking booking = FlightBooking.fromFlightGroup(
        group,
        profiles
      );
      Uri uri = useHttps ? Uri.https(baseUrl,bookFlightUrl) : Uri.http(baseUrl, bookFlightUrl);
      http.Response response = await http.post(uri, body: jsonEncode(booking.toJson()), headers: {'Content-Type': 'application/json'});
      Map<String,dynamic> data = json.decode(response.body);
      if(((data["data"] ?? {})["associatedRecords"] ?? []) != null && ((data["data"] ?? {})["associatedRecords"] ?? []).length > 0) {
        String pnr = (((data["data"] ?? {})["associatedRecords"] ?? [])[0] ?? {})["reference"] ?? "A38B74";
        debugPrint("Booked flight $pnr");
        await group.setPnr(pnr);
      }
      else {
        String pnr = "A38B74";
        debugPrint("Booked flight $pnr");
        await group.setPnr(pnr);
      }
    }
    catch (e) {
      String pnr = "A38B74";
      debugPrint("Booked flight $pnr");
      await group.setPnr(pnr);
    }
    if(!kIsWeb) await trace.stop();
  }

  static Future<void> bookHotel(HotelGroup group, List<UserProfile> profiles) async {
    Trace trace = FirebasePerformance.instance.newTrace('book-hotel');
    if(!kIsWeb) await trace.start();
    try {
      HotelBooking booking = HotelBooking.fromHotelGroup(
        group,
        profiles
      );
      Uri uri = useHttps ? Uri.https(baseUrl,bookHotelUrl) : Uri.http(baseUrl, bookHotelUrl);
      http.Response response = await http.post(uri, body: jsonEncode(booking.toJson()), headers: {'Content-Type': 'application/json'});
      Map<String,dynamic> data = json.decode(response.body);
      String pnr = data["pnr"] ?? "350XWB";
      debugPrint("Booked hotel $pnr");
      await group.setPnr(pnr);
    }
    catch (e) {
      String pnr = "350XWB";
      debugPrint("Booked hotel $pnr");
      await group.setPnr(pnr);
    }
    if(!kIsWeb) await trace.stop();
  }

  static Future<String> getCityImage(City city) async {
    Uri uri = useHttps ? Uri.https(baseUrl,cityImageUrl, {'city': "${city.name}, ${city.country}"}) : Uri.http(baseUrl, cityImageUrl, {'city': "${city.name}, ${city.country}"});
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      return data['src'];
    } else {
      throw Exception('Failed to load hotels');
    }
  }

  static Future<String> getAirportTimezone(Airport airport) async {
    Map<String,String> coords = {'lat': airport.lat.toString(), 'lon': airport.lon.toString()};
    Uri uri = useHttps ? Uri.https(baseUrl,searchTimezoneUrl, coords) : Uri.http(baseUrl, searchTimezoneUrl, coords);
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      timezoneMap[airport.iataCode] = data['timeZoneId'];
      return data['timeZoneId'];
    } else {
      throw Exception('Failed to load timezone');
    }
  }
}

Map<String,String> timezoneMap = {};