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
    required List<Map<String, String>> dayTimes,
    required String section,
    required String syAndTerm,
    required String setup,
    required String onlineDay,
    required String roomNum,
  }) : super(
            roomNum: roomNum,
            setup: setup,
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
            onlineDay: onlineDay);

  factory PastCourse.fromJson(Map<String, dynamic> json) {
    return PastCourse(
        uid: json['uid'],
        setup: json['setup'],
        coursecode: json['coursecode'],
        coursename: json['coursename'],
        isactive: json['isactive'],
        facultyassigned: json['facultyassigned'],
        numstudents: json['numstudents'],
        units: json['units'],
        grade: json['grade'],
        type: json['type'],
        program: json['program'],
        dayTimes: List<Map<String, String>>.from(
          (json['dayTimes'] as List).map(
            (item) => Map<String, String>.from(item as Map),
          ),
        ),
        section: json['section'] ?? '',
        syAndTerm: json['syAndTerm'] ?? '',
        roomNum: json['roomNum'],
        onlineDay: json['onlineDay']);
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
