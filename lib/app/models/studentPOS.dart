import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/schoolYear.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/main.dart';

class StudentPOS extends Student {
  final int studentIdNumber;
  final List<SchoolYear> schoolYears;

  StudentPOS({
    required this.studentIdNumber,
    required this.schoolYears,
    required String uid,
    required Map<String, String> displayname,
    required String role,
    required String email,
    required int idnumber,
    required List<EnrolledCourseData> enrolledCourses,
    required List<PastCourse> pastCourses,
  }) : super(
          uid: uid,
          displayname: displayname,
          role: role,
          email: email,
          idnumber: idnumber,
          enrolledCourses: enrolledCourses,
          pastCourses: pastCourses,
        );

  factory StudentPOS.fromJson(Map<String, dynamic> json) {
    final List<dynamic> schoolYearsJson = json['schoolYears'] ?? [];
    final List<SchoolYear> schoolYears = schoolYearsJson
        .map(
            (yearJson) => SchoolYear.fromJson(yearJson as Map<String, dynamic>))
        .toList();

    return StudentPOS(
      studentIdNumber: json['studentIdNumber'] as int,
      schoolYears: schoolYears,
      uid: json['uid'],
      displayname:
          Map<String, String>.from(json['displayname'] as Map<String, dynamic>),
      role: json['role'],
      email: json['email'],
      idnumber: json['idnumber'],
      enrolledCourses: (json['enrolledCourses'] as List<dynamic>)
          .map<EnrolledCourseData>((courseJson) {
        return EnrolledCourseData.fromJson(courseJson as Map<String, dynamic>);
      }).toList(),
      pastCourses:
          (json['pastCourses'] as List<dynamic>).map<PastCourse>((courseJson) {
        return PastCourse.fromJson(courseJson as Map<String, dynamic>);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'studentIdNumber': studentIdNumber,
      'schoolYears': schoolYears.map((year) => year.toJson()).toList(),
    };
    data.addAll(super.toJson());
    return data;
  }
}

StudentPOS studentPOS = StudentPOS(
    studentIdNumber: currentStudent.idnumber,
    schoolYears: defaultschoolyears,
    uid: currentStudent.uid,
    displayname: currentStudent.displayname,
    role: currentStudent.role,
    email: currentStudent.email,
    idnumber: currentStudent.idnumber,
    enrolledCourses: currentStudent.enrolledCourses,
    pastCourses: currentStudent.pastCourses);

void studentPOSDefault() {
  studentPOS = StudentPOS(
      studentIdNumber: currentStudent.idnumber,
      schoolYears: defaultschoolyears,
      uid: currentStudent.uid,
      displayname: currentStudent.displayname,
      role: currentStudent.role,
      email: currentStudent.email,
      idnumber: currentStudent.idnumber,
      enrolledCourses: currentStudent.enrolledCourses,
      pastCourses: currentStudent.pastCourses);
}

List<SchoolYear> defaultschoolyears = List.generate(3, (index) {
  final currentYear = DateTime.now().year;
  final schoolYearName = '${currentYear + index} - ${currentYear + index + 1}';
  final terms = List<Term>.generate(3, (termIndex) {
    return Term('Term ${termIndex + 1}', []);
  });
  return SchoolYear(schoolYearName, terms);
});

Future<void> retrieveStudentPOS(String uid) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DocumentReference documentReference =
      firestore.collection('studentpos').doc(uid); // Use provided UID

  try {
    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      // Document exists, retrieve data
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        // Create a StudentPOS object from the retrieved data
        studentPOS = StudentPOS.fromJson(data);
        initializeSchoolYears();

        // Now you can use the studentPOS object as needed
      } else {
        print('Document data is null');
      }
    } else {
      print('Document does not exist for $uid');

      studentPOSDefault();
      initializeSchoolYears();
    }
  } catch (e) {
    print('Error retrieving document for Student POS: $e');
  }
}

void initializeSchoolYears() async {
  schoolyears = studentPOS.schoolYears;
}

List<SchoolYear> schoolyears = studentPOS.schoolYears;
