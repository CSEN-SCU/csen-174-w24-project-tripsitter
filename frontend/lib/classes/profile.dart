import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String _id;
  String _name;
  String _email;
  String _hometown;
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

  static Stream<UserProfile?> getProfile(String uid) {
    return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

   Future<void> save() async {
    await _save();
  }

  Future<void> _save() async {
    await FirebaseFirestore.instance.collection("users").doc(_id).set({
      "uids": _id,
      "name": _name,
      "hometown": _hometown,
      "email": _email,
      "numberTrips": _numberTrips,
      "joinDate": _joinDate,
      "photoUrl": _photoUrl,
      "stripeId": _stripeId,
      
    });
  }
String getId(){
    return _id;
  }
  DateTime getDate(){
    return _joinDate;
  }
  Future<void> updateName(String name) async{
      _name=name;
      await _save();
  }
   String getName(){
    return _name;
  }
  Future<void> updateHometown(String hometown) async{
      _hometown=hometown;
      await _save();
  }
  String getHometown(){
    return _hometown;
  }
  Future<void> updateEmail(String email) async{
      _email=email;
      await _save();
  }
  String getEmail(){
    return _email;
  }
  Future<void> updateNumberTrips() async{
      _numberTrips++;
      await _save();
  }
  int getNumberTrips(){
    return _numberTrips;
  }
  Future<void> updatePhotoUrl(String url) async{
      _photoUrl=url;
      await _save();
  }
  String? getPhotoUrl(){
    return _photoUrl;
  }
  Future<void> updateStripeId(String id) async{
      _stripeId=id;
      await _save();
  }
  String? getStripe(){
    return _stripeId;
  }



  
}