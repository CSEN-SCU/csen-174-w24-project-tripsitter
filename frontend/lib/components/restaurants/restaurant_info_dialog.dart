
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/yelp.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantPopup extends StatelessWidget {
  final YelpRestaurant restaurant;
  const RestaurantPopup(this.restaurant, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: ListBody(children: [
          Wrap(children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name),
                  Row(
                    children: [
                      for (var category in restaurant.categories)
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Chip(label: Text(category.title)),
                        )
                    ],
                  ),
                  Text(restaurant.displayPhone ?? "Phone not available"),
                  Text(restaurant.location.displayAddress.join(', ')),
                  Text(restaurant.price ?? "Price not available"),
                  Text("Rating: ${restaurant.rating.toString()}"),
                ],
              ),
            ),
              const SizedBox(width: 100),
              Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: Image.network(restaurant.imageUrl)),
              )
          ]),
        ]),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Uri uri = Uri.parse(restaurant.url);
            launchUrl(uri);
          },
          child: const Text('View Restaurant on Yelp'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
