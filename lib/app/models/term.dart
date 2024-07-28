import 'package:sysadmindb/app/models/courses.dart';

class Term {
  late String name;
  late List<Course> termcourses;

  Term(this.name, this.termcourses);

factory Term.fromJson(Map<String, dynamic> json) {
  final name = json['name'] as String;
  final List<dynamic> coursesJson = json['courses'] ?? [];

  final List<Course> termcourses = coursesJson
      .map((courseJson) {
        // Ensure each courseJson is a Map<String, dynamic>
        if (courseJson is Map<String, dynamic>) {
          return Course.fromMap(courseJson);
        } else {
          // Handle unexpected format
          print('Unexpected courseJson format: $courseJson');
          return Course.fromMap({});
        }
      })
      .toList();

  return Term(name, termcourses);
}

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'courses': termcourses.map((termcourse) => termcourse.toJson()).toList(),
    };
  }
}
