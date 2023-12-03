import 'package:flutter/material.dart';

class Client {
  final String firstName;
  final String lastName;
  final String id;
  final int phoneNumber;

  Client(
      {required this.firstName,
      required this.lastName,
      required this.id,
      required this.phoneNumber});
}
