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

  }) : super(
          uid: uid,
          coursecode: coursecode,
          coursename: coursename,
          isactive: isactive,
          facultyassigned: facultyassigned,
          numstudents: numstudents,
          units: units,
        );

  factory EnrolledCourseData.fromJson(Map<String, dynamic> json) {
    return EnrolledCourseData(
      uid: json['uid'],
      coursecode: json['coursecode'],
      coursename: json['coursename'],
      isactive: json['isactive'],
      facultyassigned: json['facultyassigned'],
      numstudents: json['numstudents'],
      units: json['units'],
    );
  }
}



