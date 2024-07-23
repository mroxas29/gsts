import 'package:sysadmindb/app/models/courses.dart';

class EnrolledCourseData extends Course {
  EnrolledCourseData({
    required String uid,
    required String coursecode,
    required String coursename,
    required bool isactive,
    required String facultyassigned,
    required int numstudents,
    required int units,
    required String type,
    required String program,
    required List<Map<String, String>> dayTimes,
    required String syAndTerm,
    required String section,
    required String roomNum,
    required String setup,
  }) : super(
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
          syAndTerm: syAndTerm,
          section: section,
          roomNum: roomNum,
          setup: setup,
        );

  factory EnrolledCourseData.fromJson(Map<String, dynamic> json) {
    return EnrolledCourseData(
      uid: json['uid'],
      setup: json['setup'],
      coursecode: json['coursecode'],
      coursename: json['coursename'],
      isactive: json['isactive'],
      facultyassigned: json['facultyassigned'],
      numstudents: json['numstudents'],
      units: json['units'],
      type: json['type'],
      program: json['program'],
      roomNum: json['roomNum'],
      dayTimes: List<Map<String, String>>.from(
        (json['dayTimes'] as List).map(
          (item) => Map<String, String>.from(item as Map),
        ),
      ),
      syAndTerm: json['syAndTerm'],
      section: json['section'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final courseData = super.toJson();
    courseData.addAll({
      'setup': setup,
      'roomNum': roomNum,
    });
    return courseData;
  }
}
