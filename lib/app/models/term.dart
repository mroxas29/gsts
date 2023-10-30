import 'package:sysadmindb/app/models/courses.dart';

class Term {
  final String name;
  final List<Course> termcourses;

  Term(this.name, this.termcourses);

  factory Term.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final List<dynamic> coursesJson = json['courses'] ?? [];
    final List<Course> courses = coursesJson
        .map((courseJson) => Course.fromMap(courseJson as Map<String, dynamic>))
        .toList();

    return Term(name, courses);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'name': name,
      'courses': courses.map((course) => course.toJson()).toList(),
    };
    return data;
  }
}
