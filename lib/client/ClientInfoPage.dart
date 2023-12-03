import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Auth.dart';
import 'ClientModifyInfoPage.dart';
import 'ImageUploadPage.dart';

class ClientInfoPage extends StatefulWidget {
  @override
  _ClientInfoPageState createState() => _ClientInfoPageState();
}

class _ClientInfoPageState extends State<ClientInfoPage> {
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
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
        title: Text('User Info'),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Auth()));
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _userDataFuture,
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              var name = snapshot.data!['firstName'] +
                  " " +
                  snapshot.data!['lastName'];
              var email = snapshot.data!['email'];
              var phoneNumber = snapshot.data!['phone'];
              var imageUrl = snapshot.data!['imageUrl'];
              String image;
              if (imageUrl != null) {
                image = imageUrl;
              } else {
                image = "";
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImageUploadPage()));
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: CircleAvatar(
                        backgroundImage: image != "" && image.isNotEmpty
                            ? NetworkImage(image)
                            : NetworkImage(
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzCb4DonWw5pT1-A3Su9HzG6TTN4nMOmj7tg&usqp=CAU"),
                        radius: 60,
                      ),
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    email,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    phoneNumber,
                    style: TextStyle(fontSize: 18),
                  ),
                  Flexible(
                    child: IconButton(
                      icon: Icon(Icons.info),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditClientInfoPage()));
                      },
                    ),
                  )
                ],
              );
            } else {
              return Text('No data available');
            }
          },
        ),
      ),
    );
  }
}
