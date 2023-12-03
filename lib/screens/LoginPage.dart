import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_attente/Auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'SignupPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String errorMessage = '';
  bool isLoading = false; // Added to track loading state

  Future<void> login(BuildContext context) async {
    setState(() {
      isLoading = true; // Show circular progress indicator on button press
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      // Save user's login state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      Navigator.pop(context, MaterialPageRoute(builder: (context) => Auth()));
    } on FirebaseAuthException catch (e) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(_emailController.text.trim())) {
        errorMessage = 'entrez une address email';
      }
      if (e.code == 'user-not-found') {
        setState(() {
          errorMessage = 'Aucun utilisateur ne correspond à cet email';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          errorMessage = 'Le mot de passe est incorrect';
        });
      }
    }

    setState(() {
      isLoading = false; // Hide circular progress indicator after login attempt
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'Email'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(hintText: 'Mot de passe'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // Disable button during loading state
                      await login(context);
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Auth()),
                            (route) => false);
                      }
                    },
              child: isLoading
                  ? CircularProgressIndicator() // Show circular progress indicator if loading
                  : Text('Login'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey[900],
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SignUpPage()));
              },
              child: Text(
                'Signup',
                style: TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(height: 10),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
