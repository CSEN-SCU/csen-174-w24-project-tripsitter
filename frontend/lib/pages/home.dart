import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tripsitter/components/map.dart';
import 'package:tripsitter/components/new_trip_popup.dart';
import 'package:tripsitter/pages/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    if(!loggedIn) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // Don't allow the user to go back to the home page without logging in
        Navigator.pushReplacementNamed(context, "/login");
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:(context) => NewTrip()
              );
            }, 
            child: Text("New Trip popup!")
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/trip/1234");
            }, 
            child: Text("View existing trip")
          )
        ]
      ),
    );
  }
}