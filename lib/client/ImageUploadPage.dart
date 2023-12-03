import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _imageFile;
  String? _uploadedImageUrl;
  bool _uploading = false; // Track if image is currently being uploaded

  Future<String> uploadImageToFirebase(File imageFile) async {
    // Create a unique file name
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Create a reference to the Firebase Storage location
    Reference reference =
        FirebaseStorage.instance.ref().child('users/$fileName');

    // Upload the image file to Firebase Storage
    UploadTask uploadTask = reference.putFile(imageFile);

    // Get the download URL of the uploaded image
    String imageUrl = await (await uploadTask).ref.getDownloadURL();

    // Return the download URL
    return imageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _uploadImage() async {
    if (_imageFile != null) {
      setState(() {
        _uploading =
            true; // Set uploading to true while image is being uploaded
      });

      // Upload the selected image to Firebase Storage
      String imageUrl = await uploadImageToFirebase(_imageFile!);

      // Update the user in the Firestore database with the uploaded image URL
      User? user = FirebaseAuth.instance.currentUser;
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);
      await docRef.update({'imageUrl': imageUrl});

      // Render the uploaded image URL in the app
      setState(() {
        _uploadedImageUrl = imageUrl;
        _uploading = false; // Set uploading to false after image is uploaded
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload Example'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _uploading
                ? CircularProgressIndicator() // Show circular progress indicator while uploading
                : _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        height: 200,
                      )
                    : Text('No Image Selected'),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: Text('Select Image'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey[900],
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey[900],
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            _uploadedImageUrl != null
                ? Text('Uploaded Image succesfuly')
                : Container(),
          ],
        ),
      ),
    );
  }
}
