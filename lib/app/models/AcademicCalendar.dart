import 'dart:core';

class AcademicCalendar {
  final String term;
  final DateTime startDate;
  final DateTime endDate;

  AcademicCalendar(this.term, this.startDate, this.endDate);
}

String getCurrentSYandTerm() {
  DateTime now = DateTime.now();
  for (AcademicCalendar calendar in academicCalendars) {
    if (now.isAfter(calendar.startDate) && now.isBefore(calendar.endDate)) {
      return "${now.year - 1}-${now.year} ${calendar.term}";
    }
  }
  return "No current term found";
}

String getNextSYandTerm() {
  DateTime now = DateTime.now();
  for (int i = 0; i < academicCalendars.length; i++) {
    AcademicCalendar calendar = academicCalendars[i];
    if (now.isAfter(calendar.startDate) && now.isBefore(calendar.endDate)) {
      // If the current date is within the current term, return the next term
      if (i + 1 < academicCalendars.length) {
        AcademicCalendar nextCalendar = academicCalendars[i + 1];
        return "${nextCalendar.startDate.year - 1}-${nextCalendar.endDate.year} ${nextCalendar.term}";
      }
    }
  }
  return "No next term found";
}

List<AcademicCalendar> academicCalendars = [
  AcademicCalendar("Term 1", DateTime(DateTime.now().year, 9, 1),
      DateTime(DateTime.now().year, 12, 31)),
  AcademicCalendar("Term 2", DateTime(DateTime.now().year, 1, 1),
      DateTime(DateTime.now().year, 4, 30)),
  AcademicCalendar("Term 3", DateTime(DateTime.now().year, 5, 1),
      DateTime(DateTime.now().year, 8, 31)),
];
