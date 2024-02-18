class Airport {
  final String iataCode;
  final String name;
  final String size;
  final int scale;
  final double lat;
  final double lon;

  Airport({
    required this.iataCode,
    required this.name,
    required this.size,
    required this.scale,
    required this.lat,
    required this.lon,
  });

  static Airport fromArray(List<dynamic> e) {
    return Airport(
      iataCode: e[0],
      name: e[2],
      size: e[1],
      scale: int.parse(e[3].toString()),
      lat: double.parse(e[4].toString()),
      lon: double.parse(e[5].toString()),
    );
  }
}