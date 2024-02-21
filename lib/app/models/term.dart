import 'package:sysadmindb/app/models/courses.dart';

class Term {
  late String name;
  late List<Course> termcourses;
  

  Term(this.name, this.termcourses);

  factory Term.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final List<dynamic> coursesJson = json['courses'] ?? [];
    final List<Course> termcourses = coursesJson
        .map((courseJson) => Course.fromMap(courseJson as Map<String, dynamic>))
        .toList();

    return Term(name, termcourses);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'name': name,
      'courses': termcourses.map((termcourse) => termcourse.toJson()).toList(),
    };
    return data;
  }
}

