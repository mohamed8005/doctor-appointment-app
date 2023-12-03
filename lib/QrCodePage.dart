import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_attente/client/homepageClient.dart';
import 'package:gestion_attente/objects/Doctor.dart';
import 'package:gestion_attente/objects/appointmentObject.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePage extends StatelessWidget {
  AppointmentObject? appointmentO;
  String doctorName;
  QrCodePage({this.appointmentO, required this.doctorName});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text(
          'Appointment QR Code',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 240, 231, 231),
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 16),
                ),
              );
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'User data not found',
                  style: TextStyle(fontSize: 16),
                ),
              );
            } else {
              String firstName = snapshot.data!['firstName'] ?? '';
              String lastName = snapshot.data!['lastName'] ?? '';

              String email = snapshot.data!['email'] ?? '';
              String phone = snapshot.data!['phone'] ?? '';
              String cin = snapshot.data!['cin'] ?? '';
              String dates, jours, moiss, annees;
              if (appointmentO!.date.day < 10) {
                jours = "0" + appointmentO!.date.day.toString();
              } else {
                jours = appointmentO!.date.day.toString();
              }
              if (appointmentO!.date.month < 10) {
                moiss = "0" + appointmentO!.date.month.toString();
              } else {
                moiss = appointmentO!.date.month.toString();
              }
              String appointmentDate =
                  '${jours}/${moiss}/${appointmentO?.date.year}';
              String appointmentTime =
                  '${appointmentO!.hour.toString()}:${appointmentO!.min.toString()}';

              // Generate QR code data
              String qrData = lastName +
                  " " +
                  firstName +
                  "\n" +
                  appointmentDate +
                  "\n" +
                  appointmentTime +
                  "\n" +
                  phone +
                  "\n" +
                  doctorName;

              // Generate QR code image
              final qrCode = QrImage(
                data: qrData,
                size: 300,
                gapless: false,
              );

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    qrCode,
                    SizedBox(height: 20),
                    Text(
                      'Scan this QR code at the appointment',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage2(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey[900],
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
