import 'dart:core';

class AcademicCalendar {
  final String term;
  final DateTime startDate;
  final DateTime endDate;

  AcademicCalendar(this.term, this.startDate, this.endDate);
}

String getCurrentTerm(
    DateTime currentDate, List<AcademicCalendar> academicCalendars) {
  for (var academicCalendar in academicCalendars) {
    if (currentDate.isAfter(academicCalendar.startDate) &&
        currentDate.isBefore(academicCalendar.endDate)) {
      return academicCalendar.term;
    }
  }
  return "Unknown"; // Return "Unknown" if no matching term is found
}

List<AcademicCalendar> academicCalendars = [
  AcademicCalendar("Term 1", DateTime(DateTime.now().year, 9, 1),
      DateTime(DateTime.now().year, 12, 31)),
  AcademicCalendar("Term 2", DateTime(DateTime.now().year, 1, 1),
      DateTime(DateTime.now().year, 4, 30)),
  AcademicCalendar("Term 3", DateTime(DateTime.now().year, 5, 1),
      DateTime(DateTime.now().year, 8, 31)),
];

