import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';

class AddCourseButton extends StatefulWidget {
  final Function(Course) onCourseAdded;
  final StudentPOS selectedStudentPOS;

  AddCourseButton(
      {courses,
      required this.onCourseAdded,
      required allCourses,
      required this.selectedStudentPOS});

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
                    final course = _suggestedCourses[index];
                    return ListTile(
                      title: Text(
                        course.coursecode,
                        style: TextStyle(fontSize: 12.0),
                      ),
                      subtitle: Text(
                        course.coursename,
                        style: TextStyle(fontSize: 12.0),
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
                            year.terms.forEach((term) {
                              if (term.termcourses.any(
                                  (c) => c.coursecode == course.coursecode)) {
                                courseExistsInPOS = true;
                                courseLocation =
                                    "in SY. '${year.name}' and ${term.name}";
                              }
                            });
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
