import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/main.dart';

class Student extends user {
  List<EnrolledCourseData> enrolledCourses;
  List<PastCourse> pastCourses;
  List<Map<String, dynamic>> coursesJson = [];

  Student({
    required String uid,
    required Map<String, String> displayname,
    required String role,
    required String email,
    required int idnumber,
    required this.enrolledCourses,
    required this.pastCourses,
  }) : super(
          uid: uid,
          displayname: displayname,
          role: role,
          email: email,
          idnumber: idnumber,
        );

  // Convert Student object to JSON
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "displayname": displayname,
      "role": role,
      "email": email,
      "idnumber": idnumber,
      "enrolledCourses":
          enrolledCourses.map((course) => course.toJson()).toList(),
      "pastCourses": pastCourses.map((course) => course.toJson()).toList(),
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    List<dynamic> enrolledCoursesJson = json['enrolledCourses'] ?? [];
    List<dynamic> pastCoursesJson = json['pastCourses'] ?? [];

    List<EnrolledCourseData> enrolledCourses =
        enrolledCoursesJson.cast<Map<String, dynamic>>().map((courseJson) {
      return EnrolledCourseData.fromJson(courseJson);
    }).toList();

    List<PastCourse> pastCourses =
        pastCoursesJson.cast<Map<String, dynamic>>().map((courseJson) {
      return PastCourse.fromJson(courseJson);
    }).toList();

    return Student(
      uid: json['uid'],
      displayname: json['displayname'],
      role: json['role'],
      email: json['email'],
      idnumber: json['idnumber'],
      enrolledCourses: enrolledCourses,
      pastCourses: pastCourses,
    );
  }
}

Future<List<EnrolledCourseData>> getEnrolledCoursesForStudent(
    String studentUid) async {
  try {
    print('Fetching enrolled courses for student: $studentUid');
    final DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentUid)
        .get();

    if (studentSnapshot.exists) {
      final List<dynamic> coursesJson = studentSnapshot['enrolledCourses'];
      print('Fetched enrolled courses: $coursesJson');
      print('Student Data: ${studentSnapshot.data()}');
      return coursesJson
          .map((courseJson) => EnrolledCourseData.fromJson(courseJson))
          .toList();
    } else {
      print('Student not found with uid: $studentUid');
      return [];
    }
  } catch (e) {
    print('Error retrieving enrolled courses: $e');
    return [];
  }
}
Future<List<PastCourse>> getPastCoursesForStudent(String studentUid) async {
  try {
    print('Fetching past courses for student: $studentUid');
    final DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentUid)
        .get();

    if (studentSnapshot.exists) {
      final List<dynamic> coursesJson = studentSnapshot['pastCourses'];
      print('Fetched past courses: $coursesJson');
      print('Student Data: ${studentSnapshot.data()}');
      return coursesJson
          .map((courseJson) => PastCourse.fromJson(courseJson))
          .toList();
    } else {
      print('Student not found with uid: $studentUid');
      return [];
    }
  } catch (e) {
    print('Error retrieving past courses: $e');
    return [];
  }
}





Future<List<Student>> convertToStudentList(List<user> users) async {
  List<Student> studentList = [];

  int i = 0;
  for (var user in users) {
    if (user.role == 'Graduate Student') {
      List<EnrolledCourseData> enrolledCourses =
          await getEnrolledCoursesForStudent(user.uid);
      List<PastCourse> pastCourses =
          []; // You need to fetch past courses here, update accordingly

      studentList.add(Student(
        uid: user.uid,
        displayname: user.displayname,
        role: user.role,
        email: user.email,
        idnumber: user.idnumber,
        enrolledCourses: enrolledCourses,
        pastCourses: pastCourses,
      ));
      print("Student $i : ${studentList[i].displayname}");
      i++;
    }
  }

  return studentList;
}
