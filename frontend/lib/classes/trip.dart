import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/car.dart';
import 'package:tripsitter/classes/city.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/classes/hotels.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'dart:async';

class Trip {
  final String _id;
  final List<String> _uids;
  final Map<String, double> _prices;
  String _name;
  DateTime _startDate;
  DateTime _endDate;
  City _destination;
  bool _isConfirmed;
  List<FlightGroup> _flights;
  List<HotelGroup> _hotels;
  List<RentalCarGroup> _rentalCars;
  List<Activity> _activities;

  Trip({
    required String id,
    required List<String> uids,
    required Map<String, double> prices,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required City destination,
    required bool isConfirmed,
    required List<FlightGroup> flights,
    required List<HotelGroup> hotels,
    required List<RentalCarGroup> rentalCars,
    required List<Activity> activities,
  }) : _id = id,
       _uids = uids,
       _prices = prices,
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
  String get name => _name;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  City get destination => _destination;
  bool get isConfirmed => _isConfirmed;
  List<FlightGroup> get flights => _flights;
  List<HotelGroup> get hotels => _hotels;
  List<RentalCarGroup> get rentalCars => _rentalCars;
  List<Activity> get activities => _activities;

  double get totalPrice {
    return flightsPrice + hotelsPrice + rentalCarsPrice + activitiesPrice;
  }

  double get flightsPrice {
    double total = 0;
    for(FlightGroup group in _flights) {
      if(group.price != null) {
        total += group.price!;
      }
    }
    return total;
  }

  double get hotelsPrice {
    double total = 0;
    for(HotelGroup group in _hotels) {
      if(group.price != null) {
        total += group.price!;
      }
    }
    return total;
  }

  double get rentalCarsPrice {
    double total = 0;
    for(RentalCarGroup group in _rentalCars) {
      total += group.price;
    }
    return total;
  }

  double get activitiesPrice {
    double total = 0;
    for(Activity activity in _activities) {
      if(activity.price != null) {
        total += activity.price!;
      }
    }
    return total;
  }

  String get itineraryStr {
    List<String> lines = [];

    lines.add(_name);
    lines.add("${DateFormat("MM/dd/yyyy").format(_startDate)} - ${DateFormat("MM/dd/yyyy").format(_endDate)}");
    lines.add("${_destination.name}, ${_destination.country}");

    return lines.join("\n");
  }

  Future<void> save() async {
    await _save();
  }

  Map<String,dynamic> toJson() {
    return {
      "uids": _uids,
      "prices": _prices,
      "name": _name,
      "startDate": _startDate,
      "endDate": _endDate,
      "destination": _destination.toJson(),
      "isConfirmed": _isConfirmed,
      "flights": _flights.map((flight) => flight.toJson()).toList(),
      "hotels": _hotels.map((hotel) => hotel.toJson()).toList(),
      "rentalCars": _rentalCars.map((rentalCar) => rentalCar.toJson()).toList(),
      "activities": _activities.map((activity) => activity.toJson()).toList(),
    };
  }

  Future<void> _save() async {
    await FirebaseFirestore.instance.collection("trips").doc(_id).set(toJson());
  }
  static Stream<List<Trip>> getTripsByProfile(String uid) {
    return FirebaseFirestore.instance.collection('trips').where('uids', arrayContains: uid).snapshots().map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
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
    t._activities = (data['activities'] as List).map((activity) => Activity.fromJson(activity, t._save)).toList();

    return t;
  }

  Future<void> addFlightGroup(String departureAirport, String arrivalAirport, List<String> members) async {
    _flights.add(FlightGroup(
      members: members,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      options: [],
      selected: null,
      save: _save,
    ));
    await _save();
  }

  Future<void> removeFlightGroup(FlightGroup flight) async {
    _flights.remove(flight);
    await _save();
  }

  Future<HotelGroup> createHotelGroup(String name, List<String> members) async {
    HotelGroup hotel = HotelGroup(name: name, members: members, offers: List<HotelOffer>.empty(growable: true), infos: List<HotelInfo>.empty(growable: true), save: save);
    _hotels.add(hotel);
    await _save();
    return hotel;
  }

  Future<void> removeHotelGroup(HotelGroup hotel) async {
    _hotels.remove(hotel);
    await _save();
  }

  Future<RentalCarGroup> createRentalCarGroup(String name, List<String> members) async {
    RentalCarGroup rentalCar = RentalCarGroup(name: name, members: members, options: List<RentalCarOffer>.empty(growable: true), save: save);
    _rentalCars.add(rentalCar);
    await _save();
    return rentalCar;
  }

  Future<void> removeRentalCarGroup(RentalCarGroup rentalCar) async {
    _rentalCars.remove(rentalCar);
    await _save();
  }

  Future<void> addActivity(TicketmasterEvent event, List<String> uids) async {
    _activities.add(Activity(
      event: event,
      participants: uids,
      save: _save,
    ));
    await _save();
  }

  Future<void> removeActivity(Activity activity) async {
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

  double? get price {
    if(_selected == null) return 0;
    return double.tryParse(_selected!.price.total);
  }

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
      members: (json['members'] as List).map((e) => e as String).toList(),
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
  List<HotelInfo> _infos;
  List<HotelOffer> _offers;
  String _name;
  HotelOffer? _selectedOffer;
  HotelInfo? _selectedInfo;
  Future<void> Function() _save;

  double? get price {
    if(_selectedOffer == null) return 0;
    return double.tryParse(_selectedOffer!.price.total ?? "");
  }

  HotelGroup({
    required name,
    required members,
    required infos,
    required offers,
    selectedOffer,
    selectedInfo,
    required Future<void> Function() save,
  }) : 
    _save = save,
    _members = members,
    _name = name,
    _offers = offers,
    _infos = infos,
    _selectedOffer = selectedOffer,
    _selectedInfo = selectedInfo;

  factory HotelGroup.fromJson(Map<String, dynamic> json, Future<void> Function() save) {
    return HotelGroup(
      members: (json['members'] as List).map((item) => item as String).toList(),
      name: json['name'],
      infos: (json['infos'] as List).map((option) => HotelInfo.fromJson(option)).toList(),
      offers: (json['offers'] as List).map((offer) => HotelOffer.fromJson(offer)).toList(),
      selectedInfo: json['selectedOption'] != null ? HotelOption.fromJson(json['selectedOption']) : null,
      selectedOffer: json['selectedOffer'] != null ? HotelOffer.fromJson(json['selectedOffer']) : null,
      save: save
    );
  }

  String get name => _name;
  List<String> get members => _members;
  List<HotelInfo> get infos => _infos;
  List<HotelOffer> get offers => _offers;
  HotelOffer? get selectedOffer => _selectedOffer;
  HotelInfo? get selectedInfo => _selectedInfo;

  Map<String, dynamic> toJson() {
    return {
      "members": _members,
      "name": _name,
      "infos": _infos.map((option) => option.toJson()).toList(),
      "offers": _offers.map((offer) => offer.toJson()).toList(),
      "selectedOffer": selectedOffer?.toJson(),
      "selectedInfo": selectedInfo?.toJson(),
    };
  }

  Future<void> selectOption(HotelInfo info, HotelOffer offer) async {
    _selectedInfo = info;
    _selectedOffer = offer;
    await _save();
  }
  Future<void> addOption(HotelInfo info, HotelOffer offer) async {
    _offers.add(offer);
    _infos.add(info);
    await _save();
  }
  Future<void> removeOption(int i) async {
    if(i < 0 || i > _offers.length) return;
    _offers.removeAt(i);
    _infos.removeAt(i);
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
  Future<void> setName(String name) async {
    _name = name;
    await _save();
  }
}

class RentalCarGroup {
  List<String> _members;
  List<RentalCarOffer> _options;
  String _name;
  RentalCarOffer? _selected;
  Future<void> Function() _save;

  double get price {
    if(_selected == null) return 0;
    return _selected!.price;
  }

  RentalCarGroup({
    required members,
    required options,
    required name,
    selected,
    required Future<void> Function() save,
  }) : 
    _save = save,
    _name = name,
    _members = members,
    _options = options,
    _selected = selected;

  factory RentalCarGroup.fromJson(Map<String, dynamic> json, Future<void> Function() save) {
    return RentalCarGroup(
      members: (json['members'] as List).map((item) => item as String).toList(),
      name: json['name'],
      options: (json['options'] as List).map((option) => RentalCarOffer.fromJson(option)).toList(),
      selected: json['selected'] != null ? RentalCarOffer.fromJson(json['selected']) : null,
      save: save
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "members": _members,
      "name": _name,
      "options": _options.map((option) => option.toJson()).toList(),
      "selected": _selected?.toJson(),
    };
  }

  String get name => _name;
  List<String> get members => _members;
  List<RentalCarOffer> get options => _options;
  RentalCarOffer? get selected => _selected;

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
  Future<void> removeOptionById(String id) async {
    _options.removeWhere((element) => element.guid == id);
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
  Future<void> setName(String name) async {
    _name = name;
    await _save();
  }
}

class Activity {
  final TicketmasterEvent _event;
  final List<String> _participants;
  Future<void> Function() _save;

  double? get price {
    if(_event.prices.isEmpty) {
      return null;
    }
    double perPerson = _event.prices.map((e) => e.min).reduce(min);
    if(perPerson == 0) {
      return null;
    }
    return perPerson * _participants.length;
  }

  Activity({
    required TicketmasterEvent event,
    required List<String> participants,
    required Future<void> Function() save,
  }) : _event = event,
       _participants = participants,
       _save = save;

  Map<String, dynamic> toJson() {
    return {
      "event": _event.toJson(),
      "participants": _participants,
    };
  }

  TicketmasterEvent get event => _event;
  List<String> get participants => _participants;

  Future<void> addParticipant(String uid) async {
    _participants.add(uid);
    await _save();
  }

  Future<void> removeParticipant(String uid) async {
    _participants.remove(uid);
    await _save();
  }

  factory Activity.fromJson(Map<String, dynamic> json, Future<void> Function() save){
    return Activity(
      event: TicketmasterEvent.fromJson(json['event']),
      participants: (json['participants'] as List).map((item) => item as String).toList(),
      save: save
    );
  } 
}