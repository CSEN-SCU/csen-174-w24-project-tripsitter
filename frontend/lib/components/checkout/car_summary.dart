import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/formatters.dart';
import 'package:tripsitter/helpers/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class CarSummary extends StatelessWidget {
  final RentalCarGroup car;
  final double? price;
  final bool showBooking;
  const CarSummary({required this.car, required this.price, this.showBooking = false, super.key});

  @override
  Widget build(BuildContext context) {
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    bool split = Provider.of<bool>(context);
    if(car.selected == null ) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(car.name, style: summaryHeaderStyle),
                Text("${car.selected!.sipp.fromSipp()} (${car.selected!.carName} or similar)"),
                Text("Pickup at ${car.selected!.provider.providerName} @ ${car.selected!.pu}, Dropoff at ${car.selected!.doo}"),
              ]
            ),
          ),
          if(!split)
            Expanded(
              flex: 1,
              child: Column(
                children: car.members.map((e) => profiles.firstWhereOrNull((profile) => profile.id == e)?.name ?? "").map((e) => Text(e)).toList() ,
              )
            ),
          SizedBox(
            width: 130,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(price == null ? "Unknown price" : "\$${price!.toStringAsFixed(2)}"),
                  if(showBooking)
                    ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 5, vertical: 0))
                      ),
                      onPressed: () {
                        launchUrl(Uri.parse("https://skyscanner.com${car.selected!.dplnk}"));
                      },
                      child: Text("Book on ${car.selected!.provider.providerName}"),
                    ),
                ],
              )
            ),
          )
        ]
      ),
    );
  }
}