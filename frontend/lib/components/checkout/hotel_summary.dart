import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/styles.dart';

class HotelSummary extends StatelessWidget {
  final HotelGroup hotel;
  final double? price;
  HotelSummary({required this.hotel, required this.price, super.key});
  final DateFormat dateFormatter = DateFormat("E, MMM d, y");
  final DateFormat timeFormatter = DateFormat("h:mm a");

  @override
  Widget build(BuildContext context) {
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    bool split = Provider.of<bool>(context);
    if (hotel.selectedInfo == null || hotel.selectedOffer == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${hotel.name}${hotel.pnr != null ? " (Confirmation: ${hotel.pnr})" : ""}",
                    style: summaryHeaderStyle),
                Text(hotel.selectedOffer!.checkInDate !=
                        hotel.selectedOffer!.checkOutDate
                    ? "${dateFormatter.format(DateTime.parse(hotel.selectedOffer!.checkInDate))} → ${dateFormatter.format(DateTime.parse(hotel.selectedOffer!.checkOutDate))}"
                    : dateFormatter.format(
                        DateTime.parse(hotel.selectedOffer!.checkInDate))),
                Text(hotel.selectedInfo!.name),
              ]),
        ),
        if (!split)
          Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: hotel.members
                    .map((e) =>
                        profiles
                            .firstWhereOrNull((profile) => profile.id == e)
                            ?.name ??
                        "")
                    .map((e) => Text(
                          e,
                          textAlign: TextAlign.center,
                        ))
                    .toList(),
              )),
        SizedBox(
          width: 130,
          child: Center(
              child: Text(price == null
                  ? "Unknown price"
                  : "\$${price!.toStringAsFixed(2)}")),
        )
      ]),
    );
  }
}
