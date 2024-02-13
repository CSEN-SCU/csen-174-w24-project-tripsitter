import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/components/new_trip_popup.dart';
import 'package:tripsitter/components/payment.dart';
import 'package:tripsitter/pages/login.dart';
import 'package:tripsitter/pages/profile_page.dart';

class createProfile extends StatelessWidget {
  const createProfile({super.key});
  
  
  
//text field widgit
//text editing controller=attribute
//on changed to check for update
  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);//built in firebase stuff to get ID is who is currently using it 
    UserProfile? profile = Provider.of<UserProfile?>(context);//user info + stuff we want to store  what we made put the info here what we store
    UserProfile newProfile = UserProfile(
    id: user?.uid, 
    name: user?.displayName!, 
    email: user?.email!, 
    hometown: "hometown", 
    numberTrips: 0, 
    joinDate: DateTime.now());
    newProfile.save();
    return Scaffold(
      appBar: AppBar(
        
        title: Text(user!.uid),
      ),
      //TODO: pull ID, Prompt for name, Pull Email, Prompt for hometown, initialize number of trips to 0, populate join date, prompt for user photo, default stripe ID
      //store all of that info into the db
      body: Center(
        child: Column(
          children: [
            Text("Please Enter the Following Information:"),
            Text("Name"),
            TextField(
              controller:TextEditingController(
                text: user.displayName
              ),
               onChanged:(value) {
                profile!.updateName(value);
              },
            ),
            Text("Email"),
            TextField(
              controller:TextEditingController(
                text: user.email
              ),
               onChanged:(value) {
                profile!.updateEmail(value);
              },
            ),
            Text("Hometown"),
            TextField(
              onChanged:(value) {
                
                profile?.updateHometown(value);
              },
            ),
            Text("Upload Profile Picture"),
            ElevatedButton(onPressed: () async {
                await newProfile.save();
                print(profile?.getName());
                Navigator.pushNamed(context, "/");
              
            }, child: Text("DONE"))
        ]),
        
    )
    );
  }

  
}