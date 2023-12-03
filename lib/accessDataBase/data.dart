import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataBaseManager {
  final CollectionReference profileList =
      FirebaseFirestore.instance.collection('profilrInfo');
}

Future<void> createUserData(String Fname, String Lname, String Email,
    String cin, String phoneNumber, String id) async {
  final db = DataBaseManager();
  return await db.profileList.doc(id).set({
    'first_name': Fname,
    'last_name': Lname,
    'email': Email,
    'phoneNumber': phoneNumber,
    'cin': cin,
  });
}

Future<void> createAppointement(
    String date, String time, String doctor, String email, String id) async {
  final db = DataBaseManager();
  return await db.profileList
      .doc(id)
      .set({'date': date, 'time': time, 'doctor': doctor, 'email': email});
}
