import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tripsitter/classes/hotels.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/hotels/hotel_info_dialog.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/formatters.dart';

class HotelOptions extends StatefulWidget {
  final Trip trip;
  final HotelGroup? currentGroup;
  final Function setState;
  const HotelOptions({required this.currentGroup, required this.setState, required this.trip, super.key});

  @override
  State<HotelOptions> createState() => _HotelOptionsState();
}

class _HotelOptionsState extends State<HotelOptions> {

  @override
  void initState() {
    super.initState();
    getHotels();
  }

  List<HotelOption> hotels = [];

  void getHotels() async {
    HotelQuery query = HotelQuery(
      cityCode: "SFO",
      latitude: 37.7749,
      longitude: -122.4194,
      checkInDate: "2024-04-01",
      checkOutDate: "2024-04-03",
      adults: 1,
    );
    hotels = await TripsitterApi.getHotels(query);
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.currentGroup == null ? Center(
      child: Text("Select or create a group to choose a hotel")
    ) : Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Text("Hotels for ${widget.currentGroup!.name}", style: Theme.of(context).textTheme.displayMedium?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
          for (int i = 0; i < hotels.length; i++)
            ExpansionTile(
              title: ListTile(
                // leading: Image.network("https://logos.skyscnr.com/images/carhire/sippmaps/${car.group.img}", width: 80, height: 80),
                title: Text("${hotels[i].hotel.name}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.info),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return HotelInfoDialog(hotels[i].hotel);
                          }
                        );
                      },
                    ),
                  ]
                ),
                subtitle: Text("From \$${hotels[i].offers.map((e) => double.parse(e.price.total)).reduce(min)}"),
              ),
              children: hotels[i].offers.map((HotelOffer o) => ListTile(
                subtitle: Text(o.room.description.text),
                title: Text("\$${o.price.total}"),
                trailing: ElevatedButton(
                  onPressed: () async {
                    if(widget.currentGroup!.infos.map((c) => c.hotelId).contains(hotels[i].hotel.hotelId)) {
                      await widget.currentGroup!.removeOption(i);
                    } else {
                      await widget.currentGroup!.addOption(hotels[i].hotel, o);
                    }
                    widget.setState();
                  },
                  child: Text("Select${widget.currentGroup!.infos.map((c) => c.hotelId).contains(hotels[i].hotel.hotelId) ? "ed" : ""}"),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }
}