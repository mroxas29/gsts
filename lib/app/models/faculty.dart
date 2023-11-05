import 'package:cloud_firestore/cloud_firestore.dart';

class Faculty {
  String uid; // Unique Identifier
  String fullName;
  String email;

  Faculty({required this.uid, required this.fullName, required this.email});

  // Convert faculty data to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
    };
  }

  // Create a Faculty instance from a Firestore document
  factory Faculty.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Faculty(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
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
  facultyList.add(Faculty(uid: '0', fullName: "UNASSIGNED", email: ''));

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    Faculty faculty = Faculty.fromFirestore(doc);
    facultyList.add(faculty);
  }

  facultyList.sort((a, b) => a.fullName.compareTo(b.fullName));
  return facultyList;
}
