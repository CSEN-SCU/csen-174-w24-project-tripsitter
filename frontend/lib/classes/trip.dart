import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/city.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/classes/hotels.dart';

class Trip {
  final String _id;
  final List<String> _uids;
  final Map<String, double> _prices;
  double _totalPrice;
  String _name;
  DateTime _startDate;
  DateTime _endDate;
  City _destination;
  bool _isConfirmed;
  List<FlightGroup> _flights;
  List<HotelGroup> _hotels;
  List<RentalCarGroup> _rentalCars;
  List<ActivitySelection> _activities;

  Trip({
    required String id,
    required List<String> uids,
    required Map<String, double> prices,
    required double totalPrice,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required City destination,
    required bool isConfirmed,
    required List<FlightGroup> flights,
    required List<HotelGroup> hotels,
    required List<RentalCarGroup> rentalCars,
    required List<ActivitySelection> activities,
  }) : _id = id,
       _uids = uids,
       _prices = prices,
       _totalPrice = totalPrice,
       _name = name,
       _startDate = startDate,
       _endDate = endDate,
       _destination = destination,
       _isConfirmed = isConfirmed,
       _flights = flights,
       _hotels = hotels,
       _rentalCars = rentalCars,
       _activities = activities;
  
  String get id => _id;
  List<String> get uids => _uids;
  Map<String, double> get prices => _prices;
  double get totalPrice => _totalPrice;
  String get name => _name;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  City get destination => _destination;
  bool get isConfirmed => _isConfirmed;
  List<FlightGroup> get flights => _flights;
  List<HotelGroup> get hotels => _hotels;
  List<RentalCarGroup> get rentalCars => _rentalCars;
  List<ActivitySelection> get activities => _activities;

  Future<void> save() async {
    await _save();
  }

  Future<void> _save() async {
    await FirebaseFirestore.instance.collection("trips").doc(_id).set({
      "uids": _uids,
      "prices": _prices,
      "totalPrice": _totalPrice,
      "name": _name,
      "startDate": _startDate,
      "endDate": _endDate,
      "destination": _destination.toJson(),
      "isConfirmed": _isConfirmed,
      "flights": _flights.map((flight) => flight.toJson()).toList(),
      "hotels": _hotels.map((hotel) => hotel.toJson()).toList(),
      "rentalCars": _rentalCars.map((rentalCar) => rentalCar.toJson()).toList(),
      "activities": _activities.map((activity) => activity.toJson()).toList(),
    });
  }

  static Stream<Trip> getTripById(String id) {
    return FirebaseFirestore.instance.collection("trips").doc(id).snapshots().map((doc) => Trip.fromFirestore(doc));
  }

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    Trip t = Trip(
      id: doc.id,
      uids: (data['uids'] as List).map((item) => item as String).toList(),
      prices: Map<String,double>.from(data['prices']),
      totalPrice: data['totalPrice'],
      name: data['name'],
      startDate: data['startDate'].toDate(),
      endDate: data['endDate'].toDate(),
      destination: City.fromJson(data['destination']),
      isConfirmed: data['isConfirmed'],
      flights: [],
      hotels: [],
      rentalCars: [],
      activities: [],
    );

    t._flights = (data['flights'] as List).map((flight) => FlightGroup.fromJson(flight, t._save)).toList();
    t._hotels = (data['hotels'] as List).map((hotel) => HotelGroup.fromJson(hotel, t._save)).toList();
    t._rentalCars = (data['rentalCars'] as List).map((rentalCar) => RentalCarGroup.fromJson(rentalCar, t._save)).toList();
    t._activities = (data['activities'] as List).map((activity) => ActivitySelection.fromJson(activity)).toList();

    return t;
  }

  Future<void> addFlightGroup(FlightGroup flight) async {
    _flights.add(flight);
    await _save();
  }

  Future<void> removeFlightGroup(FlightGroup flight) async {
    _flights.remove(flight);
    await _save();
  }

  Future<void> addHotelGroup(HotelGroup hotel) async {
    _hotels.add(hotel);
    await _save();
  }

  Future<void> removeHotelGroup(HotelGroup hotel) async {
    _hotels.remove(hotel);
    await _save();
  }

  Future<void> addRentalCarGroup(RentalCarGroup rentalCar) async {
    _rentalCars.add(rentalCar);
    await _save();
  }

  Future<void> removeRentalCarGroup(RentalCarGroup rentalCar) async {
    _rentalCars.remove(rentalCar);
    await _save();
  }

  Future<void> addActivity(ActivitySelection activity) async {
    _activities.add(activity);
    await _save();
  }

  Future<void> removeActivity(ActivitySelection activity) async {
    _activities.remove(activity);
    await _save();
  }

  Future<void> addUser(String uid) async {
    _uids.add(uid);
    await _save();
  }

  Future<void> removeUser(String uid) async {
    _uids.remove(uid);
    await _save();
  }

  Future<void> changeStartDate(DateTime date) async {
    _startDate = date;
    await _save();
  }

  Future<void> changeEndDate(DateTime date) async {
    _endDate = date;
    await _save();
  }

  Future<void> changeDestination(City destination) async {
    _destination = destination;
    await _save();
  }

  Future<void> bookTrip() async {
    _isConfirmed = true;
    await _save();
  }

}

class FlightGroup {
  List<String> _members;
  String _departureAirport;
  String _arrivalAirport;
  List<FlightOffer> _options;
  FlightOffer? _selected;
  Future<void> Function() _save;

  FlightGroup({
    required List<String> members,
    required String departureAirport,
    required String arrivalAirport,
    required List<FlightOffer> options,
    FlightOffer? selected,
    required Future<void> Function() save,
  }) : _members = members,
       _departureAirport = departureAirport,
       _arrivalAirport = arrivalAirport,
       _options = options,
       _selected = selected,
       _save = save;

  factory FlightGroup.fromJson(Map<String, dynamic> json, Future<void> Function() save) {
    return FlightGroup(
      save: save,
      members: json['members'],
      departureAirport: json['departureAirport'],
      arrivalAirport: json['arrivalAirport'],
      options: (json['options'] as List).map((option) => FlightOffer.fromJson(option)).toList(),
      selected: json['selected'] != null ? FlightOffer.fromJson(json['selected']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "members": _members,
      "departureAirport": _departureAirport,
      "arrivalAirport": _arrivalAirport,
      "options": _options.map((option) => option.toJson()).toList(),
      "selected": _selected?.toJson(),
    };
  }

  List<String> get members => _members;
  String get departureAirport => _departureAirport;
  String get arrivalAirport => _arrivalAirport;
  List<FlightOffer> get options => _options;
  FlightOffer? get selected => _selected;

  Future<void> selectOption(FlightOffer option) async {
    _selected = option;
    await _save();
  }

  Future<void> addOption(FlightOffer option) async {
    _options.add(option);
    await _save();
  }

  Future<void> removeOption(FlightOffer option) async {
    _options.remove(option);
    await _save();
  }

  Future<void> addMember(String member) async {
    _members.add(member);
    await _save();
  }

  Future<void> removeMember(String member) async {
    _members.remove(member);
    await _save();
  }

  Future<void> setDepartureAirport(String airport) async {
    _departureAirport = airport;
    await _save();
  }

  Future<void> setArrivalAirport(String airport) async {
    _arrivalAirport = airport;
    await _save();
  }
}

class HotelGroup {
  List<String> _members;
  List<HotelOffer> _options;
  HotelOffer? _selected;
  Future<void> Function() _save;

  HotelGroup({
    required members,
    required options,
    selected,
    required Future<void> Function() save,
  }) : 
    _save = save,
    _members = members,
    _options = options,
    _selected = selected;

  factory HotelGroup.fromJson(Map<String, dynamic> json, Future<void> Function() save) {
    return HotelGroup(
      members: json['members'],
      options: (json['options'] as List).map((option) => HotelOffer.fromJson(option)).toList(),
      selected: json['selected'] != null ? HotelOffer.fromJson(json['selected']) : null,
      save: save
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "members": _members,
      "options": _options.map((option) => option.toJson()).toList(),
      "selected": _selected?.toJson(),
    };
  }

  Future<void> selectOption(HotelOffer option) async {
    _selected = option;
    await _save();
  }
  Future<void> addOption(HotelOffer option) async {
    _options.add(option);
    await _save();
  }
  Future<void> removeOption(HotelOffer option) async {
    _options.remove(option);
    await _save();
  }
  Future<void> addMember(String member) async {
    _members.add(member);
    await _save();
  }
  Future<void> removeMember(String member) async {
    _members.remove(member);
    await _save();
  }
}

class RentalCarGroup {
  List<String> _members;
  List<RentalCarOffer> _options;
  RentalCarOffer? _selected;
  Future<void> Function() _save;

  RentalCarGroup({
    required members,
    required options,
    selected,
    required Future<void> Function() save,
  }) : 
    _save = save,
    _members = members,
    _options = options,
    _selected = selected;

  factory RentalCarGroup.fromJson(Map<String, dynamic> json, Future<void> Function() save) {
    return RentalCarGroup(
      members: json['members'],
      options: (json['options'] as List).map((option) => RentalCarOffer.fromJson(option)).toList(),
      selected: json['selected'] != null ? RentalCarOffer.fromJson(json['selected']) : null,
      save: save
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "members": _members,
      "options": _options.map((option) => option.toJson()).toList(),
      "selected": _selected?.toJson(),
    };
  }

  Future<void> selectOption(RentalCarOffer option) async {
    _selected = option;
    await _save();
  }
  Future<void> addOption(RentalCarOffer option) async {
    _options.add(option);
    await _save();
  }
  Future<void> removeOption(RentalCarOffer option) async {
    _options.remove(option);
    await _save();
  }
  Future<void> addMember(String member) async {
    _members.add(member);
    await _save();
  }
  Future<void> removeMember(String member) async {
    _members.remove(member);
    await _save();
  }
}

class RentalCarOffer {
  RentalCarOffer();

  factory RentalCarOffer.fromJson(Map<String, dynamic> json) {
    return RentalCarOffer();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

class ActivitySelection {
  double _price;
  String _id;
  String _name;

  ActivitySelection({
    required price,
    required id,
    required name,
  }) : 
    _price = price,
    _id = id,
    _name = name;

  factory ActivitySelection.fromJson(Map<String, dynamic> json) {
    return ActivitySelection(
      price: json['price'],
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "price": _price,
      "id": _id,
      "name": _name,
    };
  }

  double get price => _price;
  String get id => _id;
  String get name => _name;
}