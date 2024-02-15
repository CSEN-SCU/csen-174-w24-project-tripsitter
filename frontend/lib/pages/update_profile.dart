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

class UpdateProfile extends StatefulWidget {
   UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController hometownController = TextEditingController();


  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    UserProfile userProfile = UserProfile.fromFirestore(await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid).get());
      setState(() {
 nameController = TextEditingController(text: userProfile.getName());
    emailController = TextEditingController(text: userProfile.getEmail());
    hometownController = TextEditingController(text: userProfile.getHometown());
      });
   
  }

//text field widgit
  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);//built in firebase stuff to get ID is who is currently using it 
    UserProfile? profile = Provider.of<UserProfile?>(context);//user info + stuff we want to store  what we made put the info here what we store
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
              controller: nameController,
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
                await profile?.save();
                Navigator.pushNamed(context, "/");
              
            }, child: Text("DONE"))
        ]),
        
    )
    );
  }
}
