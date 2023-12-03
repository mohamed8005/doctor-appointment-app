import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_attente/QrCodePage.dart';
import 'package:gestion_attente/guest/RendezVousPage.dart';
import 'package:gestion_attente/objects/appointmentObject.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Auth.dart';
import 'objects/Doctor.dart';

class ConfirmationPage extends StatelessWidget {
  final Doctor doctor;
  final DateTime selectedDate;
  final int selectedTime;
  final int selectedMin;

  ConfirmationPage({
    required this.doctor,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedMin,
  });
  Future<User?> _getUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    // Create a document reference
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);

    // Get the document snapshot
    DocumentSnapshot snapshot = await docRef.get();

    // Check if the document exists
    if (snapshot.exists) {
      // Access the data in the snapshot
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data;
    } else {
      return {};
    }
  }

  Future<void> signup(BuildContext context) async {
    // Save user's information in Firestore
    User? user = await _getUser();
    Map<String, dynamic> userData = await _fetchUserData();
    CollectionReference users =
        FirebaseFirestore.instance.collection('appointment');
    String dates, jours, moiss, annees;
    if (this.selectedDate.day < 10) {
      jours = "0" + this.selectedDate.day.toString();
    } else {
      jours = this.selectedDate.day.toString();
    }
    if (this.selectedDate.month < 10) {
      moiss = "0" + this.selectedDate.month.toString();
    } else {
      moiss = this.selectedDate.month.toString();
    }
    await users.doc().set({
      'cin': userData['cin'],
      'date': jours + "-" + moiss + "-" + this.selectedDate.year.toString(),
      'time': this.selectedTime.toString() + ':' + this.selectedMin.toString(),
      'doctor': this.doctor.name,
      'email': user?.email,
      "name": userData['lastName'] + " " + userData['firstName'],
      'phone': userData['phone'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text(
          'Appointment Confirmation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 240, 231, 231),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30),
              Text(
                "Appointment Details",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blueGrey[900],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Time: $selectedTime:$selectedMin",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blueGrey[900],
                ),
              ),
              SizedBox(height: 60),
              ElevatedButton(
                onPressed: () async {
                  // Save appointment details to Firestore
                  User? user = await _getUser();
                  if (user == null) {
                    AppointmentObject appointmentO = AppointmentObject(
                        date: selectedDate,
                        hour: selectedTime,
                        min: selectedMin);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RendezVousPage(
                          appointmentO: appointmentO,
                          doctorName: doctor.name,
                        ),
                      ),
                    );
                  } else {
                    await signup(context);
                    AppointmentObject appointmentO = AppointmentObject(
                      date: selectedDate,
                      hour: selectedTime,
                      min: selectedMin,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('appointement booked succesfuly'),
                      ),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrCodePage(
                          appointmentO: appointmentO,
                          doctorName: doctor.name,
                        ),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: Text(
                  "Confirm",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueGrey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
