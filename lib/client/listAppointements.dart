import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gestion_attente/AppointmentPage.dart';
import 'package:gestion_attente/client/homepageClient.dart';
import 'package:gestion_attente/objects/appointmentObject.dart';

import '../QrCodePage.dart';

class AppointmentlistPage extends StatefulWidget {
  late String doctorName;
  @override
  _AppointmentlistPageState createState() => _AppointmentlistPageState();
}

class _AppointmentlistPageState extends State<AppointmentlistPage> {
  late Future<List<DocumentSnapshot>> _appointmentsFuture;

  late String _searchQuery = '';
  TextEditingController _textFieldController = TextEditingController();
  bool _showTodayOnly = false;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _fetchAppointments();
  }

  Future<List<DocumentSnapshot>> _searchAppointments(String searchQuery) async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? "";

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("appointment")
        .where('email', isEqualTo: userEmail)
        .where('doctor', isGreaterThanOrEqualTo: searchQuery)
        .where('doctor', isLessThan: searchQuery + 'z')
        .get();

    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> _fetchAppointments() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? "";

    // Query appointments collection based on user email and filter mode
    QuerySnapshot querySnapshot;
    if (_showTodayOnly) {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      String jours, moiss;
      if (today.day < 10) {
        jours = "0" + today.day.toString();
      } else {
        jours = today.day.toString();
      }
      if (today.month < 10) {
        moiss = "0" + today.month.toString();
      } else {
        moiss = today.month.toString();
      }
      querySnapshot = await FirebaseFirestore.instance
          .collection("appointment")
          .where('email', isEqualTo: userEmail)
          .where('date',
              isEqualTo: jours +
                  '-' +
                  moiss +
                  '-' +
                  today.year.toString()) // filter by today's date
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection("appointment")
          .where('email', isEqualTo: userEmail)
          .get();
    }

    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 7,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 208, 230, 244),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _textFieldController,
              style: TextStyle(
                color: Colors.blueGrey[900],
                fontSize: 16,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _appointmentsFuture = _searchAppointments(value);
              },
              decoration: InputDecoration(
                hintText: 'Search by last name...',
                hintStyle: TextStyle(
                  color: Colors.blueGrey[400],
                  fontSize: 16,
                ),
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: Colors.blueGrey[400],
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.blueGrey[400],
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _textFieldController.clear();
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                child: Center(
                  child: FutureBuilder<List<DocumentSnapshot>>(
                    future: _appointmentsFuture,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        List<DocumentSnapshot> appointments = snapshot.data!;
                        if (appointments.isNotEmpty) {
                          return ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: appointments.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    SizedBox(height: 10),
                            itemBuilder: (BuildContext context, int index) {
                              return AppointmentBlock(
                                appointment: appointments[index],
                              );
                            },
                          );
                        } else {
                          return Center(
                              child: Text(
                            'No appointments found',
                            style: TextStyle(fontSize: 20),
                          ));
                        }
                      } else {
                        return Center(child: Text('No data available'));
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey[900],
                    ),
                    onPressed: () {
                      setState(() {
                        _showTodayOnly = false; // set filter mode to all
                        _appointmentsFuture =
                            _fetchAppointments(); // fetch appointments again
                      });
                    },
                    child: Text('all')),
                SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey[900],
                    ),
                    onPressed: () {
                      setState(() {
                        _showTodayOnly = true; // set filter mode to today only
                        _appointmentsFuture =
                            _fetchAppointments(); // fetch appointments again
                      });
                    },
                    child: Text('today only')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> _fetchDoctor(String doctorName) async {
  try {
    // Query the doctors collection based on doctor name
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .where('name', isEqualTo: doctorName)
        .get();

    // Check if any doctor is found
    if (querySnapshot.docs.isNotEmpty) {
      // Get the first doctor document
      DocumentSnapshot documentSnapshot = querySnapshot.docs[0];

      // Retrieve the imageUrl attribute from the document data
      String doctorImageUrl = documentSnapshot.get('imageUrl');

      return doctorImageUrl;
    } else {
      return 'https://cdn5.vectorstock.com/i/1000x1000/34/54/default-placeholder-doctor-half-length-portrait-vector-20773454.jpg';
    }
  } catch (e) {
    print('Error fetching doctor: $e');
    return '';
  }
}

Future<void> getImage(String image, String appointmentTitle) async {
  try {
    String image = await _fetchDoctor(appointmentTitle);
    // You can now use the value of 'image' as needed
    print('Image: $image');
  } catch (e) {
    // Handle any errors that may occur while fetching the image
    print('Error: $e');
  }
}

class AppointmentBlock extends StatelessWidget {
  final DocumentSnapshot appointment;

  AppointmentBlock({required this.appointment});

  Future<String> _getImage(String appointmentTitle) async {
    String imageUrl = await _fetchDoctor(appointmentTitle);
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _getImage(appointment['doctor'] ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching image URL
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Show an error message if fetching image URL fails
            return Text('Failed to load image');
          } else {
            // Update image1 with the fetched image URL
            String appointmentTitle = appointment['doctor'] ?? '';
            String appointmentDate = appointment['date'] ?? '';
            String appointmentTime = appointment['time'] ?? '';
            List<String> time = appointmentTime.split(":");
            print(snapshot.data ?? '');
            List<String> date = appointmentDate.split("-");
            int day = int.parse(date[0]);
            int month = int.parse(date[1]);
            int year = int.parse(date[2]);
            DateTime parsedDate = DateTime(year, month, day);
            AppointmentObject appointmentO = AppointmentObject(
                date: parsedDate,
                hour: int.parse(time[0]),
                min: int.parse(time[1]));

            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QrCodePage(
                              appointmentO: appointmentO,
                              doctorName: appointmentTitle,
                            )));
              },
              child: Card(
                color: Color.fromARGB(154, 26, 203, 223),
                child: Container(
                  height: 80,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(80, 12, 14, 75),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: (snapshot.data == null ||
                                  snapshot.data!.isEmpty)
                              ? NetworkImage(
                                  'https://cdn5.vectorstock.com/i/1000x1000/34/54/default-placeholder-doctor-half-length-portrait-vector-20773454.jpg')
                              : NetworkImage(snapshot.data!),
                        ),
                      ),

                      Column(
                        children: [
                          SizedBox(
                            height: 18,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.black,
                                size: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                appointmentDate,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_alarm,
                                color: Colors.black,
                                size: 17,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                appointmentTime,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(
                        width: 20,
                      ),
                      // Display doctor's name
                      Text(
                        appointmentTitle,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          // Delete appointment from appointments collection
                          await appointment.reference.delete();

                          // Add appointment to old appointments collection with canceled status
                          // await FirebaseFirestore.instance
                          //   .collection("old_appointments")
                          // .doc()
                          //  .set({
                          //   'doctor': appointment['doctor'],
                          // 'email': appointment['email'],
                          //'date': appointment['date'],
                          // 'time': appointment['time'],
                          // "clientName": appointment['name'],
                          //  'canceled': true,
                          // });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('appointement deleted succesfuly'),
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage2(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
