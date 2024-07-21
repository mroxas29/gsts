import 'package:sysadmindb/app/models/courses.dart';

class PastCourse extends Course {
  final double grade;

  PastCourse({
    required String uid,
    required String coursecode,
    required String coursename,
    required bool isactive,
    required String facultyassigned,
    required int numstudents,
    required int units,
    required this.grade,
    required String type,
    required String program,
    required Map<String, Map<String, String>> dayTimes,
    required String section,
    required String syAndTerm,
    required bool isOnline
  }) : super(
    isOnline: isOnline,
          uid: uid,
          coursecode: coursecode,
          coursename: coursename,
          isactive: isactive,
          facultyassigned: facultyassigned,
          numstudents: numstudents,
          units: units,
          type: type,
          program: program,
          dayTimes: dayTimes,
          section: section,
          syAndTerm: syAndTerm,
        );

  factory PastCourse.fromJson(Map<String, dynamic> json) {
    return PastCourse(
      uid: json['uid'],
      isOnline: json['isOnline'],
      coursecode: json['coursecode'],
      coursename: json['coursename'],
      isactive: json['isactive'],
      facultyassigned: json['facultyassigned'],
      numstudents: json['numstudents'],
      units: json['units'],
      grade: json['grade'],
      type: json['type'],
      program: json['program'],
      dayTimes: Map<String, Map<String, String>>.from(json['dayTimes'] ?? {}),
      section: json['section'] ?? '',
      syAndTerm: json['syAndTerm'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final courseData = super.toJson();
    courseData.addAll({
      'grade': grade,
    });
    return courseData;
  }
}

List<Map<String, dynamic>> pastCoursesData = [];

List<PastCourse> pastCourses = pastCoursesData
    .map((courseData) => PastCourse.fromJson(courseData))
    .toList();
