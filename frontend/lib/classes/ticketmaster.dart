import 'dart:core';

import 'package:intl/intl.dart';

class TicketmasterQuery {
  String? query;
  double lat;
  double long;
  DateTime startDateTime;
  DateTime endDateTime;

  TicketmasterQuery({
    this.query,
    required this.lat,
    required this.long,
    required this.startDateTime,
    required this.endDateTime,
  });

  Map<String, dynamic> toJson() {
    DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    return {
      'query': query,
      'lat': lat.toString(),
      'long': long.toString(),
      'startDateTime': "${formatter.format(startDateTime.toUtc())}Z",
      'endDateTime': "${formatter.format(endDateTime.toUtc())}Z",
    };
  }
}

class TicketmasterEvent {
  final String? ageRestrictions;
  final String id;
  final String name;
  final int? ticketLimit;
  final List<TicketmasterClassification> classifications;
  final TicketmasterDateTime startTime;
  final TicketmasterDateTime? doorsTime;
  final List<TicketmasterImage> images;
  final String locale;
  final TicketmasterEventInfo info;
  final List<TicketmasterPromoter> promoters;
  final List<TicketmasterPrice> prices;
  final String? seatmapUrl;
  final TicketmasterSales? sales;
  final String type;
  final double? distance;
  final String? distanceUnits;
  final String? url;
  final List<TicketmasterVenue> venues;
  final List<TicketmasterAttraction> attractions;

  TicketmasterEvent({
    this.ageRestrictions,
    required this.id,
    required this.name,
    this.ticketLimit,
    required this.classifications,
    required this.startTime,
    required this.doorsTime,
    required this.images,
    required this.locale,
    required this.info,
    required this.promoters,
    required this.prices,
    this.seatmapUrl,
    this.sales,
    required this.type,
    this.distance,
    this.distanceUnits,
    this.url,
    required this.venues,
    required this.attractions,
  });

  factory TicketmasterEvent.fromJson(Map<String, dynamic> json) {
    List<TicketmasterClassification> classifications = [];
    for (var classification in json['classifications'] ?? []) {
      classifications.add(TicketmasterClassification.fromJson(classification));
    }

    List<TicketmasterImage> images = [];
    for (var image in json['images'] ?? []) {
      images.add(TicketmasterImage.fromJson(image));
    }

    List<TicketmasterPromoter> promoters = [];
    for (var promoter in json['promoters'] ?? []) {
      promoters.add(TicketmasterPromoter.fromJson(promoter));
    }

    List<TicketmasterPrice> prices = [];
    for (var price in json['prices'] ?? []) {
      prices.add(TicketmasterPrice.fromJson(price));
    }

    List<TicketmasterVenue> venues = [];
    for (var venue in json['venues'] ?? []) {
      venues.add(TicketmasterVenue.fromJson(venue));
    }

    List<TicketmasterAttraction> attractions = [];
    for (var attraction in json['attractions'] ?? []) {
      attractions.add(TicketmasterAttraction.fromJson(attraction));
    }

    return TicketmasterEvent(
      ageRestrictions: json['ageRestrictions'],
      id: json['id'],
      name: json['name'],
      ticketLimit: json['ticketLimit'],
      classifications: classifications,
      startTime: TicketmasterDateTime.fromJson(json['startTime']),
      doorsTime: json['doorsTime'] != null ? TicketmasterDateTime.fromJson(json['doorsTime']) : null,
      images: images,
      locale: json['locale'],
      info: TicketmasterEventInfo.fromJson(json['info']),
      promoters: promoters,
      prices: prices,
      seatmapUrl: json['seatmapUrl'],
      sales: json['sales'] != null ? TicketmasterSales.fromJson(json['sales']) : null,
      type: json['type'],
      distance: json['distance'],
      distanceUnits: json['distanceUnits'],
      url: json['url'],
      venues: venues,
      attractions: attractions,
    );
  }

}

class TicketmasterClassification {
  final bool primary;
  final bool family;
  final TicketmasterGenre? genre;
  final TicketmasterGenre? subGenre;
  final TicketmasterGenre? segment;
  final TicketmasterGenre? type;
  final TicketmasterGenre? subType;

  TicketmasterClassification({
    required this.primary,
    required this.family,
    required this.genre,
    required this.subGenre,
    required this.segment,
    required this.type,
    required this.subType,
  });

  factory TicketmasterClassification.fromJson(Map<String, dynamic> json) {
    return TicketmasterClassification(
      primary: json['primary'],
      family: json['family'],
      genre: json['genre'] != null ? TicketmasterGenre.fromJson(json['genre']) : null,
      subGenre: json['subGenre'] != null ? TicketmasterGenre.fromJson(json['subGenre']) : null,
      segment: json['segment'] != null ? TicketmasterGenre.fromJson(json['segment']) : null,
      type: json['type'] != null ? TicketmasterGenre.fromJson(json['type']) : null,
      subType: json['subType'] != null ? TicketmasterGenre.fromJson(json['subType']) : null,
    );
  }
}

class TicketmasterGenre {
  String id;
  String name;

  TicketmasterGenre({
    required this.id,
    required this.name,
  });

  factory TicketmasterGenre.fromJson(Map<String, dynamic> json) {
    return TicketmasterGenre(
      id: json['id'],
      name: json['name'],
    );
  }
}

class TicketmasterDateTime {
  final String? localDate;
  final String? localTime;
  final DateTime? dateTimeUtc;
  final bool? dateTBD;
  final bool? dateTBA;
  final bool? timeTBA;
  final bool? noSpecificTime;

  TicketmasterDateTime({
    required this.localDate,
    required this.localTime,
    required this.dateTimeUtc,
    this.dateTBD,
    this.dateTBA,
    this.timeTBA,
    this.noSpecificTime,
  });

  factory TicketmasterDateTime.fromJson(Map<String, dynamic> json) {
    return TicketmasterDateTime(
      localDate: json['localDate'],
      localTime: json['localTime'],
      dateTimeUtc: DateTime.tryParse(json['dateTime'] ?? ""),
      dateTBD: json['dateTBD'],
      dateTBA: json['dateTBA'],
      timeTBA: json['timeTBA'],
      noSpecificTime: json['noSpecificTime'],
    );
  }
}

class TicketmasterImage {
  final bool fallback;
  final String url;

  TicketmasterImage({
    required this.fallback,
    required this.url,
  });

  factory TicketmasterImage.fromJson(Map<String, dynamic> json) {
    return TicketmasterImage(
      fallback: json['fallback'],
      url: json['url'],
    );
  }
}

class TicketmasterEventInfo {
  final String? infoStr;
  final String? pleaseNote;
  final String? ticketLimit;

  TicketmasterEventInfo({
    required this.infoStr,
    this.pleaseNote,
    this.ticketLimit,
  });

  factory TicketmasterEventInfo.fromJson(Map<String, dynamic> json) {
    return TicketmasterEventInfo(
      infoStr: json['infoStr'],
      pleaseNote: json['pleaseNote'],
      ticketLimit: json['ticketLimit'],
    );
  }
}

class TicketmasterPromoter {
  final String id;
  final String name;
  final String description;

  TicketmasterPromoter({
    required this.id,
    required this.name,
    required this.description,
  });

  factory TicketmasterPromoter.fromJson(Map<String, dynamic> json) {
    return TicketmasterPromoter(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class TicketmasterPrice {
  final String type;
  final String currency;
  final double min;
  final double max;

  TicketmasterPrice({
    required this.type,
    required this.currency,
    required this.min,
    required this.max,
  });

  factory TicketmasterPrice.fromJson(Map<String, dynamic> json) {
    return TicketmasterPrice(
      type: json['type'],
      currency: json['currency'],
      min: json['min'],
      max: json['max'],
    );
  }
}

class TicketmasterSales {
  final TicketmasterSale public;
  final List<TicketmasterSale> presales;

  TicketmasterSales({
    required this.public,
    required this.presales,
  });

  factory TicketmasterSales.fromJson(Map<String, dynamic> json) {
    List<TicketmasterSale> presales = [];
    for (var presale in json['presales'] ?? []) {
      presales.add(TicketmasterSale.fromJson(presale));
    }

    return TicketmasterSales(
      public: TicketmasterSale.fromJson(json['public']),
      presales: presales,
    );
  }
}

class TicketmasterSale {
  final String? startDateTime;
  final String? endDateTime;
  final String? name;
  final bool? startTBA;
  final bool? startTBD;

  TicketmasterSale({
    required this.startDateTime,
    required this.endDateTime,
    this.name,
    required this.startTBA,
    required this.startTBD,
  });

  factory TicketmasterSale.fromJson(Map<String, dynamic> json) {
    return TicketmasterSale(
      startDateTime: json['startDateTime'],
      endDateTime: json['endDateTime'],
      name: json['name'],
      startTBA: json['startTBA'],
      startTBD: json['startTBD'],
    );
  }
}

class TicketmasterVenue {
  final String id;
  final String name;
  final String? addressLine1;
  final String? addressLine2;
  final String? addressLine3;
  final String? city;
  final String? state;
  final String? stateCode;
  final String? country;
  final String? countryCode;
  final double distance;
  final String? distanceUnits;
  final String timezone;
  final String? postalCode;
  final List<TicketmasterImage> images;
  final double latitude;
  final double longitude;
  final String? url;

  TicketmasterVenue({
    required this.id,
    required this.name,
    this.addressLine1,
    this.addressLine2,
    this.addressLine3,
    this.city,
    this.state,
    this.stateCode,
    this.country,
    this.countryCode,
    required this.distance,
    this.distanceUnits,
    required this.timezone,
    this.postalCode,
    required this.images,
    required this.latitude,
    required this.longitude,
    this.url,
  });

  factory TicketmasterVenue.fromJson(Map<String, dynamic> json) {
    List<TicketmasterImage> images = [];
    for (var image in json['images'] ?? []) {
      images.add(TicketmasterImage.fromJson(image));
    }

    return TicketmasterVenue(
      id: json['id'],
      name: json['name'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      addressLine3: json['addressLine3'],
      city: json['city'],
      state: json['state'],
      stateCode: json['stateCode'],
      country: json['country'],
      countryCode: json['countryCode'],
      distance: json['distance'],
      distanceUnits: json['distanceUnits'],
      timezone: json['timezone'],
      postalCode: json['postalCode'],
      images: images,
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      url: json['url'],
    );
  }
}

class TicketmasterAttraction {
  final List<TicketmasterClassification> classifications;
  final String id;
  final List<TicketmasterImage> images;
  final TicketmasterLinks? externalLinks;
  final String locale;
  final String name;
  final String url;

  TicketmasterAttraction({
    required this.classifications,
    required this.id,
    required this.images,
    this.externalLinks,
    required this.locale,
    required this.name,
    required this.url,
  });

  factory TicketmasterAttraction.fromJson(Map<String, dynamic> json) {
    List<TicketmasterClassification> classifications = [];
    for (var classification in json['classifications']) {
      classifications.add(TicketmasterClassification.fromJson(classification));
    }

    List<TicketmasterImage> images = [];
    for (var image in json['images']) {
      images.add(TicketmasterImage.fromJson(image));
    }

    return TicketmasterAttraction(
      classifications: classifications,
      id: json['id'],
      images: images,
      externalLinks: json['externalLinks'] != null ? TicketmasterLinks() : null,
      locale: json['locale'],
      name: json['name'],
      url: json['url'],
    );
  }
}

class TicketmasterLinks {
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? wiki;
  final String? homepage;

  TicketmasterLinks({
    this.facebook,
    this.twitter,
    this.instagram,
    this.wiki,
    this.homepage,
  });

  factory TicketmasterLinks.fromJson(Map<String, dynamic> json) {
    return TicketmasterLinks(
      facebook: json['facebook'].isNotEmpty ? json['facebook'][0]?.url : null,
      twitter: json['twitter'].isNotEmpty ? json['twitter'][0]?.url : null,
      instagram: json['instagram'].isNotEmpty ? json['instagram'][0]?.url : null,
      wiki: json['wiki'].isNotEmpty ? json['wiki'][0]?.url : null,
      homepage: json['homepage'].isNotEmpty ? json['homepage'][0]?.url : null,
    );
  }
}