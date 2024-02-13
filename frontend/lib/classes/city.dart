class City {
  final String name;
  final String country;
  final double lat;
  final double lon;

  City({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory City.fromArray(List<dynamic> array) {
    return City(
      name: array[0],
      lat: double.parse(array[1].toString()),
      lon: double.parse(array[2].toString()),
      country: array[3]
    );
  }

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'],
      lat: json['lat'],
      lon: json['lon'],
      country: json['country']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lon': lon,
      'country': country
    };
  }
}