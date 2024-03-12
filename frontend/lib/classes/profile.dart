import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripsitter/classes/city.dart';

class UserProfile {
  final String _id;
  String _name;
  String _email;
  City? _hometown;
  int _numberTrips;
  final DateTime _joinDate;
  DateTime _birthDate;
  String _gender;
  String _countryISO;
  String _countryCode;
  String _phoneNumber;
  bool _hasPhoto;
  String? _stripeId;

  UserProfile({
    required id,
    required name,
    required email,
    required hometown,
    required numberTrips,
    required joinDate,
    required birthDate,
    required countryCode,
    required phoneNumber,
    required gender,
    required countryISO,
    hasPhoto,
    stripeId,
  })  : _id = id,
        _name = name,
        _email = email,
        _hometown = hometown,
        _numberTrips = numberTrips,
        _joinDate = joinDate,
        _hasPhoto = hasPhoto,
        _birthDate = birthDate,
        _countryCode = countryCode,
        _phoneNumber = phoneNumber,
        _gender = gender,
        _countryISO = countryISO,
        _stripeId = stripeId;

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserProfile(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      gender: data['gender'] ?? "Other",
      countryCode: data['countryCode'] ?? "1",
      phoneNumber: data['phoneNumber'] ?? "",
      countryISO: data['countryISO'] ?? "US",
      hometown:
          data['hometown'] == null ? null : City.fromJson(data['hometown']),
      numberTrips: data['numberTrips'],
      joinDate: data['joinDate']?.toDate(),
      hasPhoto: data['hasPhoto'] ?? false,
      stripeId: data['stripeId'],
      birthDate: data['birthDate']?.toDate() ?? DateTime(2000, 1, 1)
    );
  }

  static Stream<UserProfile?> getProfile(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": _name,
      "email": _email,
      "hometown": _hometown?.toJson(),
      "numberTrips": _numberTrips,
      "joinDate": Timestamp.fromDate(_joinDate),
      "hasPhoto": _hasPhoto,
      "stripeId": _stripeId,
      "birthDate": Timestamp.fromDate(_birthDate),
      "countryCode": _countryCode,
      "phoneNumber": _phoneNumber,
      "gender": _gender,
      "countryISO": _countryISO,
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
  bool get hasPhoto => _hasPhoto;
  String? get stripeId => _stripeId;
  DateTime get birthDate => _birthDate;
  String get countryCode => _countryCode;
  String get countryISO => _countryISO;
  String get phoneNumber => _phoneNumber;
  String get gender => _gender;

  Future<void> updateName(String name) async {
    _name = name;
  }

  Future<void> updateHometown(City hometown) async {
    _hometown = hometown;
  }

  Future<void> updateEmail(String email) async {
    _email = email;
  }

  Future<void> addTrip() async {
    _numberTrips++;
  }

  Future<void> updatePhoto(bool has) async {
    _hasPhoto = has;
  }

  Future<void> updateStripeId(String id) async {
    _stripeId = id;
  }

  Future<void> updateBirthDate(DateTime date) async {
    _birthDate = date;
  }

  Future<void> updateCountryCode(String code) async {
    _countryCode = code;
  }

  Future<void> updateCountryISO(String iso) async {
    _countryISO = iso;
  }

  Future<void> updatePhoneNumber(String number) async {
    _phoneNumber = number;
  }

  Future<void> updateGender(String gender) async {
    _gender = gender;
  }

  static Future<UserProfile> getProfileByUid(String uid) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserProfile.fromFirestore(doc);
  }

  static Stream<List<UserProfile>> getTripProfiles(List<String> uids) {
    return FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: uids)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .toList());
  }
}
