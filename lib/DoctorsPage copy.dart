import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gestion_attente/AppointmentPage.dart';
import 'package:gestion_attente/DoctorDetailPage%20copy.dart';
import 'package:gestion_attente/client/homepageClient.dart';
import 'package:gestion_attente/objects/appointmentObject.dart';

import '../QrCodePage.dart';
import 'objects/Doctor.dart';

class DoctorsPagecopy extends StatefulWidget {
  @override
  _DoctorsPagecopyState createState() => _DoctorsPagecopyState();
}

class _DoctorsPagecopyState extends State<DoctorsPagecopy> {
  late Future<List<Doctor>> _doctorsFuture;
  String _selectedCategory = ""; // Selected category for filtering
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _fetchDoctors();
  }

  late List<Doctor> filteredDoctors;

  List<T> getSharedComponents<T>(List<T> list1, List<T> list2) {
    List<T> sharedComponents = [];

    // Iterate over list1 and check if each element is present in list2
    for (var item1 in list1) {
      if (list2.contains(item1)) {
        sharedComponents.add(item1);
      }
    }

    return sharedComponents;
  }

  Future<List<Doctor>> _fetchDoctors() async {
    // Query doctors collection
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("doctors").get();

    // Get list of doctors from the query snapshot
    List<Doctor> doctors = querySnapshot.docs.map((doc) {
      String doctorName = doc['name'] ?? '';
      String doctorRating = doc['rating'] ?? '';
      String doctorAdditionalInfo = doc['additionalInfo'] ?? '';
      String doctorSpeciality = doc['speciality'] ?? '';
      String doctorImageUrl = doc['imageUrl'] ?? '';
      String doctorExperience = doc['experience'] ?? '';
      String doctorPhone = doc["phone"];
      String doctorEmail = doc['email'];

      return Doctor(
          name: doctorName,
          additionalInfo: doctorAdditionalInfo,
          experience: int.parse(doctorExperience),
          image: doctorImageUrl,
          rating: double.parse(doctorRating),
          speciality: doctorSpeciality,
          phone: doctorPhone,
          email: doctorEmail);
    }).toList();

    return doctors;
  }

  List<String> _specialties = [
    'null',
    'Cardiologist',
    'Dentist',
    'General',
    'Dermatology',
    'Endocrinology',
    'Gastroenterology',
    'General Surgent',
    'Neurology',
    'Ophthalmology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'Urology',
  ];

  late String _selectedSpecialty = _specialties[0];

  List<Doctor> _filterDoctors(List<Doctor> doctors) {
    print(_selectedSpecialty);
    List<Doctor> filteredDoctors = [];

    if (_selectedSpecialty != _specialties[0]) {
      filteredDoctors = doctors
          .where((doctor) =>
              doctor.speciality.toLowerCase() ==
              _selectedSpecialty.toLowerCase())
          .toList();
    } else {
      filteredDoctors = doctors;
    }

    if (_searchQuery.isNotEmpty) {
      filteredDoctors = filteredDoctors
          .where((doctor) =>
              doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filteredDoctors;
  }

  TextEditingController _textFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Appointment'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 7,
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
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
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
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
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Specialties'),
                          content: Container(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _specialties.length,
                              itemBuilder: (BuildContext context, int index) {
                                return RadioListTile<String>(
                                  title: Text(_specialties[index]),
                                  value: _specialties[index],
                                  groupValue: _selectedSpecialty,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSpecialty = value!;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      });
                },
                icon: Icon(Icons.arrow_drop_down_circle_sharp),
              )
            ],
          ),
          SizedBox(height: 7),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: FutureBuilder<List<Doctor>>(
                    future: _doctorsFuture,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Doctor>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        List<Doctor> doctors = snapshot.data!;
                        if (doctors.isNotEmpty) {
                          List<Doctor> doctors1 = _filterDoctors(doctors);
                          return ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: doctors1.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    SizedBox(height: 1),
                            itemBuilder: (BuildContext context, int index) {
                              return DoctorBlockcopy(
                                doctor: doctors1[index],
                              );
                            },
                          );
                        } else {
                          return Center(
                              child: Text(
                            'No doctors found',
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
        ],
      ),
    );
  }
}

class DoctorBlockcopy extends StatelessWidget {
  final Doctor doctor;

  DoctorBlockcopy({
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DoctorDetailPagecopy(doctor: doctor)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 194, 173, 173),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 69, 62, 62).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              width: 3,
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 80,
                  padding: EdgeInsets.only(right: 20, left: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    image: DecorationImage(
                      image: doctor.image != ""
                          ? NetworkImage(doctor.image)
                          : NetworkImage(
                              'https://cdn5.vectorstock.com/i/1000x1000/34/54/default-placeholder-doctor-half-length-portrait-vector-20773454.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 7,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        doctor.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        doctor.speciality,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          Icon(Icons.star, color: Colors.yellow[700]),
                          SizedBox(width: 5),
                          Text(doctor.rating.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 10),
                          Text(
                            doctor.experience.toString() +
                                " years of experience",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
