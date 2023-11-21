import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/user.dart';

class Student extends user {
  List<EnrolledCourseData> enrolledCourses;
  List<PastCourse> pastCourses;
  String degree;
  
  List<Map<String, dynamic>> coursesJson = [];
  Student({
    required String uid,
    required Map<String, String> displayname,
    required String role,
    required String email,
    required int idnumber,
    required this.enrolledCourses,
    required this.pastCourses,
    required this.degree,
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
      "degree": degree,
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
      degree: json['degree']
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
      final Map<String, dynamic>? userData =
          studentSnapshot.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('enrolledCourses')) {
        final List<dynamic> coursesJson = userData['enrolledCourses'];

        return coursesJson
            .map((courseJson) => EnrolledCourseData.fromJson(courseJson))
            .toList();
      } else {
        print(
            'Field "enrolledCourses" not found in document for student: $studentUid');
        return [];
      }
    } else {
      print('Student not found with uid: $studentUid');
      return [];
    }
  } catch (e) {
    print('Error retrieving enrolled courses for student: $e');
    return [];
  }
}

Future<List<PastCourse>> getPastCoursesForStudent(String studentUid) async {
  try {
    final DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentUid)
        .get();

    if (studentSnapshot.exists) {
      final List<dynamic> coursesJson = studentSnapshot['pastCourses'];

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

List<Student> studentList = [];
Future<List<Student>> convertToStudentList(List<user> users) async {
  studentList.clear();
  for (var user in users) {
    if (user.role == 'Graduate Student') {
      List<EnrolledCourseData> enrolledCourses =
          await getEnrolledCoursesForStudent(user.uid);
      List<PastCourse> pastCourses = await getPastCoursesForStudent(user.uid);
        String degree =
          await getDegreeForStudent(user.uid); // Fetch degree information
      
      // You need to fetch past courses here, update accordingly
      studentList.add(Student(
        uid: user.uid,
        displayname: user.displayname,
        role: user.role,
        email: user.email,
        idnumber: user.idnumber,
        enrolledCourses: enrolledCourses,
        pastCourses: pastCourses,
        degree: degree,
      ));
    }
  }

  return studentList;
}

Future<String> getDegreeForStudent(String studentUid) async {
  try {
    final DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentUid)
        .get();

    if (studentSnapshot.exists) {
      final Map<String, dynamic>? userData =
          studentSnapshot.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('degree')) {
        return userData['degree'] as String;
      } else {
        print('Field "degree" not found in document for student: $studentUid');
        return ''; // Return a default value or handle accordingly
      }
    } else {
      print('Student not found with uid: $studentUid');
      return ''; // Return a default value or handle accordingly
    }
  } catch (e) {
    print('Error retrieving degree for student: $e');
    return ''; // Return a default value or handle accordingly
  }
}
