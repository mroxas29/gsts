import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/term.dart';

class SchoolYear {
  final String name;
  final List<Term> terms;

  SchoolYear(this.name, this.terms);

  factory SchoolYear.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final List<dynamic> termsJson = json['terms'] ?? [];
    final List<Term> terms = termsJson
        .map((termJson) => Term.fromJson(termJson as Map<String, dynamic>))
        .toList();

    return SchoolYear(name, terms);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'name': name,
      'terms': terms.map((term) => term.toJson()).toList(),
    };
    return data;
  }
}

List<SchoolYear> schoolyears = List.generate(3, (index) {
  final currentYear = DateTime.now().year;
  final schoolYearName = '${currentYear + index} - ${currentYear + index + 1}';
  final terms = List<Term>.generate(3, (termIndex) {
    return Term('Term ${termIndex + 1}', []);
  });
  return SchoolYear(schoolYearName, terms);
});
