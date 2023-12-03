import 'package:flutter/material.dart';
import 'package:gestion_attente/objects/Doctor.dart';
import 'ConfirmationPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentPage extends StatefulWidget {
  final Doctor doctor;
  AppointmentPage({required this.doctor});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime? selectedDate;
  int selectedTime = 0;
  int selectedMin = 0;
  List<DocumentSnapshot> appointmentList = [];

  // Function to check if a given date is a weekend
  bool _isWeekend(DateTime date) {
    return date.weekday == 6 || date.weekday == 7;
  }

  @override
  void initState() {
    fetchAppointments().then((appointments) {
      setState(() {
        appointmentList = appointments;
      });
    });
  }

  Future<List<DocumentSnapshot>> fetchAppointments() async {
    List<DocumentSnapshot> appointments = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('appointment')
          .where('doctor', isEqualTo: widget.doctor.name)
          .get();
      appointments = querySnapshot.docs;
    } catch (e) {
      print('Error fetching appointments: $e');
    }
    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text(
          'Select Appointment Date',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 240, 231, 231),
          ),
        ),
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 30),
            Text(
              "Select Date:",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      selectedDate != null
                          ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                          : "Select Date",
                      style: TextStyle(
                        fontSize: 20,
                        color: selectedDate != null
                            ? Colors.blueGrey[900]
                            : Colors.grey[600],
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 30,
                      color: selectedDate != null
                          ? Colors.blueGrey[900]
                          : Colors.grey[600],
                    ),
                  ],
                ),
              ),
              onTap: () {
                initState();
                DateTime now = DateTime.now();
                DateTime nextWeekday =
                    now.add(Duration(days: 1 + (8 - now.weekday) % 7));
                showDatePicker(
                  context: context,
                  initialDate: nextWeekday,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                  selectableDayPredicate: (DateTime date) {
                    // Disable weekends
                    return !_isWeekend(date);
                  },
                ).then((value) {
                  setState(() {
                    selectedDate = value;
                    selectedTime = 0;
                    // reset selected time
                  });
                });
              },
            ),
            SizedBox(height: 60),
            Text(
              "Select Time:",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                childAspectRatio: 3 / 2,
                crossAxisCount: 4, // total cells = 54
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: List.generate(40, (index) {
                  final hour = index ~/ 4 + 8; // generate hour dynamically
                  final minute =
                      (index % 4) * 15; // generate minute dynamically
                  bool isAppointmentExists = false;
                  appointmentList.forEach((appointment) {
                    if (selectedDate != null) {
                      String dates, jours, moiss, annees;
                      if (this.selectedDate!.day < 10) {
                        jours = "0" + this.selectedDate!.day.toString();
                      } else {
                        jours = this.selectedDate!.day.toString();
                      }
                      if (this.selectedDate!.month < 10) {
                        moiss = "0" + this.selectedDate!.month.toString();
                      } else {
                        moiss = this.selectedDate!.month.toString();
                      }
                      if (appointment['date'] ==
                              jours +
                                  "-" +
                                  moiss +
                                  "-" +
                                  selectedDate!.year.toString() &&
                          appointment['time'] ==
                              hour.toString() + ":" + minute.toString()) {
                        isAppointmentExists = true;
                        print(isAppointmentExists);
                      }
                    }
                    print(hour.toString() + ":" + minute.toString());
                    print(isAppointmentExists);
                  });
                  return ElevatedButton(
                    onPressed: selectedDate == null || isAppointmentExists
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('appointement already booked'),
                              ),
                            );
                          }
                        : () {
                            setState(() {
                              selectedTime = hour;
                              selectedMin = minute;
                            });
                          },
                    child: Text(
                      "$hour:${minute.toString().padLeft(2, '0')}", // pad minute with leading zero
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: selectedDate != null
                          ? selectedTime == hour && selectedMin == minute
                              ? Colors.green // selected time
                              : isAppointmentExists
                                  ? Colors.red // appointment already exists
                                  : Colors.blueGrey[900]
                          : Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: selectedDate == null ||
                      selectedTime == 0 ||
                      (appointmentList.any((appointment) =>
                          appointment['time'] ==
                              selectedTime.toString() +
                                  ":" +
                                  selectedMin.toString() &&
                          appointment['date'] == selectedDate))
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('appointement already booked'),
                        ),
                      );
                    }
                  : () {
                      // Navigate to confirmation page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmationPage(
                            doctor: widget.doctor,
                            selectedDate: selectedDate!,
                            selectedTime: selectedTime,
                            selectedMin: selectedMin,
                          ),
                        ),
                      );
                    },
              child: Text(
                "Book Appointment",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: selectedDate != null && selectedTime != 0
                    ? Colors.blueGrey[900]
                    : Colors.grey[400],
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
    );
  }
}
