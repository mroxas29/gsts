import 'package:sysadmindb/app/models/term.dart';

class SchoolYear {
  String name;
  List<Term> terms;

  SchoolYear(this.name, this.terms);

  factory SchoolYear.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final termsJson = json['terms'] as List<dynamic>? ?? [];
    final terms = termsJson
        .map((termJson) => Term.fromJson(termJson as Map<String, dynamic>))
        .toList();

    return SchoolYear(name, terms);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'terms': terms.map((term) => term.toJson()).toList(),
    };
  }
}
