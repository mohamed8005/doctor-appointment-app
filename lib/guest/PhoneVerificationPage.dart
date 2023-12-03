import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestion_attente/Auth.dart';
import 'package:gestion_attente/objects/appointmentObject.dart';

import '../objects/Client.dart';
import 'QrCodePage.dart';

class PhoneVerificationPage extends StatefulWidget {
  final Client client;
  String doctorName, code;
  AppointmentObject appointmentO;

  PhoneVerificationPage(
      {required this.client,
      required this.doctorName,
      required this.appointmentO,
      required this.code});

  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  TextEditingController _verificationCodeController1 = TextEditingController();
  TextEditingController _verificationCodeController2 = TextEditingController();
  TextEditingController _verificationCodeController3 = TextEditingController();
  TextEditingController _verificationCodeController4 = TextEditingController();
  String? verificationCode;
  @override
  void initState() {
    super.initState();
    Client client = widget.client;
    print(client.phoneNumber);
    print(widget.code);
    // do something with the client object
  }

  Future<void> signup(BuildContext context) async {
    // Save user's information in Firestore

    CollectionReference users =
        FirebaseFirestore.instance.collection('appointment');
    String dates, jours, moiss, annees;
    if (widget.appointmentO.date.day < 10) {
      jours = "0" + widget.appointmentO.date.day.toString();
    } else {
      jours = widget.appointmentO.date.day.toString();
    }
    if (widget.appointmentO.date.month < 10) {
      moiss = "0" + widget.appointmentO.date.month.toString();
    } else {
      moiss = widget.appointmentO.date.month.toString();
    }
    await users.doc().set({
      'date':
          jours + "-" + moiss + "-" + widget.appointmentO.date.year.toString(),
      'time': widget.appointmentO.hour.toString() +
          ':' +
          widget.appointmentO.min.toString(),
      'doctor': widget.doctorName,
      'email': '',
      "name": widget.client.lastName + " " + widget.client.firstName,
      'phone': '0' + widget.client.phoneNumber.toString(),
      "cin": widget.client.id.toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    String phoneNumber = "0" + widget.client.phoneNumber.toString();
    int phoneNumberLength = phoneNumber.length;
    String formattedPhoneNumber = phoneNumber.replaceRange(
        2, phoneNumberLength - 2, '*' * (phoneNumberLength - 4));

    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Verification'),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Enter the verification code sent to the number $formattedPhoneNumber',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Icon(Icons.phone),
                SizedBox(width: 10),
                Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 68,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            controller: _verificationCodeController1,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: '0'),
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          height: 68,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            controller: _verificationCodeController2,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: '0'),
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          height: 68,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            controller: _verificationCodeController3,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: '0'),
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          height: 68,
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            controller: _verificationCodeController4,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: '0'),
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ]),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    verificationCode = _verificationCodeController1.text +
                        _verificationCodeController2.text +
                        _verificationCodeController3.text +
                        _verificationCodeController4.text;
                    if (verificationCode == widget.code) {
                      signup(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QrCodePage(
                              doctorName: widget.doctorName,
                              appointmentO: widget.appointmentO,
                              client: widget.client),
                        ),
                        (route) => false,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('appointment booked succesfuly'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('the code provided is false'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Verify",
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
          ],
        ),
      ),
    );
  }
}
