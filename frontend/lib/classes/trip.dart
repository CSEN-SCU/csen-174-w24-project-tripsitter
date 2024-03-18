import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/car.dart';
import 'package:tripsitter/classes/city.dart';
import 'package:tripsitter/classes/flights.dart';
import 'package:tripsitter/classes/hotels.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'dart:async';

import 'package:tripsitter/classes/yelp.dart';

class Trip {
  final String _id;
  final List<String> _uids;
  String _name;
  DateTime _startDate;
  DateTime _endDate;
  City _destination;
  bool _isConfirmed;
  bool _usingSplitPayments;
  bool _frozen;
  Map<String, bool> _paymentsComplete;

  List<FlightGroup> _flights;
  List<HotelGroup> _hotels;
  List<RentalCarGroup> _rentalCars;
  List<Activity> _activities;
  List<Meal> _meals;
  List<TripComment> _comments;

  Trip({
    required String id,
    required List<String> uids,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required City destination,
    required bool isConfirmed,
    required bool usingSplitPayments,
    required bool frozen,
    required Map<String, bool> paymentsComplete,
    required List<FlightGroup> flights,
    required List<HotelGroup> hotels,
    required List<RentalCarGroup> rentalCars,
    required List<Meal> meals,
    required List<Activity> activities,
    required List<TripComment> comments,
  })  : _id = id,
        _uids = uids,
        _name = name,
        _startDate = startDate,
        _endDate = endDate,
        _destination = destination,
        _isConfirmed = isConfirmed,
        _usingSplitPayments = usingSplitPayments,
        _paymentsComplete = paymentsComplete,
        _frozen = frozen,
        _flights = flights,
        _hotels = hotels,
        _rentalCars = rentalCars,
        _meals = meals,
        _comments = comments,
        _activities = activities;

  String get id => _id;
  List<String> get uids => _uids;
  String get name => _name;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  City get destination => _destination;
  bool get isConfirmed => _isConfirmed;
  List<FlightGroup> get flights => _flights;
  List<HotelGroup> get hotels => _hotels;
  List<RentalCarGroup> get rentalCars => _rentalCars;
  List<Activity> get activities => _activities;
  List<Meal> get meals => _meals;
  Map<String, bool> get paymentsComplete => _paymentsComplete;
  bool get usingSplitPayments => _usingSplitPayments;
  bool get frozen => _frozen;
  List<TripComment> get comments => _comments;

  double get totalPrice {
    return flightsPrice + hotelsPrice + rentalCarsPrice + activitiesPrice;
  }

  double get stripePrice {
    return flightsPrice + hotelsPrice;
  }

  double get flightsPrice {
    double total = 0;
    for (FlightGroup group in _flights) {
      if (group.price != null) {
        total += group.price!;
      }
    }
    return total;
  }

  double get hotelsPrice {
    double total = 0;
    for (HotelGroup group in _hotels) {
      if (group.price != null) {
        total += group.price!;
      }
    }
    return total;
  }

  double get rentalCarsPrice {
    double total = 0;
    for (RentalCarGroup group in _rentalCars) {
      total += group.price;
    }
    return total;
  }

  double get activitiesPrice {
    double total = 0;
    for (Activity activity in _activities) {
      if (activity.price != null) {
        total += activity.price!;
      }
    }
    return total;
  }

  double get mealsPrice {
    double total = 0;
    for (Meal meal in _meals) {
      if (meal.price != null) {
        total += meal.price!;
      }
    }
    return total;
  }

  double userFlightsPrice(String uid) {
    double total = 0;
    for (FlightGroup group in _flights) {
      total += group.userPrice(uid) ?? 0;
    }
    return total;
  }

  double userHotelsPrice(String uid) {
    double total = 0;
    for (HotelGroup group in _hotels) {
      total += group.userPrice(uid) ?? 0;
    }
    return total;
  }

  double userRentalCarsPrice(String uid) {
    double total = 0;
    for (RentalCarGroup group in _rentalCars) {
      total += group.userPrice(uid);
    }
    return total;
  }

  double userActivitiesPrice(String uid) {
    double total = 0;
    for (Activity activity in _activities) {
      total += activity.userPrice(uid) ?? 0;
    }
    return total;
  }

  double userMealsPrice(String uid) {
    double total = 0;
    for (Meal meal in _meals) {
      total += meal.userPrice(uid) ?? 0;
    }
    return total;
  }

  double userTotalPrice(String uid) {
    return userFlightsPrice(uid) +
        userHotelsPrice(uid) +
        userRentalCarsPrice(uid) +
        userActivitiesPrice(uid) +
        userMealsPrice(uid);
  }

  double userStripePrice(String uid) {
    return userFlightsPrice(uid) + userHotelsPrice(uid);
  }

  String get itineraryStr {
    List<String> lines = [];

    lines.add(_name);
    lines.add(
        "${DateFormat("MM/dd/yyyy").format(_startDate)} - ${DateFormat("MM/dd/yyyy").format(_endDate)}");
    lines.add("${_destination.name}, ${_destination.country}");

    return lines.join("\n");
  }

  Future<void> save() async {
    await _save();
  }

  Map<String, dynamic> toJson() {
    return {
      "uids": _uids,
      "paymentsComplete": _paymentsComplete,
      "usingSplitPayments": _usingSplitPayments,
      "name": _name,
      "startDate": _startDate,
      "endDate": _endDate,
      "destination": _destination.toJson(),
      "isConfirmed": _isConfirmed,
      "flights": _flights.map((flight) => flight.toJson()).toList(),
      "hotels": _hotels.map((hotel) => hotel.toJson()).toList(),
      "rentalCars": _rentalCars.map((rentalCar) => rentalCar.toJson()).toList(),
      "activities": _activities.map((activity) => activity.toJson()).toList(),
      "meals": _meals.map((meal) => meal.toJson()).toList(),
      "frozen": _frozen,
      "comments": _comments.map((comment) => comment.toJson()).toList(),
    };
  }

  Future<void> _save() async {
    await FirebaseFirestore.instance.collection("trips").doc(_id).set(toJson());
  }

  static Stream<List<Trip>> getTripsByProfile(String uid) {
    return FirebaseFirestore.instance
        .collection('trips')
        .where('uids', arrayContains: uid)
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
    });
  }

  static Stream<Trip> getTripById(String id) {
    return FirebaseFirestore.instance
        .collection("trips")
        .doc(id)
        .snapshots()
        .map((doc) => Trip.fromFirestore(doc));
  }

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    Trip t = Trip(
      id: doc.id,
      uids: (data['uids'] as List).map((item) => item as String).toList(),
      comments: data["comments"] != null
          ? List<TripComment>.from(
              data["comments"].map((x) => TripComment.fromJson(x)))
          : List.empty(growable: true),
      usingSplitPayments: data['usingSplitPayments'] ?? false,
      frozen: data['frozen'] ?? false,
      paymentsComplete: Map<String, bool>.from(data['paymentsComplete'] ?? {}),
      name: data['name'],
      startDate: data['startDate'].toDate(),
      endDate: data['endDate'].toDate(),
      destination: City.fromJson(data['destination']),
      isConfirmed: data['isConfirmed'],
      flights: List.empty(growable: true),
      hotels: List.empty(growable: true),
      rentalCars: List.empty(growable: true),
      activities: List.empty(growable: true),
      meals: List.empty(growable: true),
    );

    t._flights = (data['flights'] as List)
        .map((flight) => FlightGroup.fromJson(flight, t._save))
        .toList();
    t._hotels = (data['hotels'] as List)
        .map((hotel) => HotelGroup.fromJson(hotel, t._save))
        .toList();
    t._rentalCars = (data['rentalCars'] as List)
        .map((rentalCar) => RentalCarGroup.fromJson(rentalCar, t._save))
        .toList();
    t._activities = (data['activities'] as List)
        .map((activity) => Activity.fromJson(activity, t._save))
        .toList();
    t._meals = ((data['meals'] ?? []) as List)
        .map((meal) => Meal.fromJson(meal, t._save))
        .toList();

    return t;
  }

  Future<void> addFlightGroup(String departureAirport, String arrivalAirport,
      List<String> members) async {
    _flights.add(FlightGroup(
      members: members,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      options: List.empty(growable: true),
      selected: null,
      pnr: null,
      save: _save,
    ));
    await _save();
  }

  Future<void> removeFlightGroup(FlightGroup flight) async {
    _flights.remove(flight);
    await _save();
  }

  Future<HotelGroup> createHotelGroup(String name, List<String> members) async {
    HotelGroup hotel = HotelGroup(
        name: name,
        pnr: null,
        members: members,
        offers: List<HotelOffer>.empty(growable: true),
        infos: List<HotelInfo>.empty(growable: true),
        save: save);
    _hotels.add(hotel);
    await _save();
    return hotel;
  }

  Future<void> removeHotelGroup(HotelGroup hotel) async {
    _hotels.remove(hotel);
    await _save();
  }

  Future<RentalCarGroup> createRentalCarGroup(
      String name, List<String> members) async {
    RentalCarGroup rentalCar = RentalCarGroup(
        name: name,
        members: members,
        options: List<RentalCarOffer>.empty(growable: true),
        save: save);
    _rentalCars.add(rentalCar);
    await _save();
    return rentalCar;
  }

  Future<void> removeRentalCarGroup(RentalCarGroup rentalCar) async {
    _rentalCars.remove(rentalCar);
    await _save();
  }

  Future<void> updateName(String name) async {
    _name = name;
    await _save();
  }

  Future<void> updateStartDate(DateTime date) async {
    if (_startDate == date) return;
    _startDate = date;
    flights.clear();
    hotels.clear();
    rentalCars.clear();
    _activities = activities
        .where((e) =>
            e.event.startTime.dateTimeUtc != null &&
            e.event.startTime.dateTimeUtc!.isAfter(date))
        .toList();
    await _save();
  }

  Future<void> updateEndDate(DateTime date) async {
    if (_endDate == date) return;
    _endDate = date;
    flights.clear();
    hotels.clear();
    rentalCars.clear();
    _activities = activities
        .where((e) =>
            e.event.startTime.dateTimeUtc != null &&
            e.event.startTime.dateTimeUtc!.isBefore(date))
        .toList();
    await _save();
  }

  Future<void> updateDestination(City newDest) async {
    if (newDest.lat == _destination.lat && newDest.lon == _destination.lon)
      return;
    _destination = newDest;
    flights.clear();
    hotels.clear();
    rentalCars.clear();
    activities.clear();
    await _save();
  }

  Future<void> addActivity(TicketmasterEvent event, List<String> uids) async {
    _activities.add(Activity(
      comments: List<TripComment>.empty(growable: true),
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

  Future<void> addMeal(YelpRestaurant restaurant, List<String> uids) async {
    _meals.add(Meal(
      comments: List<TripComment>.empty(growable: true),
      restaurant: restaurant,
      participants: uids,
      save: _save,
    ));
    await _save();
  }

  Future<void> removeMeal(Meal meal) async {
    _meals.remove(meal);
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

  Future<void> complete() async {
    _isConfirmed = true;
    _frozen = true;
    await _save();
  }

  Future<void> freeze() async {
    _frozen = true;
    await _save();
  }

  Future<void> toggleSplitPayments() async {
    _usingSplitPayments = !_usingSplitPayments;
    await _save();
  }

  Future<void> addComment(TripComment comment) async {
    _comments.add(comment);
    await _save();
  }

  Future<void> removeComment(TripComment comment) async {
    _comments.remove(comment);
    await _save();
  }

  delete() {
    FirebaseFirestore.instance.collection("trips").doc(_id).delete();
  }
}

class FlightGroup {
  List<String> _members;
  String _departureAirport;
  String _arrivalAirport;
  List<FlightOffer> _options;
  FlightOffer? _selected;
  String? _pnr;
  Future<void> Function() _save;

  double? get price {
    if (_selected == null) return 0;
    return double.tryParse(_selected!.price.total);
  }

  double? userPrice(String uid) {
    if (_selected == null || !_members.contains(uid)) return 0;
    double? total = double.tryParse(_selected!.price.total);
    if (total == null) return 0;
    return total / _members.length.toDouble();
  }

  FlightGroup({
    required List<String> members,
    required String departureAirport,
    required String arrivalAirport,
    required List<FlightOffer> options,
    required String? pnr,
    FlightOffer? selected,
    required Future<void> Function() save,
  })  : _members = members,
        _departureAirport = departureAirport,
        _arrivalAirport = arrivalAirport,
        _options = options,
        _selected = selected,
        _pnr = pnr,
        _save = save;

  factory FlightGroup.fromJson(
      Map<String, dynamic> json, Future<void> Function() save) {
    return FlightGroup(
      save: save,
      members: (json['members'] as List).map((e) => e as String).toList(),
      departureAirport: json['departureAirport'],
      arrivalAirport: json['arrivalAirport'],
      pnr: json["pnr"],
      options: (json['options'] as List)
          .map((option) => FlightOffer.fromJson(option))
          .toList(),
      selected: json['selected'] != null
          ? FlightOffer.fromJson(json['selected'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "members": _members,
      "departureAirport": _departureAirport,
      "arrivalAirport": _arrivalAirport,
      "options": _options.map((option) => option.toJson()).toList(),
      "selected": _selected?.toJson(),
      "pnr": _pnr
    };
  }

  List<String> get members => _members;
  String get departureAirport => _departureAirport;
  String get arrivalAirport => _arrivalAirport;
  List<FlightOffer> get options => _options;
  FlightOffer? get selected => _selected;
  String? get pnr => _pnr;

  Future<void> selectOption(FlightOffer option) async {
    _selected = option;
    await _save();
  }

  Future<void> setPnr(String pnr) async {
    _pnr = pnr;
    await _save();
  }

  Future<void> addOption(FlightOffer option) async {
    _options.add(option);
    _selected = option;
    await _save();
  }

  Future<void> removeOption(FlightOffer option) async {
    if (option == _selected) {
      _selected = null;
    }
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
    if (airport == _departureAirport) return;
    _departureAirport = airport;
    options.clear();
    _selected = null;
    await _save();
  }

  Future<void> setArrivalAirport(String airport) async {
    if (airport == _arrivalAirport) return;
    _arrivalAirport = airport;
    options.clear();
    _selected = null;
    await _save();
  }
}

class HotelGroup {
  List<String> _members;
  List<HotelInfo> _infos;
  List<HotelOffer> _offers;
  String _name;
  String? _pnr;
  HotelOffer? _selectedOffer;
  HotelInfo? _selectedInfo;
  Future<void> Function() _save;

  double? get price {
    if (_selectedOffer == null) return 0;
    return double.tryParse(_selectedOffer!.price.total ?? "");
  }

  double? userPrice(String uid) {
    if (_selectedOffer == null || !_members.contains(uid)) return 0;
    double? total = double.tryParse(_selectedOffer!.price.total ?? "");
    if (total == null) return 0;
    return total / _members.length.toDouble();
  }

  HotelGroup({
    required String name,
    required List<String> members,
    required List<HotelInfo> infos,
    required List<HotelOffer> offers,
    required String? pnr,
    HotelOffer? selectedOffer,
    HotelInfo? selectedInfo,
    required Future<void> Function() save,
  })  : _save = save,
        _members = members,
        _name = name,
        _offers = offers,
        _infos = infos,
        _pnr = pnr,
        _selectedOffer = selectedOffer,
        _selectedInfo = selectedInfo;

  factory HotelGroup.fromJson(
      Map<String, dynamic> json, Future<void> Function() save) {
    return HotelGroup(
      members: (json['members'] as List).map((item) => item as String).toList(),
      name: json['name'],
      pnr: json['pnr'],
      infos: (json['infos'] as List)
          .map((option) => HotelInfo.fromJson(option))
          .toList(),
      offers: (json['offers'] as List)
          .map((offer) => HotelOffer.fromJson(offer))
          .toList(),
      selectedInfo: json['selectedInfo'] != null
          ? HotelInfo.fromJson(json['selectedInfo'])
          : null,
      selectedOffer: json['selectedOffer'] != null
          ? HotelOffer.fromJson(json['selectedOffer'])
          : null,
      save: save,
    );
  }

  String get name => _name;
  List<String> get members => _members;
  List<HotelInfo> get infos => _infos;
  List<HotelOffer> get offers => _offers;
  HotelOffer? get selectedOffer => _selectedOffer;
  HotelInfo? get selectedInfo => _selectedInfo;
  String? get pnr => _pnr;

  Map<String, dynamic> toJson() {
    return {
      "members": _members,
      "name": _name,
      "infos": _infos.map((option) => option.toJson()).toList(),
      "offers": _offers.map((offer) => offer.toJson()).toList(),
      "selectedOffer": selectedOffer?.toJson(),
      "selectedInfo": selectedInfo?.toJson(),
      "pnr": _pnr
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
    _selectedInfo = info;
    _selectedOffer = offer;
    await _save();
  }

  Future<void> removeOption(int i) async {
    if (i < 0 || i > _offers.length) return;
    if (_selectedOffer == _offers[i]) {
      _selectedOffer = null;
    }
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

  Future<void> setPnr(String pnr) async {
    _pnr = pnr;
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
    if (_selected == null) return 0;
    return _selected!.price;
  }

  double userPrice(String uid) {
    if (_selected == null || !_members.contains(uid)) return 0;
    return _selected!.price / _members.length.toDouble();
  }

  RentalCarGroup({
    required List<String> members,
    required List<RentalCarOffer> options,
    required String name,
    RentalCarOffer? selected,
    required Future<void> Function() save,
  })  : _save = save,
        _name = name,
        _members = members,
        _options = options,
        _selected = selected;

  factory RentalCarGroup.fromJson(
      Map<String, dynamic> json, Future<void> Function() save) {
    return RentalCarGroup(
      members: (json['members'] as List).map((item) => item as String).toList(),
      name: json['name'],
      options: (json['options'] as List)
          .map((option) => RentalCarOffer.fromJson(option))
          .toList(),
      selected: json['selected'] != null
          ? RentalCarOffer.fromJson(json['selected'])
          : null,
      save: save,
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
    _selected = option;
    await _save();
  }

  Future<void> removeOption(RentalCarOffer option) async {
    if (option == _selected) {
      _selected = null;
    }
    _options.remove(option);
    await _save();
  }

  Future<void> removeOptionById(String id) async {
    if (_selected?.guid == id) {
      _selected = null;
    }
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
  final List<TripComment> _comments;
  Future<void> Function() _save;

  double? get price {
    if (_event.prices.isEmpty) {
      return null;
    }
    double perPerson = _event.prices.map((e) => e.min).reduce(min);
    if (perPerson == 0) {
      return null;
    }
    return perPerson * _participants.length;
  }

  double? userPrice(String uid) {
    if (_event.prices.isEmpty || !_participants.contains(uid)) {
      return null;
    }
    double perPerson = _event.prices.map((e) => e.min).reduce(min);
    if (perPerson == 0) {
      return null;
    }
    return perPerson;
  }

  Activity({
    required TicketmasterEvent event,
    required List<String> participants,
    required List<TripComment> comments,
    required Future<void> Function() save,
  })  : _event = event,
        _participants = participants,
        _comments = comments,
        _save = save;

  Map<String, dynamic> toJson() {
    return {
      "event": _event.toJson(),
      "participants": _participants,
      "comments": _comments.map((comment) => comment.toJson()).toList(),
    };
  }

  TicketmasterEvent get event => _event;
  List<String> get participants => _participants;
  List<TripComment> get comments => _comments;

  Future<void> addParticipant(String uid) async {
    _participants.add(uid);
    await _save();
  }

  Future<void> removeParticipant(String uid) async {
    _participants.remove(uid);
    await _save();
  }

  factory Activity.fromJson(
      Map<String, dynamic> json, Future<void> Function() save) {
    return Activity(
        comments: (json['comments'] as List)
            .map((comment) => TripComment.fromJson(comment))
            .toList(),
        event: TicketmasterEvent.fromJson(json['event']),
        participants: (json['participants'] as List)
            .map((item) => item as String)
            .toList(),
        save: save);
  }

  Future<void> addComment(TripComment comment) async {
    _comments.add(comment);
    await _save();
  }

  Future<void> removeComment(TripComment comment) async {
    _comments.remove(comment);
    await _save();
  }
}

class Meal {
  final YelpRestaurant _restaurant;
  final List<String> _participants;
  final List<TripComment> _comments;
  Future<void> Function() _save;

  Meal({
    required YelpRestaurant restaurant,
    required List<String> participants,
    required List<TripComment> comments,
    required Future<void> Function() save,
  })  : _restaurant = restaurant,
        _participants = participants,
        _comments = comments,
        _save = save;

  Map<String, dynamic> toJson() {
    return {
      "restaurant": _restaurant.toJson(),
      "participants": _participants,
      "comments": _comments.map((comment) => comment.toJson()).toList(),
    };
  }

  YelpRestaurant get restaurant => _restaurant;
  List<String> get participants => _participants;
  List<TripComment> get comments => _comments;

  double? get price {
    if (_restaurant.price == null) return null;
    return double.tryParse(_restaurant.price ?? '');
  }

  double? userPrice(String uid) {
    if (_restaurant.price == null || !_participants.contains(uid)) return 0;
    double? total = double.tryParse(_restaurant.price ?? '');
    if (total == null) return 0;
    return total / _participants.length.toDouble();
  }

  Future<void> addParticipant(String uid) async {
    _participants.add(uid);
    await _save();
  }

  Future<void> removeParticipant(String uid) async {
    _participants.remove(uid);
    await _save();
  }

  factory Meal.fromJson(
      Map<String, dynamic> json, Future<void> Function() save) {
    return Meal(
        comments: (json['comments'] as List)
            .map((comment) => TripComment.fromJson(comment))
            .toList(),
        restaurant: YelpRestaurant.fromJson(json['restaurant']),
        participants: (json['participants'] as List)
            .map((item) => item as String)
            .toList(),
        save: save);
  }

  Future<void> addComment(TripComment comment) async {
    _comments.add(comment);
    await _save();
  }

  Future<void> removeComment(TripComment comment) async {
    _comments.remove(comment);
    await _save();
  }
}

class TripComment {
  final String _uid;
  final String _comment;
  final DateTime _date;

  TripComment({
    required String uid,
    required String comment,
    required DateTime date,
  })  : _uid = uid,
        _comment = comment,
        _date = date;

  String get uid => _uid;
  String get comment => _comment;
  DateTime get date => _date;

  Map<String, dynamic> toJson() {
    return {
      "uid": _uid,
      "comment": _comment,
      "date": Timestamp.fromDate(_date),
    };
  }

  factory TripComment.fromJson(Map<String, dynamic> json) {
    return TripComment(
      uid: json['uid'],
      comment: json['comment'],
      date: (json['date'] as Timestamp).toDate(),
    );
  }
}

class TravelerInfo {
  final int id;
  final String dateOfBirth;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String countryCode;
  final String phoneNumber;

  TravelerInfo({
    required this.id,
    required this.dateOfBirth,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.countryCode,
    required this.phoneNumber,
  });

  Map<String, dynamic> toFlightJson() {
    return {
      "id": (id + 1).toString(),
      "dateOfBirth": dateOfBirth,
      "name": {
        "firstName": firstName,
        "lastName": lastName,
      },
      "gender": gender.toUpperCase(),
      "contact": {
        "emailAddress": email,
        "phones": [
          {
            "deviceType": "MOBILE",
            "countryCallingCode": countryCode,
            "number": phoneNumber
          }
        ]
      }
    };
  }

  Map<String, dynamic> toHotelJson() {
    return {
      "name": {
        "title": gender == "Male" ? "MR" : (gender == "Female" ? "MS" : "MX"),
        "firstName": firstName.toUpperCase(),
        "lastName": lastName.toUpperCase()
      },
      "contact": {"phone": "+$countryCode$phoneNumber", "email": email}
    };
  }

  factory TravelerInfo.fromUserProfile(UserProfile profile, int num) {
    return TravelerInfo(
        id: num,
        gender: profile.gender,
        countryCode: profile.countryCode,
        phoneNumber: profile.phoneNumber,
        dateOfBirth: DateFormat("yyyy-MM-dd").format(profile.birthDate),
        firstName: profile.name.split(" ").first,
        lastName: profile.name.split(" ").slice(1).join(" "),
        email: profile.email);
  }
}
