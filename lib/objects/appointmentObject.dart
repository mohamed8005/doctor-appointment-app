import 'package:flutter/material.dart';

class AppointmentObject {
  late final DateTime date;
  late final int hour;
  late final int min;

  AppointmentObject(
      {required this.date, required this.hour, required this.min});
}
