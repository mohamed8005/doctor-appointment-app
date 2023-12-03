import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_attente/client/homepageClient.dart';

import '../Auth.dart';

class EditClientInfoPage extends StatefulWidget {
  @override
  _EditClientInfoPageState createState() => _EditClientInfoPageState();
}

class _EditClientInfoPageState extends State<EditClientInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cinController = TextEditingController();

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
      _firstNameController.text = data['firstName'];
      _lastNameController.text = data['lastName'];
      _phoneController.text = data['phone'];
      _cinController.text = data['cin'];
      return data;
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Info'),
        backgroundColor: Colors.blueGrey[900],
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
              var cin = snapshot.data!['cin'];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _cinController,
                        decoration: InputDecoration(
                          labelText: 'Cin',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your ID number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            User? user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
// Update user data in the Firestore database
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .update({
                                'firstName': _firstNameController.text,
                                'lastName': _lastNameController.text,
                                'phone': _phoneController.text,
                                'cin': _cinController.text
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('User information updated')));
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage2()));
                            }
                          }
                        },
                        child: Text('Update Info'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blueGrey[900],
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Text('No user data found');
            }
          },
        ),
      ),
    );
  }
}
