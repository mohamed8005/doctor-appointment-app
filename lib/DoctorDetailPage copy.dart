import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'FullScreenImage.dart';
import 'objects/Doctor.dart';
import 'AppointmentPage.dart';

class DoctorDetailPagecopy extends StatefulWidget {
  final Doctor doctor;

  DoctorDetailPagecopy({
    required this.doctor,
  });

  @override
  _DoctorDetailPagecopyState createState() => _DoctorDetailPagecopyState();
}

class _DoctorDetailPagecopyState extends State<DoctorDetailPagecopy> {
  bool _isRatingVisible = false;
  int _rating = 0;

  void _toggleRatingVisibility() {
    setState(() {
      _isRatingVisible = !_isRatingVisible;
    });
  }

  void _updateRating(int newRating) async {
    setState(() {
      _rating = newRating;
    });

    User? user = FirebaseAuth.instance.currentUser;

    CollectionReference ratingsCollection =
        FirebaseFirestore.instance.collection('ratings');

    QuerySnapshot querySnapshot = await ratingsCollection
        .where('doctor_name', isEqualTo: widget.doctor.name)
        .where('user_email', isEqualTo: user?.email)
        .get();

    // If a document exists, update its rating field
    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs[0].id;
      await ratingsCollection.doc(documentId).update({'rating': _rating});
    } else {
      await ratingsCollection.add({
        'doctor_name': widget.doctor.name,
        'user_email': user?.email,
        'rating': _rating.toString(),
      });
    }
    List<int> ratings = [];
    QuerySnapshot doctorRatingsSnapshot = await ratingsCollection
        .where('doctor_name', isEqualTo: widget.doctor.name)
        .get();
    for (var doc in doctorRatingsSnapshot.docs) {
      ratings.add(doc['rating']);
    }
    double averageRating;
    // Calculate average rating
    if (ratings.length > 0) {
      averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
    } else {
      averageRating = ratings[0] as double;
    }

    CollectionReference doctorsCollection =
        FirebaseFirestore.instance.collection('doctors');

    QuerySnapshot doctorSnapshot = await doctorsCollection
        .where('name', isEqualTo: widget.doctor.name)
        .get();
    print(averageRating);
    if (doctorSnapshot.docs.isNotEmpty) {
      String documentId = doctorSnapshot.docs[0].id;
      await doctorsCollection
          .doc(documentId)
          .update({'rating': averageRating.toString()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text(
          'HEALTHCARE NOW',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 240, 231, 231),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            GestureDetector(
              child: CircleAvatar(
                radius: 75,
                backgroundImage: widget.doctor.image != ""
                    ? NetworkImage(widget.doctor.image)
                    : NetworkImage(
                        'https://cdn5.vectorstock.com/i/1000x1000/34/54/default-placeholder-doctor-half-length-portrait-vector-20773454.jpg'),
              ),
              onTap: () {
                print(widget.doctor.image.toString());
                widget.doctor.image != ""
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImage(image: widget.doctor.image),
                        ),
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                              image:
                                  'https://cdn5.vectorstock.com/i/1000x1000/34/54/default-placeholder-doctor-half-length-portrait-vector-20773454.jpg'),
                        ),
                      );
              },
            ),
            SizedBox(height: 20),
            Text(
              widget.doctor.name,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 70, 58, 58),
              ),
            ),
            SizedBox(height: 10),
            Text(
              widget.doctor.speciality,
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    User? user1 = FirebaseAuth.instance.currentUser;
                    if (user1 != null) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                backgroundColor: Colors.transparent,
                                title: Column(
                                  children: [
                                    Text(
                                      "Rating",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        for (int i = 1; i <= 5; i++)
                                          IconButton(
                                            onPressed: () {
                                              _updateRating(i);
                                              Navigator.of(context)
                                                  .pop(); // Update the selected rating
                                            },
                                            icon: Icon(
                                              _rating >= i
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: 30,
                                              color: Colors.amber,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ));
                    }
                  },
                  child: Icon(
                    Icons.star,
                    size: 30,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  widget.doctor.rating.toString(),
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 70, 58, 58),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Experience: " + widget.doctor.experience.toString() + " years",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  width: double.infinity,
                  child: Column(children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        "more info: ",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        widget.doctor.additionalInfo.toString(),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AppointmentPage(
                              doctor: widget.doctor,
                            )));
              },
              child: Text(
                "Make Appointment",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                primary: Colors.blueGrey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
