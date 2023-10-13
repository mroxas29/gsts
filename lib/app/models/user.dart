import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class user {
  String uid;
  Map<String, String> displayname = {};
  String email;
  int idnumber;
  String role;

  user(
      {
      required this.uid,
      required this.displayname,
      required this.role,
      required this.email,
      required this.idnumber});

  toJson() {
    return {
      "uid": uid,
      "displayname": displayname,
      "role": role,
      "email": email,
      "idnumber": idnumber
    };
  }
}

List<user> users = [];

String formatMapToString(Map<String, String> map) {
  return map.entries.map((entry) => entry.value).join(' ');
}

Future<void> addUserFromFirestore() async {
    print("Add user from FS executed");
  try {
    // Access the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Assuming you have a collection named 'users' in your Firestore database
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection('users').get();

    // Iterate through the documents and add users to your list
    for (QueryDocumentSnapshot<Map<String, dynamic>> document
        in querySnapshot.docs) {
      Map<String, dynamic> userData = document.data();
      user newUser = user(
        uid: document.id,
        displayname: Map<String, String>.from(userData['displayname']),
        role: userData['role'],
        email: userData['email'],
        idnumber: userData['idnumber'],
      );
      
      users.add(newUser);
    }
    

    // Optional: Print the users to the console
    users.forEach((user) {
      print(user.toJson());
    });
    
  } catch (e) {
    print('Error fetching users from Firestore: $e');
  }
}


