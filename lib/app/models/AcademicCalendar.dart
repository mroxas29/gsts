class AcademicCalendar {
  String term;
  String duration;

  AcademicCalendar(this.term, this.duration);

  static List<AcademicCalendar> getAcademicYear() {
    return [
      AcademicCalendar('Term 1', 'September to December'),
      AcademicCalendar('Term 2', 'January to April'),
      AcademicCalendar('Term 3', 'May to August'),
    ];
  }
}
