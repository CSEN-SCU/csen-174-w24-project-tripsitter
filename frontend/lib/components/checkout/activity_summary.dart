import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/ticketmaster.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivitySummary extends StatelessWidget {
  final Activity activity;
  final double? price;
  final bool showBooking;
  const ActivitySummary({required this.activity, required this.price, this.showBooking = false, super.key});

  TicketmasterEvent get event => activity.event;

  @override
  Widget build(BuildContext context) {
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    bool split = Provider.of<bool>(context);
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
                Text(event.name, style: summaryHeaderStyle),
                Text("${event.startTime.getFormattedDate()}, ${event.startTime.getFormattedTime()}"),
                Text(event.venues.firstOrNull?.name ?? "Unknown location"),
              ]
            ),
          ),
          if(!split)
            Expanded(
              flex: 1,
              child: Column(
                children: activity.participants.map((e) => profiles.firstWhere((profile) => profile.id == e).name).map((e) => Text(e)).toList() ,
              )
            ),
          SizedBox(
            width: 130,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price == null ? "Unknown price" : "\$${price!.toStringAsFixed(2)}"),
                  if(showBooking && event.url != null)
                    ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 8, vertical: 0))
                      ),
                      onPressed: () {
                        launchUrl(Uri.parse(event.url!));
                      },
                      child: const Text("Purchase"),
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