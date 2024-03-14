import 'dart:convert';

import 'package:flutter/foundation.dart';

class YelpRestaurant {
  String id;
  String alias;
  String name;
  String imageUrl;
  bool isClosed;
  String url;
  int reviewCount;
  List<YelpCategory> categories;
  double rating;
  YelpCoordinates coordinates;
  List<String> transactions;
  String? price;
  YelpLocation location;
  String? phone;
  String? displayPhone;
  double distance;

  YelpRestaurant({
    required this.id,
    required this.alias,
    required this.name,
    required this.imageUrl,
    required this.isClosed,
    required this.url,
    required this.reviewCount,
    required this.categories,
    required this.rating,
    required this.coordinates,
    required this.transactions,
    required this.price,
    required this.location,
    required this.phone,
    required this.displayPhone,
    required this.distance,
  });

  factory YelpRestaurant.fromJson(Map<String, dynamic> json){
    // debugPrint(json.toString());
    return YelpRestaurant(
      id: json["id"],
      alias: json["alias"],
      name: json["name"],
      imageUrl: json["image_url"],
      isClosed: json["is_closed"],
      url: json["url"],
      reviewCount: json["review_count"],
      categories: List<YelpCategory>.from(json["categories"].map((x) => YelpCategory.fromJson(x))),
      rating: json["rating"].toDouble(),
      coordinates: YelpCoordinates.fromJson(json["coordinates"]),
      transactions: List<String>.from(json["transactions"].map((x) => x)),
      price: json["price"],
      location: YelpLocation.fromJson(json["location"]),
      phone: json["phone"],
      displayPhone: json["display_phone"],
      distance: json["distance"].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "alias": alias,
    "name": name,
    "image_url": imageUrl,
    "is_closed": isClosed,
    "url": url,
    "review_count": reviewCount,
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
    "rating": rating,
    "coordinates": coordinates.toJson(),
    "transactions": List<dynamic>.from(transactions.map((x) => x)),
    "price": price,
    "location": location.toJson(),
    "phone": phone,
    "display_phone": displayPhone,
    "distance": distance,
  };
}

class YelpCategory {
  String alias;
  String title;

  YelpCategory({
    required this.alias,
    required this.title,
  });

  factory YelpCategory.fromJson(Map<String, dynamic> json) => YelpCategory(
    alias: json["alias"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "alias": alias,
    "title": title,
  };
}

class YelpCoordinates {
  double latitude;
  double longitude;

  YelpCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory YelpCoordinates.fromJson(Map<String, dynamic> json) => YelpCoordinates(
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

class YelpLocation {
  String address1;
  String? address2;
  String? address3;
  String city;
  String zipCode;
  String country;
  String state;
  List<String> displayAddress;

  YelpLocation({
    required this.address1,
    required this.address2,
    required this.address3,
    required this.city,
    required this.zipCode,
    required this.country,
    required this.state,
    required this.displayAddress,
  });

  factory YelpLocation.fromJson(Map<String, dynamic> json) => YelpLocation(
        address1: json["address1"],
        address2: json["address2"],
        address3: json["address3"],
        city: json["city"],
        zipCode: json["zip_code"],
        country: json["country"],
        state: json["state"],
        displayAddress: List<String>.from(json["display_address"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "address1": address1,
        "address2": address2,
        "address3": address3,
        "city": city,
        "zip_code": zipCode,
        "country": country,
        "state": state,
        "display_address": List<dynamic>.from(displayAddress.map((x) => x)),
      };
}
