import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tripsitter/classes/profile.dart';

class ProfilePicture extends StatefulWidget {
  final UserProfile profile;
  const ProfilePicture(this.profile, {super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {

  UserProfile get profile => widget.profile;

  String? image;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseStorage.instance.ref('pictures/${profile.id}').getDownloadURL(),
      builder: 
      (BuildContext context, AsyncSnapshot<String> snapshot) {
        return CircleAvatar(
          backgroundImage:
              (profile.hasPhoto && snapshot.hasData && snapshot.data != null)
                  ? NetworkImage(snapshot.data!)
                  : null,
          child: !(profile.hasPhoto && snapshot.hasData && snapshot.data != null)
              ? Icon(Icons.person)
              : null);
      }
    );
  }
}