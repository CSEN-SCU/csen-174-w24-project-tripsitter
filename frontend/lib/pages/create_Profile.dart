import 'package:cloud_firestore/cloud_firestore.dart';
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

class CreateProfile extends StatefulWidget {
   CreateProfile({super.key});

  @override
  State<CreateProfile> createState() => _UpdateProfileState();
}


class _UpdateProfileState extends State<CreateProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController hometownController = TextEditingController();


  @override
  void initState() {
    super.initState();
    getProfile();
  }

  void getProfile()  {
    User? user = FirebaseAuth.instance.currentUser;
    nameController = TextEditingController(text: user?.displayName);
    emailController = TextEditingController(text: user?.email);
    hometownController = TextEditingController(text: "Hometown");
    
  }
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
              controller:nameController,
               onChanged:(value) {
                profile!.updateName(value);
              },
            ),
            Text("Email"),
            TextField(
              controller:emailController,
               onChanged:(value) {
                profile!.updateEmail(value);
              },
            ),
            Text("Hometown"),
            TextField(
              controller:hometownController,
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