import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripsitter/classes/city.dart';

class UserProfile {
  final String _id;
  String _name;
  String _email;
  City? _hometown;
  int _numberTrips;
  final DateTime _joinDate;
  String? _photoUrl;
  String? _stripeId;
  
  UserProfile({
    required id,
    required name,
    required email,
    required hometown,
    required numberTrips,
    required joinDate,
    photoUrl,
    stripeId,
  }):
      _id=id,
      _name=name,
      _email=email,
      _hometown=hometown,
      _numberTrips=numberTrips,
      _joinDate=joinDate,
      _photoUrl=photoUrl,
      _stripeId=stripeId;

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    print(data);
    return UserProfile(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      hometown: data['hometown'] == null ? null : City.fromJson(data['hometown']),
      numberTrips: data['numberTrips'],
      joinDate: data['joinDate']?.toDate(),
      photoUrl: data['photoUrl'],
      stripeId: data['stripeId'],
    );
  }

  static Stream<UserProfile?> getProfile(String uid) {
    return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  Map<String,dynamic> toJson() {
    return {
      "name": _name,
      "email": _email,
      "hometown": _hometown?.toJson(),
      "numberTrips": _numberTrips,
      "joinDate": _joinDate,
      "photoUrl": _photoUrl,
      "stripeId": _stripeId,
    };
  }

  Future<void> save() async {
    await FirebaseFirestore.instance.collection("users").doc(_id).set(toJson());
  }
  String get id => _id;
  String get name => _name;
  String get email => _email;
  City? get hometown => _hometown;
  int get numberTrips => _numberTrips;
  DateTime get joinDate => _joinDate;
  String? get photoUrl => _photoUrl;
  String? get stripeId => _stripeId;

  Future<void> updateName(String name) async{
      _name=name;
  }
  Future<void> updateHometown(City hometown) async{
      _hometown=hometown;
  }
  Future<void> updateEmail(String email) async{
      _email=email;
  }
  Future<void> addTrip() async{
      _numberTrips++;
  }
  Future<void> updatePhotoUrl(String url) async{
      _photoUrl=url;
  }
  Future<void> updateStripeId(String id) async{
      _stripeId=id;
  }

  static Future<UserProfile> getProfileByUid(String uid) async {
    print("Getting $uid");
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserProfile.fromFirestore(doc);
  }
}