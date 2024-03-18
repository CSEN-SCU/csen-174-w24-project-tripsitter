import 'dart:html';

import 'package:flutter/material.dart';
import 'package:tripsitter/classes/hotels.dart';

class HotelInfoDialog extends StatelessWidget {
  final HotelInfo hotel;
  final HotelOffer? offer;
  const HotelInfoDialog({required this.hotel, this.offer, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Hotel Details"),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hotel: ${hotel.name}"),
            Text("ID: ${hotel.hotelId}\n"),
            if (offer != null)
              Text(
                "More Info: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            if (offer != null) Text(offer!.room?.description?.text ?? "None"),
          ]),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        )
      ],
    );
  }
}
