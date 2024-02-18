import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';

class FlightsQuery {
  String origin;
  String destination;
  DateTime departureDate;
  DateTime? returnDate;
  int adults;
  int? children;
  String? currency;
  TravelClass? travelClass;

  FlightsQuery({
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.adults,
    this.children,
    this.currency,
    this.travelClass,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'origin': origin,
      'destination': destination,
      'departureDate': departureDate.toIso8601String().split('T')[0],
      'adults': adults.toString(),
    };
    if (returnDate != null) {
      json['returnDate'] = returnDate!.toIso8601String().split('T')[0];
    }
    if (children != null) {
      json['children'] = children.toString();
    }
    if (currency != null) {
      json['currency'] = currency;
    }
    if (travelClass != null) {
      switch (travelClass) {
        case TravelClass.economy:
          json['travelClass'] = 'ECONOMY';
          break;
        case TravelClass.premiumEconomy:
          json['travelClass'] = 'PREMIUM_ECONOMY';
          break;
        case TravelClass.business:
          json['travelClass'] = 'BUSINESS';
          break;
        case TravelClass.first:
          json['travelClass'] = 'FIRST';
          break;
        default:
          break;
      }
    }
    return json;
  }
}

enum TravelClass {
  economy,
  premiumEconomy,
  business,
  first,
}

class FlightItineraryRecursive {
  List<FlightItineraryRecursive> next;
  FlightPrice? minPrice;
  Set<String> offerIds;
  bool isOneWay;
  int numberOfBookableSeats;
  Set<String> offeredBy;
  List<Set<String>> flightNumbers;
  List<FlightOffer> offers;
  String id;
  int depth;

  List<FlightSegment> get segments {
    return offers.first.itineraries[depth].segments;
  }

  List<FlightItinerary> get itineraries {
    return offers.map((offer) => offer.itineraries[depth]).toList();
  }

  FlightItineraryRecursive({
    required this.depth,
    required this.id,
    required this.offers,
    required this.next,
    required this.minPrice,
    required this.offerIds,
    required this.isOneWay,
    required this.numberOfBookableSeats,
    required this.offeredBy,
    required this.flightNumbers,
  });

  static List<FlightItineraryRecursive> fromOffersList(
      List<FlightOffer> offers) {
    List<FlightItineraryRecursive> itineraries = [];
    List<FlightItineraryRecursive> currentObj = itineraries;
    int depth = 0;
    for (FlightOffer offer in offers) {
      currentObj = itineraries;
      depth = 0;
      for (FlightItinerary i in offer.itineraries) {
        FlightItineraryRecursive? iRec = itineraries.firstWhereOrNull((ir) {
          if (ir.id == i.id) {
            return true;
          }
          if (ir.offers.first.itineraries.first.segments.length !=
              i.segments.length) {
            return false;
          }
          for (int j = 0; j < i.segments.length; j++) {
            if (ir.offers.first.itineraries[depth].segments[j].departure
                    .iataCode !=
                i.segments[j].departure.iataCode) {
              return false;
            }
            if (ir.offers.first.itineraries[depth].segments[j].arrival
                    .iataCode !=
                i.segments[j].arrival.iataCode) {
              return false;
            }
            if (ir.offers.first.itineraries[depth].segments[j].departure.at !=
                i.segments[j].departure.at) {
              return false;
            }
            if (ir.offers.first.itineraries[depth].segments[j].arrival.at !=
                i.segments[j].arrival.at) {
              return false;
            }
            String thisOperator = i.segments[j].operating?.carrierCode ??
                i.segments[j].carrierCode;
            String thatOperator = ir.offers.first.itineraries[depth].segments[j]
                    .operating?.carrierCode ??
                ir.offers.first.itineraries[depth].segments[j].carrierCode;
            if (thisOperator != thatOperator) {
              return false;
            }
          }
          return true;
        });
        if (iRec == null) {
          iRec = FlightItineraryRecursive(
            depth: depth,
            id: i.id,
            offers: [],
            next: [],
            minPrice: null,
            offerIds: {},
            isOneWay: offer.oneWay,
            numberOfBookableSeats: offer.numberOfBookableSeats,
            offeredBy: {},
            flightNumbers: [],
          );
          currentObj.add(iRec);
        }

        iRec.offers.add(offer);
        iRec.offerIds.add(offer.id);
        iRec.offeredBy.add(offer.validatingAirlineCodes.first);
        for (int j = 0; j < i.segments.length; j++) {
          if (iRec.flightNumbers.length <= j) {
            iRec.flightNumbers.add({});
          }
          iRec.flightNumbers[j]
              .add(i.segments[j].carrierCode + i.segments[j].number);
        }

        if (iRec.minPrice == null ||
            double.parse(offer.price.total) <
                double.parse(iRec.minPrice!.total)) {
          iRec.minPrice = offer.price;
        }

        depth++;
        currentObj = iRec.next;
      }
    }
    return itineraries;
  }
}

class FlightOffer {
  final String type;
  final String id;
  final String source;
  final bool instantTicketingRequired;
  final bool nonHomogeneous;
  final bool oneWay;
  final String lastTicketingDate;
  final String lastTicketingDateTime;
  final int numberOfBookableSeats;
  final List<FlightItinerary> itineraries;
  final FlightPrice price;
  final FlightPricingOptions pricingOptions;
  final List<String> validatingAirlineCodes;
  final List<FlightTravelerPricing> travelerPricings;

  const FlightOffer({
    required this.type,
    required this.id,
    required this.source,
    required this.instantTicketingRequired,
    required this.nonHomogeneous,
    required this.oneWay,
    required this.lastTicketingDate,
    required this.lastTicketingDateTime,
    required this.numberOfBookableSeats,
    required this.itineraries,
    required this.price,
    required this.pricingOptions,
    required this.validatingAirlineCodes,
    required this.travelerPricings,
  });

  factory FlightOffer.fromJson(Map<String, dynamic> json) {
    return FlightOffer(
      type: json['type'],
      id: json['id'],
      source: json['source'],
      instantTicketingRequired: json['instantTicketingRequired'],
      nonHomogeneous: json['nonHomogeneous'],
      oneWay: json['oneWay'],
      lastTicketingDate: json['lastTicketingDate'],
      lastTicketingDateTime: json['lastTicketingDateTime'],
      numberOfBookableSeats: json['numberOfBookableSeats'],
      itineraries: List<FlightItinerary>.from(json['itineraries']
          .map((itinerary) => FlightItinerary.fromJson(itinerary))),
      price: FlightPrice.fromJson(json['price']),
      pricingOptions: FlightPricingOptions.fromJson(json['pricingOptions']),
      validatingAirlineCodes: List<String>.from(json['validatingAirlineCodes']),
      travelerPricings: List<FlightTravelerPricing>.from(
          json['travelerPricings'].map((travelerPricing) =>
              FlightTravelerPricing.fromJson(travelerPricing))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'source': source,
      'instantTicketingRequired': instantTicketingRequired,
      'nonHomogeneous': nonHomogeneous,
      'oneWay': oneWay,
      'lastTicketingDate': lastTicketingDate,
      'lastTicketingDateTime': lastTicketingDateTime,
      'numberOfBookableSeats': numberOfBookableSeats,
      'itineraries':
          itineraries.map((itinerary) => itinerary.toJson()).toList(),
      'price': price.toJson(),
      'pricingOptions': pricingOptions.toJson(),
      'validatingAirlineCodes': validatingAirlineCodes,
      'travelerPricings': travelerPricings
          .map((travelerPricing) => travelerPricing.toJson())
          .toList(),
    };
  }
}

class FlightItinerary {
  final String duration;
  final List<FlightSegment> segments;
  final String id;

  FlightItinerary({required this.duration, required this.segments})
      : id = segments.map((segment) => segment.id).join('-');

  factory FlightItinerary.fromJson(Map<String, dynamic> json) {
    return FlightItinerary(
      duration: json['duration'],
      segments: List<FlightSegment>.from(
          json['segments'].map((segment) => FlightSegment.fromJson(segment))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'segments': segments.map((segment) => segment.toJson()).toList(),
    };
  }
}

class FlightSegment {
  final FlightDepartureArrival departure;
  final FlightDepartureArrival arrival;
  final String carrierCode;
  final String number;
  final FlightAircraft aircraft;
  final FlightOperating? operating;
  final String duration;
  final String id;
  final int numberOfStops;
  final bool blacklistedInEU;

  String get airlineOperating {
    return operating?.carrierCode ?? carrierCode;
  }

  const FlightSegment({
    required this.departure,
    required this.arrival,
    required this.carrierCode,
    required this.number,
    required this.aircraft,
    required this.operating,
    required this.duration,
    required this.id,
    required this.numberOfStops,
    required this.blacklistedInEU,
  });

  factory FlightSegment.fromJson(Map<String, dynamic> json) {
    return FlightSegment(
      departure: FlightDepartureArrival.fromJson(json['departure']),
      arrival: FlightDepartureArrival.fromJson(json['arrival']),
      carrierCode: json['carrierCode'],
      number: json['number'],
      aircraft: FlightAircraft.fromJson(json['aircraft']),
      operating: json['operating'] != null
          ? FlightOperating.fromJson(json['operating'])
          : null,
      duration: json['duration'],
      id: json['id'],
      numberOfStops: json['numberOfStops'],
      blacklistedInEU: json['blacklistedInEU'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'departure': departure.toJson(),
      'arrival': arrival.toJson(),
      'carrierCode': carrierCode,
      'number': number,
      'aircraft': aircraft.toJson(),
      'duration': duration,
      'id': id,
      'numberOfStops': numberOfStops,
      'blacklistedInEU': blacklistedInEU,
    };
    if (operating != null) {
      map['operating'] = operating!.toJson();
    }
    return map;
  }
}

class FlightDepartureArrival {
  final String iataCode;
  final String? terminal;
  final DateTime at;

  const FlightDepartureArrival(
      {required this.iataCode, this.terminal, required this.at});

  factory FlightDepartureArrival.fromJson(Map<String, dynamic> json) {
    return FlightDepartureArrival(
      iataCode: json['iataCode'],
      terminal: json['terminal'],
      at: DateTime.parse(json['at']),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'iataCode': iataCode,
      'at': at.toIso8601String(),
    };
    if (terminal != null) {
      map['terminal'] = terminal;
    }
    return map;
  }
}

class FlightAircraft {
  final String code;

  const FlightAircraft({required this.code});

  factory FlightAircraft.fromJson(Map<String, dynamic> json) {
    return FlightAircraft(
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
    };
  }
}

class FlightOperating {
  final String carrierCode;

  const FlightOperating({required this.carrierCode});

  factory FlightOperating.fromJson(Map<String, dynamic> json) {
    return FlightOperating(
      carrierCode: json['carrierCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carrierCode': carrierCode,
    };
  }
}

class FlightPrice {
  final String currency;
  final String total;
  final String base;
  final List<FlightFee> fees;
  final String? grandTotal;

  const FlightPrice({
    required this.currency,
    required this.total,
    required this.base,
    required this.fees,
    required this.grandTotal,
  });

  factory FlightPrice.fromJson(Map<String, dynamic> json) {
    return FlightPrice(
      currency: json['currency'],
      total: json['total'],
      base: json['base'],
      fees: List<FlightFee>.from(
          (json['fees'] ?? []).map((fee) => FlightFee.fromJson(fee))),
      grandTotal: json['grandTotal'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'currency': currency,
      'total': total,
      'base': base,
      'fees': fees.map((fee) => fee.toJson()).toList(),
    };
    if (grandTotal != null) {
      map['grandTotal'] = grandTotal;
    }
    return map;
  }
}

class FlightFee {
  final String amount;
  final String type;

  const FlightFee({required this.amount, required this.type});

  factory FlightFee.fromJson(Map<String, dynamic> json) {
    return FlightFee(
      amount: json['amount'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'type': type,
    };
  }
}

class FlightPricingOptions {
  final List<String> fareType;
  final bool includedCheckedBagsOnly;

  const FlightPricingOptions({
    required this.fareType,
    required this.includedCheckedBagsOnly,
  });

  factory FlightPricingOptions.fromJson(Map<String, dynamic> json) {
    return FlightPricingOptions(
      fareType: List<String>.from(json['fareType']),
      includedCheckedBagsOnly: json['includedCheckedBagsOnly'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fareType': fareType,
      'includedCheckedBagsOnly': includedCheckedBagsOnly,
    };
  }
}

class FlightTravelerPricing {
  final String travelerId;
  final String fareOption;
  final String travelerType;
  final FlightPrice price;
  final List<FlightFareDetailsBySegment> fareDetailsBySegment;

  const FlightTravelerPricing({
    required this.travelerId,
    required this.fareOption,
    required this.travelerType,
    required this.price,
    required this.fareDetailsBySegment,
  });

  factory FlightTravelerPricing.fromJson(Map<String, dynamic> json) {
    return FlightTravelerPricing(
      travelerId: json['travelerId'],
      fareOption: json['fareOption'],
      travelerType: json['travelerType'],
      price: FlightPrice.fromJson(json['price']),
      fareDetailsBySegment: List<FlightFareDetailsBySegment>.from(
          json['fareDetailsBySegment'].map((fareDetails) =>
              FlightFareDetailsBySegment.fromJson(fareDetails))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travelerId': travelerId,
      'fareOption': fareOption,
      'travelerType': travelerType,
      'price': price.toJson(),
      'fareDetailsBySegment': fareDetailsBySegment
          .map((fareDetails) => fareDetails.toJson())
          .toList(),
    };
  }
}

class FlightFareDetailsBySegment {
  final String segmentId;
  final String cabin;
  final String fareBasis;
  final String brandedFare;
  final String brandedFareLabel;
  final String classType;
  final FlightIncludedCheckedBags includedCheckedBags;
  final List<FlightAmenity> amenities;

  const FlightFareDetailsBySegment({
    required this.segmentId,
    required this.cabin,
    required this.fareBasis,
    required this.brandedFare,
    required this.brandedFareLabel,
    required this.classType,
    required this.includedCheckedBags,
    required this.amenities,
  });

  factory FlightFareDetailsBySegment.fromJson(Map<String, dynamic> json) {
    return FlightFareDetailsBySegment(
      segmentId: json['segmentId'],
      cabin: json['cabin'],
      fareBasis: json['fareBasis'],
      brandedFare: json['brandedFare'],
      brandedFareLabel: json['brandedFareLabel'],
      classType: json['class'],
      includedCheckedBags:
          FlightIncludedCheckedBags.fromJson(json['includedCheckedBags']),
      amenities: List<FlightAmenity>.from(
          json['amenities'].map((amenity) => FlightAmenity.fromJson(amenity))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segmentId': segmentId,
      'cabin': cabin,
      'fareBasis': fareBasis,
      'brandedFare': brandedFare,
      'brandedFareLabel': brandedFareLabel,
      'class': classType,
      'includedCheckedBags': includedCheckedBags.toJson(),
      'amenities': amenities.map((amenity) => amenity.toJson()).toList(),
    };
  }
}

class FlightIncludedCheckedBags {
  final int quantity;

  const FlightIncludedCheckedBags({required this.quantity});

  factory FlightIncludedCheckedBags.fromJson(Map<String, dynamic> json) {
    return FlightIncludedCheckedBags(
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
    };
  }
}

class FlightAmenity {
  final String description;
  final bool isChargeable;
  final String amenityType;
  final FlightAmenityProvider amenityProvider;

  const FlightAmenity({
    required this.description,
    required this.isChargeable,
    required this.amenityType,
    required this.amenityProvider,
  });

  factory FlightAmenity.fromJson(Map<String, dynamic> json) {
    return FlightAmenity(
      description: json['description'],
      isChargeable: json['isChargeable'],
      amenityType: json['amenityType'],
      amenityProvider: FlightAmenityProvider.fromJson(json['amenityProvider']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'isChargeable': isChargeable,
      'amenityType': amenityType,
      'amenityProvider': amenityProvider.toJson(),
    };
  }
}

class FlightAmenityProvider {
  final String name;

  const FlightAmenityProvider({required this.name});

  factory FlightAmenityProvider.fromJson(Map<String, dynamic> json) {
    return FlightAmenityProvider(
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class AirportInfo {
  final String type;
  final String iataCode;
  final String airportName;
  final String cityName;
  final String country;
  final String lat;
  final String lon;
  final String timeZoneOffset;

  const AirportInfo({
    required this.type,
    required this.iataCode,
    required this.airportName,
    required this.cityName,
    required this.country,
    required this.lat,
    required this.lon,
    required this.timeZoneOffset,
  });

  factory AirportInfo.fromJson(Map<String, dynamic> json) {
    return AirportInfo(
      type: json['type'],
      iataCode: json['iataCode'],
      airportName: json['airportName'],
      cityName: json['cityName'],
      country: json['country'],
      lat: json['lat'],
      lon: json['lon'],
      timeZoneOffset: json['timeZoneOffset'],
    );
  }
}

class AirlineInfo {
  final String iataCode;
  final String icaoCode;
  final String businessName;
  final String commonName;

  const AirlineInfo({
    required this.iataCode,
    required this.icaoCode,
    required this.businessName,
    required this.commonName,
  });

  factory AirlineInfo.fromJson(Map<String, dynamic> json) {
    return AirlineInfo(
      iataCode: json['iataCode'],
      icaoCode: json['icaoCode'],
      businessName: json['businessName'],
      commonName: json['commonName'],
    );
  }
}

class Airline {
  static Map<String, Airline> _airlineCache = {};

  static Future<void> cacheAirlines(BuildContext context) async {
    if (_airlineCache.isNotEmpty) return;
    String data =
        await DefaultAssetBundle.of(context).loadString("airlines.json");
    List<Airline> airlines = jsonDecode(data)
        .map<Airline>((a) => Airline.fromJson(a))
        .toList(); //latest Dart
    for (Airline airline in airlines) {
      _airlineCache[airline.code] = airline;
    }
  }

  static Airline? fromCode(String iata) {
    return _airlineCache[iata];
  }

  final String name;
  final String code;
  final String logo;

  Airline({
    required this.name,
    required this.code,
    required this.logo,
  });

  factory Airline.fromJson(Map<String, dynamic> json) {
    return Airline(
      name: json['name'],
      code: json['code'],
      logo: json['logo'],
    );
  }
}

extension StringToDuration on String {
  Duration toDuration() {
    if (!RegExp(
            r"^(-|\+)?P(?:([-+]?[0-9,.]*)Y)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)W)?(?:([-+]?[0-9,.]*)D)?(?:T(?:([-+]?[0-9,.]*)H)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)S)?)?$")
        .hasMatch(this)) {
      throw ArgumentError("String does not follow correct format");
    }

    final weeks = _parseTime(this, "W");
    final days = _parseTime(this, "D");
    final hours = _parseTime(this, "H");
    final minutes = _parseTime(this, "M");
    final seconds = _parseTime(this, "S");

    return Duration(
      days: days + (weeks * 7),
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  int _parseTime(String duration, String timeUnit) {
    final timeMatch = RegExp(r"\d+" + timeUnit).firstMatch(duration);

    if (timeMatch == null) {
      return 0;
    }
    final timeString = timeMatch.group(0);
    return int.parse(timeString!.substring(0, timeString.length - 1));
  }
}
