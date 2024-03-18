import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/navbar.dart';
import 'package:tripsitter/helpers/styles.dart';
import 'package:tripsitter/pages/update_profile.dart';

class TripInfo extends StatelessWidget {
  final Trip trip;
  final Color col;

  const TripInfo({required this.trip, required this.col, super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = Provider.of<bool>(context);
    String city = trip.destination.name;
    String country = trip.destination.country;
    String start = DateFormat.MMMd().format(trip.startDate).toString();
    String end = DateFormat.MMMd().format(trip.endDate).toString();
    String price = trip.totalPrice.toStringAsFixed(2);
    return Container(
      color: col,
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, "/trip/${trip.id}");
        },
        title: Text(trip.name,
            style: sectionHeaderStyle.copyWith(fontSize: isMobile ? 20 : 25)),
        trailing: Text("\$$price",
            style: TextStyle(color: Colors.black, fontSize: 15)),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_pin,
                ),
                const SizedBox(width: 5),
                Text(
                  '$city, $country',
                )
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                ),
                const SizedBox(width: 5),
                Text(
                  start,
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.arrow_forward,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  end,
                )
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
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
    bool isMobile = Provider.of<bool>(context);

    Widget tripList = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("My Trips",
            style: sectionHeaderStyle.copyWith(fontSize: isMobile ? 20 : 30)),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    upcoming = true;
                    setState(() {});
                  },
                  style: upcoming ? buttonStyle : buttonStyle2,
                  child: const Text("Upcoming")),
              const Icon(Icons.swap_horiz_sharp),
              ElevatedButton(
                  onPressed: () {
                    upcoming = false;
                    setState(() {});
                  },
                  style: upcoming ? buttonStyle2 : buttonStyle,
                  child: const Text("Past"))
            ],
          ),
        ),
        const SizedBox(height: 10),
        Builder(builder: (context) {
          List<Trip> trips = Provider.of<List<Trip>>(context);
          if (upcoming) {
            trips = trips
                .where((element) => element.endDate.isAfter(DateTime.now()))
                .sortedBy((element) => element.startDate)
                .toList();
          } else {
            trips = trips
                .where((element) => element.endDate.isBefore(DateTime.now()))
                .sortedBy((element) => element.startDate)
                .reversed
                .toList();
          }
          if (isMobile) {
            return Column(
              children: [
                for (var trip in trips)
                  TripInfo(
                      trip: trip,
                      col: trips.indexOf(trip) % 2 == 0
                          ? const Color.fromARGB(255, 245, 245, 245)
                          : const Color.fromARGB(255, 217, 217, 217))
              ],
            );
          }
          return Expanded(
            child: ListView.builder(
                itemCount: trips.length,
                itemBuilder: (BuildContext context, int index) {
                  // Generate a widget for each item in the list
                  return TripInfo(
                      trip: trips[index],
                      col: index % 2 == 1
                          ? const Color.fromARGB(255, 245, 245, 245)
                          : const Color.fromARGB(255, 217, 217, 217));
                }),
          );
        }),
      ],
    );
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
          child: Builder(builder: (context) {
            if (isMobile) {
              return ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                        backgroundImage: (profile.hasPhoto && image != null)
                            ? NetworkImage(image!)
                            : null,
                        child: !(profile.hasPhoto && image != null)
                            ? const Icon(Icons.person)
                            : null),
                    title: Text(
                      profile.name,
                      style: sectionHeaderStyle,
                    ),
                    subtitle: Text(
                        "Tripping since ${DateFormat.yMMM().format(profile.joinDate)}\nNumber of Trips: ${profile.numberTrips}"),
                    isThreeLine: true,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/profile");
                            },
                            child: const Text("Edit Profile")),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                            },
                            child: const Text("Sign out")),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/new");
                        },
                        child: const Text("Create New Trip")),
                  ),
                  const SizedBox(height: 10),
                  tripList
                ],
              );
            }
            return Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: -300,
                  child: Image.asset(
                    "assets/skyline.png",
                    height: 300,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //profile part
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                                ? const Icon(Icons.person,
                                                    size: 200)
                                                : null),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, "/profile");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: HexColor("#C6D6FF"),
                                        foregroundColor: Colors.black,
                                      ),
                                      child: const Text("Edit Profile"),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                    Container(height: 25),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, "/new");
                                        },
                                        child: const Text("Create New Trip")),
                                    Container(height: 25),
                                    ElevatedButton(
                                        onPressed: () {
                                          FirebaseAuth.instance.signOut();
                                        },
                                        child: const Text("Sign out")),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      )),

                      //the trip info
                      ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * .45),
                          child: Container(
                            color: Colors.white,
                            child: Center(child: tripList),
                          ))
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
