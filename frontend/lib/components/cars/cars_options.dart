import 'package:flutter/material.dart';
import 'package:tripsitter/classes/car.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/cars/car_info_dialog.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/formatters.dart';

class CarOptions extends StatefulWidget {
  final RentalCarGroup? currentGroup;
  final Function setState;
  const CarOptions({required this.currentGroup, required this.setState, super.key});

  @override
  State<CarOptions> createState() => _CarOptionsState();
}

class _CarOptionsState extends State<CarOptions> {

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
    return widget.currentGroup == null
      ? Center(child: Text("Select or create a group to choose a rental car"))
      : Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text("Rental Cars for ${widget.currentGroup!.name}", style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    // Determine the background color based on row index
                    Color bgColor = index % 2 == 0 ? Colors.white : Colors.grey[200]!;
                    RentalCarOffer car = cars[index];
                    return Container(
                      color: bgColor, // Apply the background color
                      child: ListTile(
                        leading: Image.network(
                            "https://logos.skyscnr.com/images/carhire/sippmaps/${car.group.img}",
                            width: 80,
                            height: 80),
                        title: Text("${car.sipp.fromSipp()} (${car.carName} or similar)"),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CarInfoDialog(car);
                                    });
                              }),
                          ElevatedButton(
                            child: Text("Select${widget.currentGroup!.options.map((c) => c.guid).contains(car.guid) ? "ed" : ""}"),
                            onPressed: () async {
                              if (widget.currentGroup!.options.map((c) => c.guid).contains(car.guid)) {
                                await widget.currentGroup!.removeOptionById(car.guid);
                              } else {
                                await widget.currentGroup!.addOption(car);
                              }
                              setState(() {});
                              widget.setState();
                            },
                          )
                        ]),
                        subtitle: Text("\$${car.price.toStringAsFixed(2)}"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
  }


}