import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_attente/Auth.dart';
import 'package:gestion_attente/client/homepageClient.dart';
import 'package:gestion_attente/objects/Client.dart';
import 'package:gestion_attente/objects/Doctor.dart';
import 'package:gestion_attente/objects/appointmentObject.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePage extends StatelessWidget {
  AppointmentObject appointmentO;
  String doctorName;
  Client client;
  QrCodePage(
      {required this.appointmentO,
      required this.doctorName,
      required this.client});

  Future<User?> _getUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<Map<String, dynamic>> _fetchAppointments() async {
    // Query appointments collection based on user email and filter mode
    QuerySnapshot<Map<String, dynamic>> querySnapshot;

    querySnapshot = await FirebaseFirestore.instance
        .collection("appointment")
        .where('name', isEqualTo: client.lastName + " " + client.firstName)
        .where('doctor', isEqualTo: doctorName)
        .where("cin", isEqualTo: client.id)
        .where("date",
            isEqualTo: appointmentO.date.day.toString() +
                "-" +
                appointmentO.date.month.toString() +
                '-' +
                appointmentO.date.year.toString())
        .where("phone", isEqualTo: client.phoneNumber)
        .where("time",
            isEqualTo: appointmentO.hour.toString() +
                ':' +
                appointmentO.min.toString())
        .limit(1)
        .get();

    QueryDocumentSnapshot<Map<String, dynamic>>? snapshot =
        querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;

    // Check if the document exists
    if (snapshot != null && snapshot.exists) {
      // Access the data in the snapshot
      Map<String, dynamic>? data = snapshot.data();
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
        future: _fetchAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 16),
                ),
              );
            } else {
              String firstName = client.firstName;
              String lastName = client.lastName;

              String email = '';
              String phone = "0" + client.phoneNumber.toString();
              String cin = client.id;
              String appointmentDate =
                  '${appointmentO.date.day}/${appointmentO.date.month}/${appointmentO.date.year}';
              String appointmentTime =
                  '${appointmentO.hour.toString()}:${appointmentO.min.toString()}';

              // Generate QR code data
              String qrData =
                  'Appointment details\nDate: $appointmentDate\nTime: $appointmentTime\n\nFirst Name: $firstName\nLast Name: $lastName\n\nEmail: $email\nPhone: $phone\nCIN: $cin\n\nDoctor: $doctorName';

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
                    Center(
                      child: Text(
                        'please screenshot this because you \n won\'t have it again',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Auth(),
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
