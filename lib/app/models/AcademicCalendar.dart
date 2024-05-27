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
      int startYear = calendar.startDate.year;
      int endYear = calendar.endDate.year;

      // Adjust the start year and end year to match the academic year format
      if (now.month < calendar.startDate.month) {
        startYear -= 1;
        endYear -= 1;
      }

      return "${calendar.term} of AY $startYear-$endYear";
    }
  }
  return "No current term found";
}

String getNextSYandTerm() {
  DateTime now = DateTime.now();
  for (int i = 0; i < academicCalendars.length; i++) {
    AcademicCalendar calendar = academicCalendars[i];
    if (now.isAfter(calendar.startDate) && now.isBefore(calendar.endDate)) {
      // If current date is within a term
      if (i == academicCalendars.length - 1) {
        // Check if it's the last term (avoiding out-of-bounds)
        return getNextSchoolYearTerm(calendar);
      } else {
        // If not the last term, return next term of current year
        AcademicCalendar nextCalendar = academicCalendars[i + 1];
        return "${nextCalendar.startDate.year}-${nextCalendar.endDate.year} ${nextCalendar.term}";
      }
    }
  }
  return "No next term found";
}

String getNextSchoolYearTerm(AcademicCalendar currentTerm) {
  int nextYear = currentTerm.startDate.year;
  // Assuming Term 1 always starts on January 1st
  return "${nextYear}-${nextYear + 1} Term 1";
}

List<AcademicCalendar> academicCalendars = [
  AcademicCalendar("Term 1", DateTime(DateTime.now().year, 9, 1),
      DateTime(DateTime.now().year, 12, 31)),
  AcademicCalendar("Term 2", DateTime(DateTime.now().year, 1, 1),
      DateTime(DateTime.now().year, 4, 30)),
  AcademicCalendar("Term 3", DateTime(DateTime.now().year, 5, 1),
      DateTime(DateTime.now().year, 8, 31)),
];
