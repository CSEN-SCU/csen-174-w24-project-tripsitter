import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/components/new_trip_popup.dart';
import 'package:tripsitter/components/payment.dart';
import 'package:tripsitter/pages/create_Profile.dart';
import 'package:tripsitter/pages/login.dart';
import 'package:tripsitter/pages/profile_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    UserProfile? profile = Provider.of<UserProfile?>(context);
    if(profile == null){
      return createProfile();
    }
    else{
      return ProfilePage();
    }
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Home'),
    //   ),
    //   body: Center(
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         ElevatedButton(
    //           onPressed: () {
    //             showDialog(
    //               context: context,
    //               builder:(context) => NewTrip()
    //             );
    //           }, 
    //           child: Text("New Trip popup!")
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             Navigator.pushNamed(context, "/trip/1234");
    //           }, 
    //           child: Text("View existing trip")
    //         ),
    //       ]
    //     ),
    //   ),
    // );
  }
}
