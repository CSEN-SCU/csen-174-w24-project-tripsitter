

import 'package:flutter/material.dart';
import 'package:tripsitter/classes/car.dart';
import 'package:tripsitter/helpers/formatters.dart';
import 'package:url_launcher/url_launcher.dart';

class CarInfoDialog extends StatelessWidget {
  final RentalCarOffer car;
  const CarInfoDialog(this.car,{super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Car Details"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network("https://logos.skyscnr.com/images/carhire/sippmaps/${car.group.img}", width: 200, height: 200),
          Text("Type: ${car.sipp.fromSipp()} (${car.carName} or similar)"),
          Text("Provider: ${car.provider.providerName}"),
          Text("Bags: ${car.group.maxBags}"),
          Text("Seats: ${car.group.maxSeats}"),
          Text("Pickup at ${car.pu}, Dropoff at ${car.doo}"),
          Text("Price: \$${car.price.toStringAsFixed(2)}"),
          ElevatedButton(
            onPressed: () {
              Uri uri = Uri.parse("https://skyscanner.com${car.dplnk}");
              launchUrl(uri);
            },
            child: Text("View on ${car.provider.providerName}"),
          ),
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