import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/classes/yelp.dart';
import 'package:tripsitter/helpers/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantSummary extends StatelessWidget {
  final Meal meal;
  final double? price;
  final bool showBooking;
  const RestaurantSummary(
      {required this.meal,
      required this.price,
      this.showBooking = false,
      Key? key})
      : super(key: key);

  YelpRestaurant get restaurant => meal.restaurant;

  @override
  Widget build(BuildContext context) {
    List<UserProfile> profiles = Provider.of<List<UserProfile>>(context);
    bool split = Provider.of<bool>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: summaryHeaderStyle),
                Text(restaurant.categories
                    .map((category) => category.title)
                    .join(", ")),
                Text(restaurant.location.displayAddress.join(", ")),
              ]),
        ),
        if (!split)
          Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: meal.participants
                    .map((e) =>
                        profiles
                            .firstWhereOrNull((profile) => profile.id == e)
                            ?.name ??
                        "")
                    .map((e) => Text(e, textAlign: TextAlign.center))
                    .toList(),
              )),
        SizedBox(
          width: 130,
          child: Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(meal.restaurant.price == null
                  ? " "
                  : "${meal.restaurant.price}"),
              if (showBooking)
                ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 0))),
                  onPressed: () {
                    launchUrl(Uri.parse(meal.restaurant.url));
                  },
                  child: const Text("Reserve On Yelp"),
                ),
            ],
          )),
        )
      ]),
    );
  }
}
