import 'package:flutter/material.dart';
import 'package:tripsitter/classes/car.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/formatters.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectCars extends StatefulWidget {
  final Trip trip;
  final List<UserProfile> profiles;
  const SelectCars(this.trip, this.profiles, {super.key});

  @override
  State<SelectCars> createState() => _SelectCarsState();
}

class _SelectCarsState extends State<SelectCars> {

  @override
  void initState() {
    super.initState();
    getCars();
  }

  List<RentalCarOffer> cars = [];

  void getCars() async {
    RentalCarQuery query = RentalCarQuery(
      name: 'San Francisco',
      lat: 37.6193,
      lon: -122.3816,
      pickUp: DateTime(2024, 4, 1, 12, 0),
      dropOff: DateTime(2024, 4, 3, 10, 0),
    );
    cars = await TripsitterApi.searchRentalCars(query);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: constraints.maxWidth * 0.65,
              child: ListView(
                children: [
                  Text("Choose Rental Cars", style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                  for (RentalCarOffer car in cars)
                    ListTile(
                      leading: car.group == null ? const Text("img") : Image.network("https://logos.skyscnr.com/images/carhire/sippmaps/${car.group!.img}", width: 50, height: 50),
                      title: Text("${car.sipp.fromSipp()} (${car.carName} or similar)"),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Uri uri = Uri.parse("https://skyscanner.com${car.dplnk}");
                          launchUrl(uri);
                        },
                        child: Text("View on ${car.provider.providerName}"),
                      ),
                      subtitle: Text("\$${car.price.toStringAsFixed(2)}"),
                    )
                ],
              )
            ),
            Container(
              color: Color.fromARGB(255, 127, 166, 198),
              width: constraints.maxWidth * 0.35,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selected Cars', style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                  ]
                ),
              )
            ),
          ],
        );
      }
    );
  }
}