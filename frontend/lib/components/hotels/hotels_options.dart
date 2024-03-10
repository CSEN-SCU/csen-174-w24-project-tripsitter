import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripsitter/classes/hotels.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/hotels/hotel_info_dialog.dart';
import 'package:tripsitter/helpers/api.dart';
import 'package:tripsitter/helpers/formatters.dart';
import 'package:google_fonts/google_fonts.dart';

class HotelOptions extends StatefulWidget {
  final Trip trip;
  final HotelGroup? currentGroup;
  final Function setState;
  const HotelOptions(
      {required this.currentGroup,
      required this.setState,
      required this.trip,
      super.key});

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
      latitude: widget.trip.destination.lat,
      longitude: widget.trip.destination.lon,
      checkInDate: DateFormat("yyyy-MM-dd").format(widget.trip.startDate),
      checkOutDate: DateFormat("yyyy-MM-dd").format(widget.trip.endDate),
      adults: 1,
    );
    hotels = await TripsitterApi.getHotels(query);
    // for(HotelOption hotel in hotels) {
    // print(hotel.offers.first.toJson());
    // }
    if (!mounted) return;
    setState(() {});
  }

  String? minPrice(List<HotelOffer> offers) {
    List<String> prices =
        offers.map((o) => o.price.total).whereNotNull().toList();
    return prices.isEmpty
        ? null
        : prices.map((p) => double.parse(p)).reduce(min).toString();
  }

  @override
  Widget build(BuildContext context) {
    return widget.currentGroup == null
        ? Center(child: Text("Select or create a group to choose a hotel"))
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                // Text("Hotels for ${widget.currentGroup!.name}",
                //     style: Theme.of(context).textTheme.displayMedium?.copyWith(
                //         decoration: TextDecoration.underline,
                //         fontWeight: FontWeight.bold)),
                Text("Hotels for ${widget.currentGroup!.name}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                for (int i = 0; i < hotels.length; i++)
                  ExpansionTile(
                    title: ListTile(
                      // leading: Image.network("https://logos.skyscnr.com/images/carhire/sippmaps/${car.group.img}", width: 80, height: 80),
                      title: Text("${hotels[i].hotel.name}"),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: Icon(Icons.info),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return HotelInfoDialog(hotels[i].hotel);
                                });
                          },
                        ),
                      ]),
                      subtitle: Text(minPrice(hotels[i].offers) != null
                          ? "From \$${minPrice(hotels[i].offers)}"
                          : "No price available"),
                    ),
                    children: hotels[i].offers.map((HotelOffer o) {
                      return ListTile(
                        subtitle: Text(o.room?.description?.text ??
                            "No description available"),
                        title: o.price.total == null
                            ? null
                            : Text("\$${o.price.total}"),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            if (widget.currentGroup!.infos.isNotEmpty &&
                                widget.currentGroup!.infos
                                    .map((c) => c.hotelId)
                                    .contains(hotels[i].hotel.hotelId)) {
                              await widget.currentGroup!.removeOption(widget
                                  .currentGroup!.infos
                                  .indexWhere((element) =>
                                      element.hotelId ==
                                      hotels[i].hotel.hotelId));
                            } else {
                              await widget.currentGroup!
                                  .addOption(hotels[i].hotel, o);
                            }
                            setState(() {});
                            widget.setState();
                          },
                          child: Text(
                              "Select${(widget.currentGroup!.infos.isNotEmpty && widget.currentGroup!.infos.map((c) => c.hotelId).contains(hotels[i].hotel.hotelId)) ? "ed" : ""}"),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
  }
}
