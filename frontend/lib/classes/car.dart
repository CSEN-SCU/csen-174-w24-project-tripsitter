import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:tripsitter/classes/trip.dart';

class RentalCarQuery {
  String name;
  double lat;
  double lon;
  DateTime pickUp;
  DateTime dropOff;

  RentalCarQuery({
    required this.name,
    required this.lat,
    required this.lon,
    required this.pickUp,
    required this.dropOff,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat.toString(),
      'lon': lon.toString(),
      'pickUpDate': DateFormat('yyyy-MM-dd').format(pickUp),
      'dropOffDate': DateFormat('yyyy-MM-dd').format(dropOff),
      'pickUpTime': DateFormat('HH:mm').format(pickUp),
      'dropOffTime': DateFormat('HH:mm').format(dropOff),
    };
  }
}

class RentalCarOffer {
  final List<TripComment> comments;
  final String sipp;
  final int puRnId;
  final String guid;
  final String bookingPanelOptionGuid;
  final RentalCarAdds adds;
  final String pu;
  final double score;
  final double newScore;
  final int vndrId;
  final String vndr;
  final String doo;
  final int bags;
  final double price;
  final String prvId;
  final String carName;
  final String originalCarName;
  final RentalCarGroupInfo group;
  final String dplnk;
  final int doRnId;
  final String pickupMethod;
  final String officeId;
  final VndrRating vndrRating;
  final int seat;
  final RentalCarProvider provider;

  RentalCarOffer({
    required this.sipp,
    required this.puRnId,
    required this.guid,
    required this.bookingPanelOptionGuid,
    required this.adds,
    required this.pu,
    required this.score,
    required this.newScore,
    required this.vndrId,
    required this.vndr,
    required this.doo,
    required this.bags,
    required this.price,
    required this.prvId,
    required this.carName,
    required this.originalCarName,
    required this.group,
    required this.dplnk,
    required this.doRnId,
    required this.pickupMethod,
    required this.officeId,
    required this.vndrRating,
    required this.seat,
    required this.provider,
    required this.comments,
  });

  factory RentalCarOffer.fromJson(Map<String, dynamic> json) => RentalCarOffer(
        sipp: json["sipp"],
        puRnId: json["pu_rn_id"],
        guid: json["guid"],
        comments: json["comments"] != null ? List<TripComment>.from(json["comments"].map((x) => TripComment.fromJson(x))) : List.empty(growable: true),
        bookingPanelOptionGuid: json["booking_panel_option_guid"],
        adds: RentalCarAdds.fromJson(json["adds"]),
        pu: json["pu"],
        score: json["score"].toDouble(),
        newScore: json["new_score"].toDouble(),
        vndrId: json["vndr_id"],
        vndr: json["vndr"],
        doo: json["do"],
        bags: json["bags"],
        price: json["price"].toDouble(),
        prvId: json["prv_id"],
        carName: json["car_name"],
        originalCarName: json["original_car_name"],
        group: RentalCarGroupInfo.fromJson(json["group"]),
        dplnk: json["dplnk"],
        doRnId: json["do_rn_id"],
        pickupMethod: json["pickup_method"],
        officeId: json["office_id"],
        vndrRating: VndrRating.fromJson(json["vndr_rating"]),
        seat: json["seat"],
        provider: RentalCarProvider.fromJson(json["provider"]),
      );

  Map<String, dynamic> toJson({bool includeComments = true}){
    Map<String,dynamic> json = {
        "sipp": sipp,
        "pu_rn_id": puRnId,
        "guid": guid,
        "booking_panel_option_guid": bookingPanelOptionGuid,
        "adds": adds.toJson(),
        "pu": pu,
        "score": score,
        "new_score": newScore,
        "vndr_id": vndrId,
        "vndr": vndr,
        "do": doo,
        "bags": bags,
        "price": price,
        "prv_id": prvId,
        "car_name": carName,
        "original_car_name": originalCarName,
        "group": group.toJson(),
        "dplnk": dplnk,
        "do_rn_id": doRnId,
        "pickup_method": pickupMethod,
        "office_id": officeId,
        "vndr_rating": vndrRating.toJson(),
        "seat": seat,
        "provider": provider.toJson(),
      };
    if(includeComments){
      json["comments"] = comments.map((e) => e.toJson()).toList();
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

class RentalCarAdds {
  final bool unlimMlg;

  RentalCarAdds({
    required this.unlimMlg,
  });

  factory RentalCarAdds.fromJson(Map<String, dynamic> json) => RentalCarAdds(
        unlimMlg: json["unlim_mlg"],
      );

  Map<String, dynamic> toJson() => {
        "unlim_mlg": unlimMlg,
      };
}

class RentalCarGroupInfo {
  final String sippCode;
  final String carName;
  final bool ac;
  final int quotesCount;
  final String img;
  final double maxScore;
  final int maxSeats;
  final double minPrice;
  final double meanPrice;
  final String doors;
  final int maxBags;
  final String trans;
  final bool fairFuel;
  final String cls;
  final String pickupMethod;
  final String searchResultsOptionGuid;

  RentalCarGroupInfo({
    required this.sippCode,
    required this.carName,
    required this.ac,
    required this.quotesCount,
    required this.img,
    required this.maxScore,
    required this.maxSeats,
    required this.minPrice,
    required this.meanPrice,
    required this.doors,
    required this.maxBags,
    required this.trans,
    required this.fairFuel,
    required this.cls,
    required this.pickupMethod,
    required this.searchResultsOptionGuid,
  });

  factory RentalCarGroupInfo.fromJson(Map<String, dynamic> json) {
    return RentalCarGroupInfo(
      sippCode: json["sippCode"],
      carName: json["car_name"],
      ac: json["ac"],
      quotesCount: json["quotes_count"],
      img: json["img"],
      maxScore: json["max_score"].toDouble(),
      maxSeats: json["max_seats"],
      minPrice: json["min_price"].toDouble(),
      meanPrice: json["mean_price"].toDouble(),
      doors: json["doors"],
      maxBags: json["max_bags"],
      trans: json["trans"],
      fairFuel: json["fair_fuel"],
      cls: json["cls"],
      pickupMethod: json["pickup_method"],
      searchResultsOptionGuid: json["search_results_option_guid"],
    );
  }

  Map<String, dynamic> toJson() => {
        "sippCode": sippCode,
        "car_name": carName,
        "ac": ac,
        "quotes_count": quotesCount,
        "img": img,
        "max_score": maxScore,
        "max_seats": maxSeats,
        "min_price": minPrice,
        "mean_price": meanPrice,
        "doors": doors,
        "max_bags": maxBags,
        "trans": trans,
        "fair_fuel": fairFuel,
        "cls": cls,
        "pickup_method": pickupMethod,
        "search_results_option_guid": searchResultsOptionGuid,
      };
}

class RentalCarProvider {
  final double rating;
  final bool optimisedForMobile;
  final int reviews;
  final bool facilitatedBookingEnabled;
  final String providerName;
  final bool errored;
  final bool inProgress;

  RentalCarProvider({
    required this.rating,
    required this.optimisedForMobile,
    required this.reviews,
    required this.facilitatedBookingEnabled,
    required this.providerName,
    required this.errored,
    required this.inProgress,
  });

  factory RentalCarProvider.fromJson(Map<String, dynamic> json) => RentalCarProvider(
        rating: json["rating"].toDouble(),
        optimisedForMobile: json["optimised_for_mobile"],
        reviews: json["reviews"],
        facilitatedBookingEnabled: json["facilitated_booking_enabled"],
        providerName: json["provider_name"],
        errored: json["errored"],
        inProgress: json["in_progress"],
      );

  Map<String, dynamic> toJson() => {
        "rating": rating,
        "optimised_for_mobile": optimisedForMobile,
        "reviews": reviews,
        "facilitated_booking_enabled": facilitatedBookingEnabled,
        "provider_name": providerName,
        "errored": errored,
        "in_progress": inProgress,
      };
}

class VndrRating {
  final double overallRating;
  final double carCondition;
  final double carsKeptClean;
  final double easyPickup;
  final double service;
  final String ratingType;
  final String ratingDesc;

  VndrRating({
    required this.overallRating,
    required this.carCondition,
    required this.carsKeptClean,
    required this.easyPickup,
    required this.service,
    required this.ratingType,
    required this.ratingDesc,
  });

  factory VndrRating.fromJson(Map<String, dynamic> json) => VndrRating(
        overallRating: json["overall_rating"].toDouble(),
        carCondition: json["car_condition"].toDouble(),
        carsKeptClean: json["cars_kept_clean"].toDouble(),
        easyPickup: json["easy_pickup"].toDouble(),
        service: json["service"].toDouble(),
        ratingType: json["rating_type"],
        ratingDesc: json["rating_desc"],
      );

  Map<String, dynamic> toJson() => {
        "overall_rating": overallRating,
        "car_condition": carCondition,
        "cars_kept_clean": carsKeptClean,
        "easy_pickup": easyPickup,
        "service": service,
        "rating_type": ratingType,
        "rating_desc": ratingDesc,
      };
}