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
    required Map<String, Map<String, String>> dayTimes,
    required String syAndTerm,
    required String section,
    required bool isOnline,
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
          syAndTerm: syAndTerm,
          section: section,
        );

  factory EnrolledCourseData.fromJson(Map<String, dynamic> json) {
    return EnrolledCourseData(
      uid: json['uid'],
      isOnline: json['isOnline'],
      coursecode: json['coursecode'],
      coursename: json['coursename'],
      isactive: json['isactive'],
      facultyassigned: json['facultyassigned'],
      numstudents: json['numstudents'],
      units: json['units'],
      type: json['type'],
      program: json['program'],
      dayTimes: (json['dayTimes'] as Map<String, dynamic> ?? {}).map(
        (key, value) => MapEntry(key, Map<String, String>.from(value)),
      ),
      syAndTerm: json['syAndTerm'],
      section: json['section'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'dayTimes': dayTimes,
      'section': section,
    });
    return data;
  }
}
