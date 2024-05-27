import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/coursedemand.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';

class AddCourseButton extends StatefulWidget {
  final Function(Course) onCourseAdded;
  final StudentPOS selectedStudentPOS;
  final String syAndTerm;
  AddCourseButton(
      {courses,
      required this.onCourseAdded,
      required allCourses,
      required this.selectedStudentPOS,
      required this.syAndTerm});

  @override
  _AddCourseButtonState createState() => _AddCourseButtonState();
}

class _AddCourseButtonState extends State<AddCourseButton> {
  String getCourseLocationInPOS(Course course) {
    for (var year in studentPOS.schoolYears) {
      for (var term in year.terms) {
        if (term.termcourses.contains(course)) {
          return "school year '${year.name}' and term '${term.name}'";
        }
      }
    }
    return "an unknown location"; // If course location is not found, return a default message
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

  String generateStudentList(String syAndTerm, Course targetCourse) {
    String fulfillingStudentPOS = '';
    // Get the next SY and term
    List<String> sytermParts = widget.syAndTerm.split(" ");

    for (int i = 0; i < studentPOSList.length; i++) {
      StudentPOS pos = studentPOSList[i];
      for (int j = 0; j < pos.schoolYears.length; j++) {
        SchoolYear sy = pos.schoolYears[j];
        if (sytermParts[0] == sy.name) {
          for (int k = 0; k < sy.terms.length; k++) {
            Term term = sy.terms[k];
            if (term.name == '${sytermParts[1]} ${sytermParts[2]}') {
              for (Course course in term.termcourses) {
                if (course.coursecode == targetCourse.coursecode) {
                  fulfillingStudentPOS +=
                      "${pos.idnumber}: ${pos.displayname['firstname']} ${pos.displayname['lastname']}\n";
                }
              }
            }
          }
        }
      }
    }
    if (fulfillingStudentPOS == '') {
      return "Students who will take the ${targetCourse.coursecode} on $syAndTerm:\nNo students found";
    } else {
      return "Students who will take the ${targetCourse.coursecode} on $syAndTerm:\n$fulfillingStudentPOS";
    }
  }

  bool _showTextField = false;
  TextEditingController _textEditingController = TextEditingController();
  List<Course> _suggestedCourses = courses;

  @override
  Widget build(BuildContext context) {
    return _showTextField
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textEditingController,
                onChanged: (text) {
                  // Filter courses based on user input
                  setState(() {
                    _suggestedCourses = courses
                        .where((course) =>
                            course.coursecode
                                .toLowerCase()
                                .contains(text.toLowerCase()) ||
                            course.coursename
                                .toLowerCase()
                                .contains(text.toLowerCase()) ||
                            course.program
                                .toLowerCase()
                                .contains(text.toLowerCase()) ||
                            course.type
                                .toLowerCase()
                                .contains(text.toLowerCase()))
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Type a course code or name",
                ),
              ),
              SizedBox(height: 8.0),
              SizedBox(
                height: MediaQuery.sizeOf(context).height / 3,
                width: MediaQuery.sizeOf(context).width / 3,
                child: ListView.builder(
                  itemCount: _suggestedCourses.length,
                  itemBuilder: (context, index) {
                    Course course = _suggestedCourses[index];
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.coursecode,
                                style: TextStyle(fontSize: 12.0),
                              ),
                              Text(
                                course.coursename,
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ],
                          ),
                          Spacer(),
                          Column(
                            children: [
                              Tooltip(
                                message: generateStudentList(
                                    widget.syAndTerm, course),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Icon(Icons.info_outline_rounded),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // Check if the course already exists in the specific school year and term
                        bool courseExistsInPOS =
                            widget.selectedStudentPOS.schoolYears.any((year) =>
                                year.terms.any((term) => term.termcourses.any(
                                    (c) => c.coursecode == course.coursecode)));

                        String courseLocation = '';

                        if (courseExistsInPOS) {
                          // If the course exists, show a Snackbar

                          for (var year
                              in widget.selectedStudentPOS.schoolYears) {
                            for (var term in year.terms) {
                              if (term.termcourses.any(
                                  (c) => c.coursecode == course.coursecode)) {
                                courseExistsInPOS = true;
                                courseLocation =
                                    "in SY. '${year.name}' and ${term.name}";
                              }
                            }
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "The course '${course.coursecode}' already exists in the Program of Study in $courseLocation."),
                            ),
                          );
                        } else {
                          // If the course doesn't exist, add it to the POS
                          widget.onCourseAdded(course);
                          // Reset TextField and suggestions
                          _textEditingController.clear();
                          setState(() {
                            _suggestedCourses = courses;
                            _showTextField = false;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          )
        : ListTile(
            title: Text(
              "Add a course",
              style: TextStyle(color: Colors.blue),
            ),
            onTap: () {
              setState(() {
                _showTextField = true;
              });
              // Handle tapping on the button
              // You can implement further actions here if needed
            },
          );
  }
}
