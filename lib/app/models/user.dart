import 'package:cloud_firestore/cloud_firestore.dart';

class user {
  String uid;
  Map<String, String> displayname = {};
  String email;
  int idnumber;
  String role;
  String status;
  user(
      {required this.uid,
      required this.displayname,
      required this.role,
      required this.email,
      required this.idnumber,
      required this.status});

  toJson() {
    return {
      "uid": uid,
      "displayname": displayname,
      "role": role,
      "email": email,
      "idnumber": idnumber,
      "status": status
    };
  }
}

List<user> users = [];

String formatMapToString(Map<String, String> map) {
  return map.entries.map((entry) => entry.value).join(' ');
}

Future<void> addUserFromFirestore() async {
  users.clear();
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
          status: userData['status']);

      users.add(newUser);
    }

    users.sort((a, b) => a.email.compareTo(b.email));
  } catch (e) {
    print('Error fetching users from Firestore: $e');
  }
}
