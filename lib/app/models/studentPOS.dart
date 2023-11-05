import 'package:sysadmindb/app/models/schoolYear.dart';

class StudentPOS {
  final int studentIdNumber;
  final List<SchoolYear> schoolYears;

  StudentPOS(this.studentIdNumber, this.schoolYears);

  factory StudentPOS.fromJson(Map<String, dynamic> json) {
    final studentIdNumber = json['studentIdNumber'] as int;
    final List<dynamic> schoolYearsJson = json['schoolYears'] ?? [];
    final List<SchoolYear> schoolYears = schoolYearsJson
        .map(
            (yearJson) => SchoolYear.fromJson(yearJson as Map<String, dynamic>))
        .toList();

    return StudentPOS(studentIdNumber, schoolYears);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'studentIdNumber': studentIdNumber,
      'schoolYears': schoolYears.map((year) => year.toJson()).toList(),
    };
    return data;
  }
}


