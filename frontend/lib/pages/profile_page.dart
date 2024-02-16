import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/classes/trip.dart';
import 'package:tripsitter/components/new_trip_popup.dart';
import 'package:tripsitter/components/payment.dart';
import 'package:tripsitter/helpers/locators.dart';
import 'package:tripsitter/pages/login.dart';
import 'package:tripsitter/pages/update_profile.dart';
//TODO: pull and populate user info. have fallbacks for photo
//pull the trip info from the DB and dynamically build the trip list
//make the page not look like shit
class TripInfo extends StatelessWidget{
    final Trip trip;
    final Color col;

    TripInfo({
      required this.trip,
      required this.col,
    });
    @override
    Widget build(BuildContext context){
      String name=trip.name;
      String city=trip.destination.name;
      String country=trip.destination.country;
      String start=trip.startDate.toString();
      String end=trip.endDate.toString();
      String price=trip.totalPrice.toString();
      return ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/trip/${trip.id}");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: col,
          textStyle: TextStyle(color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          
          
        ),
        
       child: Row(
        children: [
          Column(
            children: [
              Text(name,
              style:TextStyle(color: Colors.black),),
              Row(
                children: [
                  Icon(Icons.location_pin,
                  color: Colors.black,),
                  Text(city+', '+country,
                  style: TextStyle(color: Colors.black),)
                ],
              
              ),
              Row(
                children: [
                  Icon(Icons.calendar_month,
                  color: Colors.black,),
                  Text(start,
                  style: TextStyle(color: Colors.black),),
                  Icon(Icons.arrow_forward,
                  color: Colors.black,),
                  Text(end,
                  style: TextStyle(color: Colors.black),)
                ],
              )
            ],
          ),
          Center(
            child: Text(price,
            style: TextStyle(color: Colors.black),),
          )
       ],));  
    }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    UserProfile? profile = Provider.of<UserProfile?>(context);
    if(profile == null){
      return UpdateProfile();
    }
    FirebaseFirestore.instance.collection('trips').where('uids', arrayContains: profile.id).get().then((s) => s.docs.map(((doc) => Trip.fromFirestore(doc))));
    return MultiProvider(
      providers: [
        StreamProvider.value(value: Trip.getTripsByProfile(profile.id), initialData: List<Trip>.empty(growable: true))
      ],
      child: Scaffold(
        appBar: AppBar(
          //contains the logo and trip sitter name
          title: Text('This Is the Profile Page'),
        ),
        //contains two columns to contain the user info in one and the trip info in the other
        
        body: Center(
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width*.55 ,
      
                child: 
                
                  //profile info
                  Column(
                    children: [
                      Row(
                        //profile part
                        children: [
                          Container(
                           //width: MediaQuery.of(context).size.width*.45 ,
                              child: Column(
                                //the icon and change button
                                children: [
                                  Icon(Icons.account_circle_rounded),
                                  ElevatedButton(onPressed: (){
                                     Navigator.pushNamed(context, "/profile");
                                  }, child: Text("Edit Profile"))
                                ],
                              ),
                            
                          ),
                          Container(
                            //width: MediaQuery.of(context).size.width*.55 ,
                            child: Column(
                                children: [
                                  Text(profile.name),
                                  Text("Tripping since ${DateFormat.yMMM().format(profile.joinDate)}"),
                                  Text("Number of trips:${profile.numberTrips}"),
                                  
                                  
                                ],
                                
                            ),
                          )
                        ],
                      ),
                      ElevatedButton(onPressed: (){
                         Navigator.pushNamed(context, "/new");
                      }, child: Text("Create New Trip"))
                      //button and possible picture/video
                    ],
                  
                )
                  ),
                  //the trip info
                  Container(
                     width: MediaQuery.of(context).size.width*.45 ,
                    child:
                  Center(
                    child: Column(
                      children: [
                        Text("My Trips"),
                        Center(
                          child: Row(
                            children: [
                              Text("Upcoming"),
                              Icon(Icons.compare_arrows),
                              Text("Past")
                            ],
                          ),
                        ),
                      // StreamBuilder<List<Trip>>(
                      // stream: Trip.getTripsByProfile(profile.getId()),
                      // builder: (BuildContext context, AsyncSnapshot<List<Trip>> snapshot) {
                      //   if (snapshot.hasData) {
                      //     return ListView.builder(
                      //       itemCount: snapshot.data!.length,
                      //       itemBuilder: (BuildContext context, int index) {
                      //         // Generate a widget for each item in the list
                      //         Trip itemData = snapshot.data![index];
                      //         return tripInfo(price: '\$'+itemData.totalPrice.toString(), name: itemData.name, city: itemData.destination.name, country: itemData.destination.country, start: itemData.startDate.toString(), end: itemData.endDate.toString(), col: Color.fromARGB(255, 148, 148, 148), onPressed:(){ Navigator.pushNamed(context, "/trips/${itemData.id}");});
                      //       },
                      //     );
                      //   } else if (snapshot.hasError) {
                      //     return Text('Error: ${snapshot.error}');
                      //   } else {
                      //     return CircularProgressIndicator(); // Placeholder for loading indicator
                      //   }
                      // },
                      Builder(
                        builder: (context) {
                          List<Trip> trips = Provider.of<List<Trip>>(context);
                          return Expanded(
                            child: ListView.builder(
                              itemCount: trips.length,
                              itemBuilder: (BuildContext context, int index) {
                                // Generate a widget for each item in the list
                                return TripInfo(trip: trips[index], col: Color.fromARGB(255, 148, 148, 148));
                            }
                                                ),
                          );
                        }
                      ),
                      ],
                    ),
                  )
                  )
                
              
            ],
          ),
        ),
      ),
    );
  }

  
}