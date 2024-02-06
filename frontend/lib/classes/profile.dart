import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String hometown;
  final int numberTrips;
  final DateTime joinDate;
  final String? photoUrl;
  final String? stripeId;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.hometown,
    required this.numberTrips,
    required this.joinDate,
    this.photoUrl,
    this.stripeId,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserProfile(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      hometown: data['hometown'],
      numberTrips: data['numberTrips'],
      joinDate: data['joinDate'].toDate(),
      photoUrl: data['photoUrl'],
      stripeId: data['stripeId'],
    );
  }
}