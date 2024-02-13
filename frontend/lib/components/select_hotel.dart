import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tripsitter/classes/hotels.dart';
import 'package:tripsitter/helpers/api.dart';

class SelectHotel extends StatefulWidget {
  const SelectHotel({super.key});

  @override
  State<SelectHotel> createState() => _SelectHotelState();
}

class _SelectHotelState extends State<SelectHotel> {

  List<HotelOption> hotels = [];

  HotelQuery query = HotelQuery(
    // cityCode: 'SFO',
    latitude: 40.0150,
    longitude: -105.2705,
    checkInDate: '2024-03-03',
    checkOutDate: '2024-03-04',
    adults: 1,
  );

  @override
  void initState() {
    super.initState();
    getHotels();
  }

  void getHotels() async {
    final List<HotelOption> hotelList = await TripsitterApi.getHotels(query);
    setState(() {
      hotels = hotelList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: hotels.map((HotelOption hotel) {
          return ExpansionTile(
            title: Text(hotel.hotel.name),
            trailing: Text('\$${hotel.offers.map((o) => double.parse(o.price.total)).reduce(min)}'),
            children: hotel.offers.map((HotelOffer o) {
              return ListTile(
                title: Text(o.room.description.text),
                subtitle: Text(o.room.typeEstimated.category ?? "${o.room.typeEstimated.beds} beds"),
                trailing: Text('\$${o.price.total}'),
              );
            }).toList(),
          );
        }).toList()
      ),
    );
  }
}