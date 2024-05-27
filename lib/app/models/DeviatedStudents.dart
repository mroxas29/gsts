import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';

class DeviatedStudent {
  final StudentPOS studentPOS;
  final List<Course> deviatedCourses;

  DeviatedStudent({
    required this.studentPOS,
    required this.deviatedCourses,
  });
}

List<DeviatedStudent> deviatedStudentList = [];
