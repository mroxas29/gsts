import 'package:cloud_firestore/cloud_firestore.dart';

class Faculty {
  String uid; // Unique Identifier
  Map<String, String> displayname;
  String email;

  Faculty({required this.uid, required this.displayname, required this.email});

  // Convert faculty data to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayname': displayname,
      'email': email,
    };
  }

  // Create a Faculty instance from a Firestore document
  factory Faculty.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Extracting the 'displayname' map
    Map<String, String> displayName =
        Map<String, String>.from(data['displayname'] ?? {});

    // Extracting other values with default values if they don't exist
    String email = data['email'] ?? '';

    return Faculty(
      uid: doc.id,
      displayname: displayName,
      email: email,
    );
  }
}

final CollectionReference facultyCollection =
    FirebaseFirestore.instance.collection('faculty');

// Add a faculty member to Firestore
Future<void> addFaculty(Faculty faculty) async {
  await facultyCollection.doc(faculty.uid).set(faculty.toMap());
}

List<Faculty> facultyList = [];

// Get a list of all faculty members from Firestore
Future<List<Faculty>> getFacultyList() async {
  QuerySnapshot querySnapshot = await facultyCollection.get();

  // Clear the list before populating it
  facultyList.clear();
  facultyList.add(Faculty(
      uid: '0',
      displayname: {'firstname': 'UNASSIGNED', 'lastname': 'UNASSIGNED'},
      email: ''));

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    Faculty faculty = Faculty.fromFirestore(doc);
    facultyList.add(faculty);
  }

  return facultyList;
}
