import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/city.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/components/new_trip_popup.dart';
import 'package:tripsitter/components/payment.dart';
import 'package:tripsitter/helpers/data.dart';
import 'package:tripsitter/pages/login.dart';
import 'package:tripsitter/pages/profile_page.dart';

class UpdateProfile extends StatefulWidget {
   const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();


  @override
  void initState() {
    super.initState();
    getProfile();
    loadCities();
  }

  List<City> cities = [];

  void loadCities() async {
    cities = await getCities(context);
    setState(() {});
  }

  UserProfile? profile;

  bool newProfile = false;

  Future<void> getProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      return;
    }
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if(!mounted) {
      return;
    }
    setState(() {
      if(doc.exists) {
        profile = UserProfile.fromFirestore(doc);
        nameController.text = profile!.name;
        emailController.text = profile!.email;
      }
      else {
        print("NEW PROFILE");
        nameController.text = user.displayName!;
        emailController.text = user.email!;
        newProfile = true;
        profile = UserProfile(
          id: user.uid, 
          name: user.displayName!, 
          email: user.email!, 
          hometown: null,
          numberTrips: 0, 
          joinDate: DateTime.now()
        );
      }
    });

  }

//text field widgit
  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);//built in firebase stuff to get ID is who is currently using it
    if(profile == null) {
      return Center(
        child: ConstrainedBox(
          child: AspectRatio( aspectRatio: 1.0, child: CircularProgressIndicator()),
          constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
        )
      );
    }
    return Scaffold(
      appBar: AppBar(
        
        title: Text(user!.uid),
      ),
      //TODO: pull ID, Prompt for name, Pull Email, Prompt for hometown, initialize number of trips to 0, populate join date, prompt for user photo, default stripe ID
      //store all of that info into the db
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Text(newProfile ? "Create Profile" : "Update Profile"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: nameController,
                   onChanged:(value) {
                    profile!.updateName(value);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: InputBorder.none,
                    labelText: 'Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller:emailController,
                   onChanged:(value) {
                    profile!.updateEmail(value);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: InputBorder.none,
                    labelText: 'Email',
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Autocomplete<City>(
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) => TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onFieldSubmitted: (_) {},
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: InputBorder.none,
                        labelText: 'Hometown',
                      ),
                    ),
                    initialValue: TextEditingValue(text: profile!.hometown == null ? "" : "${profile!.hometown!.name}, ${profile!.hometown!.country}"),
                    displayStringForOption: (option) => "${option.name}, ${option.country}",
                    optionsBuilder: (TextEditingValue value) {
                      if(value.text == '') {
                        return const Iterable<City>.empty();
                      }
                      return cities.where((t){
                        return t.name.toLowerCase().contains(value.text.toLowerCase());
                      });
                    },
                    onSelected: (selected) {
                      profile!.updateHometown(selected);
                    },
                  ),
                ),
              Text("Upload Profile Picture"),
              ElevatedButton(onPressed: () async {
                if(profile!.hometown == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a hometown")));
                  return;
                }
                  await profile?.save();
                  if(!newProfile) {
                    Navigator.pushReplacementNamed(context, "/");
                  }
                
              }, child: Text("Save Profile"))
          ]),
        ),
        
    )
    );
  }
}
