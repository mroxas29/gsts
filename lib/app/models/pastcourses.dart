import 'package:sysadmindb/app/models/courses.dart';

class PastCourse extends Course {
  final double grade;

  PastCourse(
      {required String uid,
      required String coursecode,
      required String coursename,
      required bool isactive,
      required String facultyassigned,
      required int numstudents,
      required int units,
      required this.grade,
      required String type,
      required String program})
      : super(
            uid: uid,
            coursecode: coursecode,
            coursename: coursename,
            isactive: isactive,
            facultyassigned: facultyassigned,
            numstudents: numstudents,
            units: units,
            type: type,
            program: program);

  factory PastCourse.fromJson(Map<String, dynamic> json) {
    return PastCourse(
      uid: json['uid'],
      coursecode: json['coursecode'],
      coursename: json['coursename'],
      isactive: json['isactive'],
      facultyassigned: json['facultyassigned'],
      numstudents: json['numstudents'],
      units: json['units'],
      grade: json['grade'],
      type: json['type'],
      program: json['program']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'coursecode': coursecode,
      'coursename': coursename,
      'isactive': isactive,
      'facultyassigned': facultyassigned,
      'numstudents': numstudents,
      'units': units,
      'grade': grade,
      'type': type,
    };
  }
}

List<Map<String, dynamic>> pastCoursesData = [];

List<PastCourse> pastCourses = pastCoursesData
    .map((courseData) => PastCourse.fromJson(courseData))
    .toList();
