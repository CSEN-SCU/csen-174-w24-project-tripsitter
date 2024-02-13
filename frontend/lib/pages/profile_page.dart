import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/components/new_trip_popup.dart';
import 'package:tripsitter/components/payment.dart';
import 'package:tripsitter/pages/login.dart';
//TODO: pull and populate user info. have fallbacks for photo
//pull the trip info from the DB and dynamically build the trip list
//make the page not look like shit
class tripInfo extends StatelessWidget{
    final String price;
    final String name;
    final String city;
    final String country;
    final String start;
    final String end;
    final Color col;
    final VoidCallback onPressed;

    tripInfo({
      required this.price,
      required this.name,
      required this.city,
      required this.country,
      required this.start,
      required this.end,
      required this.col,
      required this.onPressed
    });
    @override
    Widget build(BuildContext context){
      return ElevatedButton(
        onPressed: onPressed,
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
    return Scaffold(
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
                                Text('change')
                              ],
                            ),
                          
                        ),
                        Container(
                          //width: MediaQuery.of(context).size.width*.55 ,
                          child: Column(
                              children: [
                                Text(profile!.getName()),
                                Text("Tripping since "+profile!.getDate().toString()),
                                Text("Number of trips:" + profile.getNumberTrips().toString()),
                                
                                
                              ],
                              
                          ),
                        )
                      ],
                    ),
                    Text("this is where a button will go")
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
                     
                    tripInfo(price: '\$420', name: "Uma's Unremarkable Jaunt", city: 'San Francisco', country: 'USA', start: '01-07', end: '01-13', col: Color.fromARGB(255, 214, 214, 214), onPressed: (){
                      print('Uma');
                    }),
                    tripInfo(price: '\$69', name: "Jordan's Justified Journey", city: 'Seattle', country: 'USA', start: '05-07', end: '06-13', col: Color.fromARGB(255, 148, 148, 148), onPressed: (){
                      print('Jordan');
                    }),
                    tripInfo(price: '\$10000', name: "Cameron's Costly Campagin", city: 'Fort Lauderdale', country: 'USA', start: '01-07', end: '01-6', col: Color.fromARGB(255, 214, 214, 214), onPressed: (){
                      print('Cameron');
                    }),
                    tripInfo(price: '\$380', name: "Daryl's Daring Drive", city: 'San Jose', country: 'USA', start: '08-07', end: '08-08', col: Color.fromARGB(255, 148, 148, 148), onPressed: (){
                      print('Daryl');
                    }),
                    
                    ],
                  ),
                )
                )
              
            
          ],
        ),
      ),
    );
  }

  
}