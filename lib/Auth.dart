import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'client/homepageClient.dart';
import 'main.dart';

class Auth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.email == "loulidi.ahmed@gmail.com") {
              return HomePage3();
            } else {
              return HomePage2();
            }
          } else {
            return HomePage1();
          }
        },
      ),
    );
  }
}
