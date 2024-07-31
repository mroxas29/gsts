import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
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
    required String status,
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
            status: status);

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
      "status": status,
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
        degree: json['degree'],
        status: json['status']);
  }
}

Future<List<EnrolledCourseData>> getEnrolledCoursesForStudent(
    String studentUid) async {
  try {
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
      final Map<String, dynamic>? userData =
          studentSnapshot.data() as Map<String, dynamic>?;

      // Ensure 'pastCourses' is correctly cast
      final List<dynamic>? coursesJson =
          userData?['pastCourses'] as List<dynamic>?;

      if (coursesJson != null) {
        return coursesJson
            .map((courseJson) => PastCourse.fromJson(
                Map<String, dynamic>.from(courseJson as Map)))
            .toList();
      } else {
        print('No pastCourses found for uid: $studentUid');
        return [];
      }
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
List<Student> graduatingStudentsList = [];
List<Student> applicantList = [];
List<Student> ineligibleStudentList = [];
List<StudentPOS> fromLOAStudents = [];
List<Student> noEnrolledStudents = [];
Future<List<Student>> getLOAStudents() async {
  fromLOAStudents.clear();

  studentPOSList.clear();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference collectionReference =
      firestore.collection('fromLOAStudents');

  try {
    QuerySnapshot querySnapshot = await collectionReference.get();

    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      if (documentSnapshot.exists) {
        // Retrieve data
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          // Create a StudentPOS object from the retrieved data
          StudentPOS studentPOS = StudentPOS.fromJson(data);

          fromLOAStudents.add(studentPOS);
        } else {
          print('Document data is null');
        }
      } else {
        print(
            'Document does not exist for document ID: ${documentSnapshot.id}');
      }
    }
  } catch (e) {
    print('Error retrieving documents from Student POS collection: $e');
  }
  return fromLOAStudents;
}

Future<List<Student>> getNewStudents() async {
  applicantList.clear();
  try {
    // Access the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query the "graduatingStudents" collection
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection('users').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> document
        in querySnapshot.docs) {
      Map<String, dynamic> userData = document.data();
      if (userData['role'] == 'Applicant') {
        Student newStudent = Student(
            uid: document.id,
            displayname: Map<String, String>.from(userData['displayname']),
            enrolledCourses: await getEnrolledCoursesForStudent(document.id),
            pastCourses: await getPastCoursesForStudent(document.id),
            role: userData['role'],
            email: userData['email'],
            idnumber: userData['idnumber'],
            status: userData['status'],
            degree: await getDegreeForStudent(document.id));

        applicantList.add(newStudent);
      }
    }
  } catch (e) {
    print(e);
  }
  return applicantList;
}

Future<List<Student>> getGraduatingStudents() async {
  graduatingStudentsList.clear();

  try {
    // Access the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query the "graduatingStudents" collection
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection('graduatingStudents').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> document
        in querySnapshot.docs) {
      Map<String, dynamic> userData = document.data();
      Student graduatingStudent = Student(
          uid: document.id,
          displayname: Map<String, String>.from(userData['displayname']),
          enrolledCourses: await getEnrolledCoursesForStudent(document.id),
          pastCourses: await getPastCoursesForStudent(document.id),
          role: userData['role'],
          email: userData['email'],
          idnumber: userData['idnumber'],
          status: userData['status'],
          degree: await getDegreeForStudent(document.id));

      graduatingStudentsList.add(graduatingStudent);
    }
  } catch (e) {
    print(e);
  }
  return graduatingStudentsList;
}

Future<void> getNoEnrolledCourseStudents() async {
  noEnrolledStudents.clear();

  for (Student stud in studentList) {
    if (stud.enrolledCourses.isEmpty && stud.status != 'LOA') {
      if (!noEnrolledStudents.contains(stud)) {
        noEnrolledStudents.add(stud);
      }
    }

    if (stud.pastCourses
        .any((past) => past.grade == 6.5 || past.grade == 9.9)) {
      if (!noEnrolledStudents.contains(stud)) {
        print(stud.toJson());
        noEnrolledStudents.add(stud);
      }
    }
  }
}

Future<List<Student>> convertToStudentList(List<user> users) async {
  studentList.clear();
  ineligibleStudentList.clear();
  for (var user in users) {
    if (user.role == 'Graduate Student') {
      List<EnrolledCourseData> enrolledCourses =
          await getEnrolledCoursesForStudent(user.uid);
      List<PastCourse> pastCourses = await getPastCoursesForStudent(user.uid);
      String degree =
          await getDegreeForStudent(user.uid); // Fetch degree information
      String status = await getStudentStatus(user.uid);
      // You need to fetch past courses here, update accordingly
      Student studentToAdd = Student(
        uid: user.uid,
        displayname: user.displayname,
        role: user.role,
        email: user.email,
        idnumber: user.idnumber,
        enrolledCourses: enrolledCourses,
        pastCourses: pastCourses,
        degree: degree,
        status: status,
      );
      studentList.add(studentToAdd);

      if (isIneligibleToEnroll(studentToAdd)) {
        ineligibleStudentList.add(Student(
          uid: user.uid,
          displayname: user.displayname,
          role: user.role,
          email: user.email,
          idnumber: user.idnumber,
          enrolledCourses: enrolledCourses,
          pastCourses: pastCourses,
          degree: degree,
          status: status,
        ));
      }
    }
  }

  return studentList;
}

bool isGraduatingWithinTimeFrame(String degree, String idNumber) {
  // Disregard if idNumber is '0'
  if (idNumber == '0') {
    return true;
  }

  // Extract the year from the ID number
  int idYear =
      int.parse(idNumber.substring(0, 3)) + 1900; // Convert to full year

  // Get the current year
  int currentYear = DateTime.now().year;

  // Calculate the maximum graduation year based on degree
  int maxGraduationYear;
  if (degree.toLowerCase().contains('doctorate')) {
    maxGraduationYear = idYear + 10;
  } else if (degree.toLowerCase().contains('masters')) {
    maxGraduationYear = idYear + 8;
  } else {
    // For other degrees, return true (no specific time frame)
    maxGraduationYear = idYear + 8;
  }

  // Check if the current year is within the time frame
  return currentYear <= maxGraduationYear;
}

bool hasTooManyLowGrades(List<PastCourse> pastCourses) {
  int lowGradeCourses = 0;
  int lowGradeUnits = 0;

  for (PastCourse course in pastCourses) {
    if (course.grade < 2.0) {
      lowGradeCourses++;
      lowGradeUnits += course.units;
    }
  }

  // Check if more than 2 courses or more than 6 units have a grade below 2.0
  return lowGradeCourses >= 2 || lowGradeUnits >= 6;
}

bool isIneligibleToEnroll(Student student) {
  bool withinTimeFrame =
      isGraduatingWithinTimeFrame(student.degree, student.idnumber.toString());
  bool tooManyLowGrades = hasTooManyLowGrades(student.pastCourses);

  // A student is ineligible if they are not within the timeframe or have too many low grades
  return !withinTimeFrame || tooManyLowGrades;
}

Future<String> getStudentStatus(String studentUid) async {
  try {
    final DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentUid)
        .get();

    if (studentSnapshot.exists) {
      final Map<String, dynamic>? userData =
          studentSnapshot.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('degree')) {
        return userData['status'] as String;
      } else {
        print('Field "status" not found in document for student: $studentUid');
        return ''; // Return a default value or handle accordingly
      }
    } else {
      print('Student not found with uid: $studentUid');
      return ''; // Return a default value or handle accordingly
    }
  } catch (e) {
    print('Error retrieving status for student: $e');
    return ''; // Return a default value or handle accordingly
  }
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
