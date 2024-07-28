import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/student_user.dart';

class Faculty {
  String uid; // Unique Identifier
  Map<String, String> displayname;
  String email;
  List<Course> history; // List of courses

  Faculty({
    required this.uid,
    required this.displayname,
    required this.email,
    required this.history,
  });

  // Convert faculty data to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayname': displayname,
      'email': email,
      'history': history.map((course) => course.toMap()).toList(),
    };
  }

  // Create a Faculty instance from a Firestore document
  factory Faculty.fromJson(Map<String, dynamic> json) {
    List<dynamic> historyJson = json['history'] ?? [];
    // Extracting the 'displayname' map

    List<EnrolledCourseData> historyCourses =
        historyJson.cast<Map<String, dynamic>>().map((courseJson) {
      return EnrolledCourseData.fromJson(courseJson);
    }).toList();
    return Faculty(
      uid: json['uid'],
      displayname: json['displayName'],
      email: json['email'],
      history: historyCourses,
    );
  }
}

List<Faculty> facultyList = [];

Future<List<EnrolledCourseData>> getHistory(String facultyuid) async {
  try {
    final DocumentSnapshot facultySnapshot = await FirebaseFirestore.instance
        .collection('faculty')
        .doc(facultyuid)
        .get();

    if (facultySnapshot.exists) {
      final Map<String, dynamic>? facultyData =
          facultySnapshot.data() as Map<String, dynamic>?;

      if (facultyData != null && facultyData.containsKey('history')) {
        final List<dynamic> coursesJson = facultyData['history'];
        return coursesJson
            .map((courseJson) => EnrolledCourseData.fromJson(courseJson))
            .toList();
      } else {
        print('Field "history" not found in document for student: $facultyuid');
        return [];
      }
    } else {
      print('faculty not found with uid: $facultyuid');
      return [];
    }
  } catch (e) {
    print('Error retrieving enrolled courses for facultyuid: $e');
    return [];
  }
}
// Get a list of all faculty members from Firestore
Future<List<Faculty>> getFacultyList() async {
  // Initialize an empty list to hold faculty data
  facultyList = [];

  facultyList.add(Faculty(
    uid: '0',
    displayname: {'firstname': 'None', 'lastname': 'assigned'},
    email: '',
    history: [], // Initialize history as an empty list
  ));

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Assuming you have a collection named 'faculty' in your Firestore database
  QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await firestore.collection('faculty').get();

  for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
    Map<String, dynamic> data = doc.data();

    // Extracting faculty details from document data
    String uid = data['uid'];
    Map<String, String> displayName =
        Map<String, String>.from(data['displayname'] ?? {});
    String email = data['email'];
    List<Course> history = await getHistory(uid);

Faculty faculty = Faculty(
  uid: uid,
  displayname: displayName,
  email: email,
  history: history.map((historyCourse) {
    return Course(
      uid: historyCourse.uid,
      coursecode: historyCourse.coursecode,
      coursename: historyCourse.coursename,
      isactive: historyCourse.isactive,
      facultyassigned: historyCourse.facultyassigned,
      numstudents: historyCourse.numstudents,
      units: historyCourse.units,
      type: historyCourse.type,
      program: historyCourse.program,
      dayTimes: List<Map<String, String>>.from(
        historyCourse.dayTimes.map((dayTime) => Map<String, String>.from(dayTime)),
      ),
      syAndTerm: historyCourse.syAndTerm,
      section: historyCourse.section,
      roomNum: historyCourse.roomNum,
      setup: historyCourse.setup,
      onlineDay: historyCourse.onlineDay
    );
  }).toList(),
);

    facultyList.add(faculty);
  }

  return facultyList;
}
