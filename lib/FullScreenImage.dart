import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String image;

  FullScreenImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
          child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 500,
          width: 500,
          child: Image.network(image),
        ),
      )),
    );
  }
}
