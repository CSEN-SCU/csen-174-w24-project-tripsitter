class FlightsQuery {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final DateTime returnDate;
  final int adults;
  final int? children;
  final String? currency;
  final TravelClass? travelClass;

  FlightsQuery({
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.returnDate,
    required this.adults,
    this.children,
    this.currency,
    this.travelClass,
  });

  Map<String, dynamic> toJson() {
    Map<String,dynamic> json = {
      'origin': origin,
      'destination': destination,
      'departureDate': departureDate.toIso8601String().split('T')[0],
      'returnDate': returnDate.toIso8601String().split('T')[0],
      'adults': adults.toString(),
    };
    if (children != null) {
      json['children'] = children.toString();
    }
    if (currency != null) {
      json['currency'] = currency;
    }
    if (travelClass != null) {
      switch(travelClass) {
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

class FlightInfo {
  final String id;
  final bool oneWay;
  final int seats;
  final double price;
  final String priceCurrency;
  final FlightPrice priceInfo;
  final List<FlightItinerary> itineraries;
  final List<String> airlines;

  FlightInfo({
    required this.id,
    required this.oneWay,
    required this.seats,
    required this.price,
    required this.priceCurrency,
    required this.priceInfo,
    required this.itineraries,
    required this.airlines,
  });

  factory FlightInfo.fromJson(Map<String, dynamic> json) {
    return FlightInfo(
      id: json['id'],
      oneWay: json['oneWay'],
      seats: json['seats'],
      price: json['price'],
      priceCurrency: json['priceCurrency'],
      priceInfo: FlightPrice.fromJson(json['priceInfo']),
      itineraries: json['itineraries'].map<FlightItinerary>((i) => FlightItinerary.fromJson(i)).toList(),
      airlines: json['airlines'].cast<String>(),
    );
  }
}

class FlightItinerary {
  final Duration duration;
  final List<FlightSegment> segments;
  final String id;
  final List<String> offerIds;
  final bool isOneWay;
  final int seats;
  final double minPrice;
  final String priceCurrency;
  final FlightPrice priceInfo;
  final List<FlightItinerary> next;
  final List<String> offeredBy;

  FlightItinerary({
    required this.duration,
    required this.segments,
    required this.id,
    required this.minPrice,
    required this.offerIds,
    required this.isOneWay,
    required this.seats,
    required this.priceCurrency,
    required this.priceInfo,
    required this.next,
    required this.offeredBy,
  });

  factory FlightItinerary.fromJson(Map<String, dynamic> json) {
    List<FlightSegment> segments = json['segments'].map<FlightSegment>((s) => FlightSegment.fromJson(s)).toList();
    return FlightItinerary(
      duration: DurationJson.fromJson(json['duration']).toDuration(),
      segments: segments,
      id: segments.map((s) => s.id).join(","),
      offerIds: json['offerIds'].cast<String>(),
      isOneWay: json['isOneWay'],
      seats: json['seats'],
      minPrice: json['minPrice'],
      priceCurrency: json['priceCurrency'],
      priceInfo: FlightPrice.fromJson(json['priceInfo']),
      next: json['next'].map<FlightItinerary>((i) => FlightItinerary.fromJson(i)).toList(),
      offeredBy: json['offeredBy'].cast<String>(),
    );
  }
}

class FlightPrice {
  final double base;
  final double grandTotal;
  final double total;
  final String currency;

  FlightPrice({
    required this.base,
    required this.grandTotal,
    required this.total,
    required this.currency,
  });

  factory FlightPrice.fromJson(Map<String, dynamic> json) {
    return FlightPrice(
      base: double.parse(json['base']),
      grandTotal: double.parse(json['grandTotal']),
      total: double.parse(json['total']),
      currency: json['currency'],
    );
  }

}

class FlightSegment {
  final String departureAirport;
  final String? departureTerminal;
  final DateTime departureTime;
  final String arrivalAirport;
  final String? arrivalTerminal;
  final DateTime arrivalTime;
  // final String airlineOffering;
  final String airlineOperating;
  final List<String> flightNumbers;
  final String aircraft;
  final Duration duration;
  final String id;
  final int numberOfStops;

  FlightSegment({
    required this.departureAirport,
    this.departureTerminal,
    required this.departureTime,
    required this.arrivalAirport,
    this.arrivalTerminal,
    required this.arrivalTime,
    // required this.airlineOffering,
    required this.airlineOperating,
    required this.flightNumbers,
    required this.aircraft,
    required this.duration,
    required this.id,
    required this.numberOfStops,
  });

  factory FlightSegment.fromJson(Map<String, dynamic> json) {
    return FlightSegment(
      departureAirport: json['departureAirport'],
      departureTerminal: json['departureTerminal'],
      departureTime: DateTime.parse(json['departureTime']),
      arrivalAirport: json['arrivalAirport'],
      arrivalTerminal: json['arrivalTerminal'],
      arrivalTime: DateTime.parse(json['arrivalTime']),
      // airlineOffering: json['airlineOffering'],
      airlineOperating: json['airlineOperating'],
      flightNumbers: json['flightNumbers'].cast<String>(),
      aircraft: json['aircraft'],
      duration: DurationJson.fromJson(json['duration']).toDuration(),
      id: json['id'],
      numberOfStops: json['numberOfStops'],
    );
  }
}

class DurationJson {
  final int years;
  final int months;
  final int weeks;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  DurationJson({
    required this.years,
    required this.months,
    required this.weeks,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  factory DurationJson.fromJson(Map<String, dynamic> json) {
    return DurationJson(
      years: json['years'] ?? 0,
      months: json['months'] ?? 0,
      weeks: json['weeks'] ?? 0,
      days: json['days'] ?? 0,
      hours: json['hours'] ?? 0,
      minutes: json['minutes'] ?? 0,
      seconds: json['seconds'] ?? 0,
    );
  }

  Duration toDuration() {
    return Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
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

  AirportInfo({
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

  AirlineInfo({
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