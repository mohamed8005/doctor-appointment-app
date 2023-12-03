import 'package:flutter/material.dart';

class Doctor {
  final String name;
  final String image;
  final String speciality;
  final int experience;
  final String additionalInfo;
  final double rating;
  String? imageUrl;
  String? phone;
  String? email;

  Doctor({
    required this.name,
    required this.image,
    required this.speciality,
    required this.experience,
    required this.additionalInfo,
    required this.rating,
    this.phone,
    this.email,
  });
}
