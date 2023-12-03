import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gestion_attente/objects/appointmentObject.dart';
import '../objects/Client.dart';
import 'PhoneVerificationPage.dart';

class RendezVousPage extends StatelessWidget {
  TextEditingController ControllerFName = TextEditingController();
  TextEditingController ControllerLName = TextEditingController();
  TextEditingController ControllerID = TextEditingController();
  TextEditingController ControllerPhoneNumber = TextEditingController();

  late String code;
  AppointmentObject appointmentO;
  String doctorName;

  String apiKey = '7a414758';
  String apiSecret = 'ZCg1PPLhuKfCwJ8v';
  String from = '+212 626 700989';

  RendezVousPage({required this.appointmentO, required this.doctorName});
  @override
  int generateRandomNumber(int min, int max) {
    Random random = Random();
    return min + random.nextInt(max - min + 1);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HEALTHCARE NOW'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.person),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: ControllerFName,
                    decoration: InputDecoration(hintText: 'Prénom'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: ControllerLName,
                    decoration: InputDecoration(hintText: 'Nom'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Icon(Icons.credit_card),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: ControllerID,
                    decoration: InputDecoration(hintText: 'Carte nationale'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Icon(Icons.phone),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: ControllerPhoneNumber,
                    keyboardType: TextInputType.phone,
                    decoration:
                        InputDecoration(hintText: 'Numéro de téléphone'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    code = generateRandomNumber(1000, 9999).toString();
                    Map<String, dynamic> requestBody = {
                      'api_key': apiKey,
                      'api_secret': apiSecret,
                      'from': from,
                      'to': "+212" +
                          int.parse(ControllerPhoneNumber.text).toString(),
                      'text': "your verification code is" + code,
                    };

// Send the POST request to the Vonage SMS API
                    http.Response response = await http.post(
                      Uri.parse('https://rest.nexmo.com/sms/json'),
                      body: requestBody,
                    );

// Check the response for success or failure
                    if (response.statusCode == 200) {
                      // SMS sent successfully
                      print('SMS sent successfully');
                    } else {
                      // SMS sending failed
                      print('Failed to send SMS. Response: ${response.body}');
                    }
                    Client client = Client(
                      firstName: ControllerFName.text,
                      lastName: ControllerLName.text,
                      id: ControllerID.text,
                      phoneNumber: int.parse(ControllerPhoneNumber.text),
                    );

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhoneVerificationPage(
                                client: client,
                                doctorName: doctorName,
                                appointmentO: appointmentO,
                                code: code)));
                  },
                  child: Text(
                    "save",
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
