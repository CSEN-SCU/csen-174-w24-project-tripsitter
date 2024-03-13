import 'package:flutter/material.dart';
import 'package:tripsitter/classes/hotels.dart';

class HotelInfoDialog extends StatelessWidget {
  final HotelInfo hotel;
  const HotelInfoDialog(this.hotel,{super.key});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Hotel Details"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Hotel: ${hotel.name}"),
          Text("ID: ${hotel.hotelId}"),
        ]
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Close"),
        )
      ],
    );
  }
}