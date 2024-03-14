import 'package:collection/collection.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';

class HotelQuery {
  String? cityCode;
  double? latitude;
  double? longitude;
  String checkInDate;
  String checkOutDate;
  int adults;

  HotelQuery({
    this.cityCode,
    this.latitude,
    this.longitude,
    required this.checkInDate,
    required this.checkOutDate,
    required this.adults,
  });

  Map<String, dynamic> toJson() {
    Map<String,dynamic> map = {
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'adults': adults.toString(),
    };
    if (cityCode != null) {
      map['cityCode'] = cityCode;
    }
    if (cityCode == null && latitude != null && latitude != null) {
      map['latitude'] = latitude.toString();
      map['longitude'] = longitude.toString();
    }
    return map;
  }
}

class HotelOption {
  final String type;
  final HotelInfo hotel;
  final bool available;
  final List<HotelOffer> offers;
  final String self;

  const HotelOption({required this.type, required this.hotel, required this.available, required this.offers, required this.self});

  factory HotelOption.fromJson(Map<String, dynamic> json) {
    return HotelOption(
      type: json['type'],
      hotel: HotelInfo.fromJson(json['hotel']),
      available: json['available'],
      offers: (json['offers'] as List).map((offer) => HotelOffer.fromJson(offer)).toList(),
      self: json['self'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'hotel': hotel.toJson(),
      'available': available,
      'offers': offers.map((offer) => offer.toJson()).toList(),
      'self': self,
    };
  }
}

class HotelInfo {
  final String type;
  final String hotelId;
  final String chainCode;
  final String dupeId;
  final String name;
  final String cityCode;
  final double? latitude;
  final double? longitude;
  final List<TripComment> comments;

  const HotelInfo({
    required this.type,
    required this.hotelId,
    required this.chainCode,
    required this.dupeId,
    required this.name,
    required this.cityCode,
    required this.latitude,
    required this.longitude,
    required this.comments
  });

  factory HotelInfo.fromJson(Map<String, dynamic> json) {
    return HotelInfo(
      type: json['type'],
      hotelId: json['hotelId'],
      chainCode: json['chainCode'],
      dupeId: json['dupeId'],
      name: json['name'],
      cityCode: json['cityCode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      comments: json["comments"] != null ? List<TripComment>.from(json["comments"].map((x) => TripComment.fromJson(x))) : List.empty(growable: true),
    );
  }

  Map<String, dynamic> toJson({bool includeComments = true}) {
    Map<String,dynamic> json = {
      'type': type,
      'hotelId': hotelId,
      'chainCode': chainCode,
      'dupeId': dupeId,
      'name': name,
      'cityCode': cityCode,
      'latitude': latitude,
      'longitude': longitude,
    };
    if(includeComments){
      json['comments'] = comments.map((comment) => comment.toJson()).toList();
    }
    return json;
  }

  Future<void> addComment(TripComment comment) async {
    comments.add(comment);
  }

  Future<void> removeComment(TripComment comment) async {
    comments.remove(comment);
  }
}

class HotelOffer {
  final String id;
  final String checkInDate;
  final String checkOutDate;
  final String rateCode;
  final HotelRateFamily? rateFamilyEstimated;
  final HotelRoom? room;
  final HotelGuests guests;
  final HotelPrice price;
  final HotelPolicies? policies;
  final String self;

  @override
  bool operator ==(other) {
    return identical(this, other) || (other is HotelOffer && other.id == id);
  }

  const HotelOffer({
    required this.id,
    required this.checkInDate,
    required this.checkOutDate,
    required this.rateCode,
    required this.rateFamilyEstimated,
    required this.room,
    required this.guests,
    required this.price,
    required this.policies,
    required this.self,
  });

  factory HotelOffer.fromJson(Map<String, dynamic> json) {
    return HotelOffer(
      id: json['id'],
      checkInDate: json['checkInDate'],
      checkOutDate: json['checkOutDate'],
      rateCode: json['rateCode'],
      rateFamilyEstimated: json['rateFamilyEstimated'] != null ? HotelRateFamily.fromJson(json['rateFamilyEstimated']) : null,
      room: json['room'] == null ? null : HotelRoom.fromJson(json['room']),
      guests: HotelGuests.fromJson(json['guests']),
      price: HotelPrice.fromJson(json['price']),
      policies: json['policies'] == null ? null : HotelPolicies.fromJson(json['policies']),
      self: json['self'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'rateCode': rateCode,
      'guests': guests.toJson(),
      'price': price.toJson(),
      'self': self,
    };
    if (room != null) {
      json['room'] = room!.toJson();
    }
    if (policies != null) {
      json['policies'] = policies!.toJson();
    }
    if (rateFamilyEstimated != null) {
      json['rateFamilyEstimated'] = rateFamilyEstimated!.toJson();
    }
    return json;
  }
}

class HotelRateFamily {
  final String code;
  final String type;

  const HotelRateFamily({required this.code, required this.type});

  factory HotelRateFamily.fromJson(Map<String, dynamic> json) {
    return HotelRateFamily(
      code: json['code'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
    };
  }
}

class HotelRoom {
  final String type;
  final HotelType? typeEstimated;
  final HotelDescription? description;

  const HotelRoom({required this.type, required this.typeEstimated, required this.description});

  factory HotelRoom.fromJson(Map<String, dynamic> json) {
    return HotelRoom(
      type: json['type'],
      typeEstimated: json['typeEstimated'] == null ? null : HotelType.fromJson(json['typeEstimated']),
      description: json['description'] == null ? null : HotelDescription.fromJson(json['description']),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'type': type,
    };
    if (typeEstimated != null) {
      json['typeEstimated'] = typeEstimated!.toJson();
    }
    if (description != null) {
      json['description'] = description!.toJson();
    }
    return json;
  }
}

class HotelType {
  final int? beds;
  final String? bedType;
  final String? category;

  const HotelType({required this.beds, required this.bedType, required this.category});

  factory HotelType.fromJson(Map<String, dynamic> json) {
    return HotelType(
      beds: json['beds'],
      bedType: json['bedType'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String,dynamic> json = {};
    if (beds != null) {
      json['beds'] = beds;
    }
    if (bedType != null) {
      json['bedType'] = bedType;
    }
    if (category != null) {
      json['category'] = category;
    }
    return json;
  }
}

class HotelDescription {
  final String text;
  final String lang;

  const HotelDescription({required this.text, required this.lang});

  factory HotelDescription.fromJson(Map<String, dynamic> json) {
    return HotelDescription(
      text: json['text'],
      lang: json['lang'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'lang': lang,
    };
  }
}

class HotelGuests {
  final int adults;

  const HotelGuests({required this.adults});

  factory HotelGuests.fromJson(Map<String, dynamic> json) {
    return HotelGuests(
      adults: json['adults'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adults': adults,
    };
  }
}

class HotelPrice {
  final String? currency;
  final String? base;
  final String? total;
  final HotelPriceVariations? variations;

  const HotelPrice({required this.currency, required this.base, required this.total, required this.variations});

  factory HotelPrice.fromJson(Map<String, dynamic> json) {
    return HotelPrice(
      currency: json['currency'],
      base: json['base'],
      total: json['total'],
      variations: json['variations'] != null ? HotelPriceVariations.fromJson(json['variations']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String,dynamic> json = {
      'currency': currency,
      'base': base,
      'total': total,
    };
    if (variations != null) {
      json['variations'] = variations!.toJson();
    }
    return json;
  }
}

class HotelPriceVariations {
  final HotelPriceAverage? average;
  final List<HotelPriceChanges> changes;

  const HotelPriceVariations({required this.average, required this.changes});

  factory HotelPriceVariations.fromJson(Map<String, dynamic> json) {
    return HotelPriceVariations(
      average: json['average'] == null ? null : HotelPriceAverage.fromJson(json['average']),
      changes: ((json['changes'] ?? []) as List).map((change) => HotelPriceChanges.fromJson(change)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String,dynamic> json = {
      'changes': changes.map((change) => change.toJson()).toList(),
    };
    if (average != null) {
      json['average'] = average!.toJson();
    }
    return json;
  }
}

class HotelPriceAverage {
  final String base;

  const HotelPriceAverage({required this.base});

  factory HotelPriceAverage.fromJson(Map<String, dynamic> json) {
    return HotelPriceAverage(
      base: json['base'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base': base,
    };
  }
}

class HotelPriceChanges {
  final String? startDate;
  final String? endDate;
  final String? base;

  const HotelPriceChanges({required this.startDate, required this.endDate, required this.base});

  factory HotelPriceChanges.fromJson(Map<String, dynamic> json) {
    return HotelPriceChanges(
      startDate: json['startDate'],
      endDate: json['endDate'],
      base: json['base'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'base': base,
    };
  }
}

class HotelPolicies {
  final List<HotelCancellations> cancellations;
  final String? paymentType;

  const HotelPolicies({required this.cancellations, required this.paymentType});

  factory HotelPolicies.fromJson(Map<String, dynamic> json) {
    return HotelPolicies(
      cancellations: ((json['cancellations'] ?? []) as List).map((cancellation) => HotelCancellations.fromJson(cancellation)).toList(),
      paymentType: json['paymentType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cancellations': cancellations.map((cancellation) => cancellation.toJson()).toList(),
      'paymentType': paymentType,
    };
  }
}

class HotelCancellations {
  final String? deadline;
  final String? description;
  final String? amount;

  const HotelCancellations({required this.deadline, required this.amount, required this.description});

  factory HotelCancellations.fromJson(Map<String, dynamic> json) {
    return HotelCancellations(
      deadline: json['deadline'],
      description: (json['description'] ?? {})['text'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String,dynamic> json = {};
    if (deadline != null) {
      json['deadline'] = deadline;
    }
    if (description != null) {
      json['description'] = {'text': description};
    }
    if (amount != null) {
      json['amount'] = amount;
    }
    return json;
  }
}

class HotelBooking {
  final String offerId;
  final List<TravelerInfo> guests;

  HotelBooking({
    required this.offerId,
    required this.guests,
  });

  factory HotelBooking.fromHotelGroup(HotelGroup group, List<UserProfile> profiles) {
    List<TravelerInfo> guests = [];
    for(int i = 0; i < group.members.length; i++) {
      UserProfile? p = profiles.firstWhereOrNull((profile) => profile.id == group.members[i]);
      if(p != null) {
        guests.add(TravelerInfo.fromUserProfile(p, i));
      }
    }
    return HotelBooking(
      offerId: group.selectedOffer!.id,
      guests: guests,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'offerId': offerId,
        'guests': guests.map((guest) => guest.toHotelJson()).toList(),
      }
    };
  }
  
}