import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/navbar.dart';
import 'package:tripsitter/pages/update_profile.dart';

class TripInfo extends StatefulWidget {
  final Trip trip;
  final Color col;

  const TripInfo({
    required this.trip,
    required this.col,
  });

  @override
  State<TripInfo> createState() => _TripInfoState();
}

class _TripInfoState extends State<TripInfo> {
  @override
  Widget build(BuildContext context) {
    String name = widget.trip.name;
    String city = widget.trip.destination.name;
    String country = widget.trip.destination.country;
    String start = DateFormat.MMMd().format(widget.trip.startDate).toString();
    String end = DateFormat.MMMd().format(widget.trip.endDate).toString();
    String price = widget.trip.totalPrice.toString();
    return ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/trip/${widget.trip.id}");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.col,
          textStyle: const TextStyle(color: Colors.black, fontSize: 20, height: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_pin,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$city, $country',
                      style: const TextStyle(color: Colors.black),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      start,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      end,
                      style: const TextStyle(color: Colors.black),
                    )
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
            const SizedBox(width: 300),
            Center(
              child: Text(
                "     Price - \$$price",
                style: const TextStyle(color: Colors.black),
              ),
            )
          ],
        ));
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool upcoming = true;
  String? image;
  @override
  Widget build(BuildContext context) {
    UserProfile? profile = Provider.of<UserProfile?>(context);
    if (profile == null) {
      return const UpdateProfile();
    }
    if (image == null && profile.hasPhoto) {
      FirebaseStorage.instance
          .ref('pictures/${profile.id}')
          .getDownloadURL()
          .then((a) {
        if (mounted) setState(() => image = a);
      });
    }
    return MultiProvider(
      providers: [
        StreamProvider.value(
            value: Trip.getTripsByProfile(profile.id),
            initialData: List<Trip>.empty(growable: true),
            catchError: (_, err) {
              debugPrint(err.toString());
              return List<Trip>.empty(growable: true);
            })
      ],
      child: Scaffold(
        appBar:
            const TripSitterNavbar(), //contains two columns to contain the user info in one and the trip info in the other

        body: Center(
          child: Row(
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * .55,
                  height: MediaQuery.of(context).size.height,
                  child:

                      //profile info
                      Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //profile part
                        children: [
                          Column(
                            //the icon and change button
                            children: [
                              CircleAvatar(
                                  radius: 100,
                                  backgroundImage:
                                      (profile.hasPhoto && image != null)
                                          ? NetworkImage(image!)
                                          : null,
                                  child:
                                      !(profile.hasPhoto && image != null)
                                          ? const Icon(Icons.person)
                                          : null),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, "/profile");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 238, 238, 238),
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text("Edit Profile")),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: const TextStyle(
                                    fontSize: 30, decorationThickness: 2),
                              ),
                              Text(
                                  "Tripping since ${DateFormat.yMMM().format(profile.joinDate)}"),
                              Text(
                                  "Number of Trips: ${profile.numberTrips}"),
                              Container(height: 50),
                              ElevatedButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut();
                                },
                                child: const Text("Sign out")
                              )
                            ],
                          )
                          ],
                        ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/new");
                          },
                          child: const Text("Create New Trip")),
                      Container(
                          alignment: Alignment.bottomLeft,
                          child: Image.asset("assets/cityscape.png")),
                      //button and possible picture/video
                    ],
                  )),

              //the trip info
              SizedBox(
                  width: MediaQuery.of(context).size.width * .45,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("My Trips"),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    upcoming = true;
                                    setState(() {});
                                  },
                                  child: const Text("Upcoming")),
                              const Icon(Icons.swap_horiz_sharp),
                              ElevatedButton(
                                  onPressed: () {
                                    upcoming = false;
                                    setState(() {});
                                  },
                                  child: const Text("Past"))
                            ],
                          ),
                        ),
                        Builder(builder: (context) {
                          List<Trip> trips = Provider.of<List<Trip>>(context);
                          if (upcoming) {
                            trips = trips
                                .where((element) =>
                                    element.endDate.isAfter(DateTime.now()))
                                .sortedBy((element) => element.startDate)
                                .toList();
                          } else {
                            trips = trips
                                .where((element) =>
                                    element.endDate.isBefore(DateTime.now()))
                                .sortedBy((element) => element.startDate)
                                .toList();
                          }
                          return Expanded(
                            child: ListView.builder(
                                itemCount: trips.length,
                                itemBuilder: (BuildContext context, int index) {
                                  // Generate a widget for each item in the list
                                  return TripInfo(
                                    trip: trips[index],
                                    col: index % 2 == 0 ? Color.fromARGB(255, 245, 245, 245) : Color.fromARGB(255, 217, 217, 217)
                                  );
                                }),
                          );
                        }),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
