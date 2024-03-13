// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:tripsitter/classes/city.dart';
import 'package:tripsitter/classes/profile.dart';
import 'package:tripsitter/helpers/data.dart';

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

  List<String> genders = <String>['Male', 'Female', 'Other'];

  void loadCities() async {
    cities = await getCities(context);
    if (mounted) {
      var result = await DefaultAssetBundle.of(context).loadString(
        "assets/worldcities.csv",
      );
      List<List<dynamic>> list =
          const CsvToListConverter().convert(result, eol: "\n");
      list.removeAt(0);
      if (!mounted) {
        return;
      }
      setState(() {});
    }
  }

  UserProfile? profile;

  bool newProfile = false;
  bool loadingPic = false;

  Future<void> getProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!mounted) {
      return;
    }
    setState(() {
      if (doc.exists) {
        profile = UserProfile.fromFirestore(doc);
        nameController.text = profile!.name;
        emailController.text = profile!.email;
      } else {
        debugPrint("NEW PROFILE");
        nameController.text = user.displayName!;
        emailController.text = user.email!;
        newProfile = true;
        profile = UserProfile(
            id: user.uid,
            name: user.displayName!,
            email: user.email!,
            countryCode: "1",
            countryISO: "US",
            phoneNumber: "",
            hometown: null,
            numberTrips: 0,
            gender: "Other",
            birthDate: DateTime(2000, 1, 1),
            joinDate: DateTime.now());
      }
    });
  }
  String? initialCountry;
  String? initialPhone;

  // Future getImageFromGallery() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     return;
  //   }
  //   if (!mounted) {
  //     return;
  //   }
  //   var image_url = '';
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   var imageFile = File(pickedFile!.path);
  //   //print("made it to picking the image");
  //   FirebaseStorage storage = FirebaseStorage.instance;
  //   Reference ref = storage.ref().child(user.uid);
  //   UploadTask uploadTask = ref.putFile(imageFile);
  //   await uploadTask.whenComplete(() async {
  //     var url = await ref.getDownloadURL();
  //     image_url = url.toString();
  //     debugPrint(image_url);
  //   }).catchError((onError) {
  //     debugPrint(onError);
  //   });
  //   if (!mounted) {
  //     return;
  //   }
  //   setState(() {});
  // }
  Future<void> uploadImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) {
      return;
    }
    if(mounted) {
      setState(() {
        loadingPic = true;
      });
    }
    Uint8List raw = await img.readAsBytes();
    Reference ref = FirebaseStorage.instance.ref('pictures/${user?.uid}');
    try {
      await ref.putData(raw);
      String url = await ref.getDownloadURL();
      image = url;
      await profile?.updatePhoto(true);
      if(mounted) setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture uploaded successfully!'),
        ),
      );
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
    }
    if(mounted) {
      setState(() {
        loadingPic = false;
      });
    }
  }

  String? image;

//text field widgit
  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(
        context); //built in firebase stuff to get ID is who is currently using it
    if (profile == null) {
      return Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200, maxWidth: 200),
        child:
            const AspectRatio(aspectRatio: 1.0, child: CircularProgressIndicator()),
      ));
    }
    if (image == null && profile!.hasPhoto) {
      FirebaseStorage.instance
          .ref('pictures/${profile!.id}')
          .getDownloadURL()
          .then((a) {
        if (mounted) setState(() => image = a);
      });
    }

    if(initialCountry == null) {
      initialCountry = profile!.countryISO;
      initialPhone = "+${profile!.countryCode}${profile!.phoneNumber}";
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(user!.uid),
        ),
        //store all of that info into the db
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(children: [
              Text(newProfile ? "Create Profile" : "Update Profile"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: nameController,
                  onChanged: (value) {
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
                child: InkWell(
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: profile!.birthDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now());
                    if (date != null) {
                      profile!.updateBirthDate(date);
                      if(mounted) setState(() {});
                    }
                  },
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(profile!.birthDate),
                  )
                )
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Autocomplete<City>(
                  fieldViewBuilder: (context, textEditingController, focusNode,
                          onFieldSubmitted) =>
                      TextFormField(
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
                  initialValue: TextEditingValue(
                      text: profile!.hometown == null
                          ? ""
                          : "${profile!.hometown!.name}, ${profile!.hometown!.country}"),
                  displayStringForOption: (option) =>
                      "${option.name}, ${option.country}",
                  optionsBuilder: (TextEditingValue value) {
                    if (value.text == '') {
                      return const Iterable<City>.empty();
                    }
                    return cities.where((t) {
                      return t.name
                          .toLowerCase()
                          .contains(value.text.toLowerCase());
                    });
                  },
                  onSelected: (selected) {
                    profile!.updateHometown(selected);
                  },
                ),
              ),
              const Text("Gender:"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: profile!.gender,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    if(value == null) return;
                    setState(() {
                      profile!.updateGender(value);
                    });
                  },
                  items: genders.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IntlPhoneField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: InputBorder.none,
                      labelText: 'Phone Number',
                    ),
                    initialCountryCode: initialCountry,
                    initialValue: initialPhone,
                    onChanged: (phone) {
                      try {if(phone.isValidNumber()) {
                        profile!.updateCountryCode(phone.countryCode.substring(1));
                        profile!.updatePhoneNumber(phone.number);
                        profile!.updateCountryISO(phone.countryISOCode);
                      }
                      } catch(e) {
                        debugPrint(e.toString());
                      }
                    },
                ),
              ),
              ListTile(
                leading: loadingPic ? const CircularProgressIndicator() : CircleAvatar(
                  backgroundImage:
                      (profile!.hasPhoto && image != null)
                          ? NetworkImage(image!)
                          : null,
                  child: !(profile!.hasPhoto && image != null)
                      ? const Icon(Icons.person)
                      : null),
                title: ElevatedButton(onPressed: () => uploadImage(), child: const Text("Select Image")),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () async {
                    if (profile!.hometown == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select a hometown")));
                      return;
                    }
                    await profile?.save();
                    if (!newProfile) {
                      Navigator.pushReplacementNamed(context, "/");
                    }
                  },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 125, 175, 220),
                                foregroundColor: Colors.black,
                              ),
                  child: const Text("Save Profile"),
              )
                  
            ]),
          ),
        ));
  }
}
