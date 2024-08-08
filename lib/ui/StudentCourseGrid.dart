import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/timeline.dart';

class StudentCourseDisplay extends StatelessWidget {
  final StudentPOS studentpos;
  final List<Timeline> timelines;
  StudentCourseDisplay({required this.studentpos, required this.timelines});

  Color checkCourseColor(Course course) {
    // Check if the course is in enrolledCourses
    if (studentpos.enrolledCourses
        .any((posCourse) => posCourse.coursecode == course.coursecode)) {
      return Colors.orange;
    }

    // Check if the course is in pastCourses with a passing grade
    if (studentpos.pastCourses.any((posCourse) =>
        posCourse.coursecode == course.coursecode && posCourse.grade >= 2.0)) {
      return Colors.green;
    }

    // Check if the course is in pastCourses with a failing grade
    if (studentpos.pastCourses.any((posCourse) =>
        posCourse.coursecode == course.coursecode &&
        (posCourse.grade < 2.0 || posCourse.grade == 6.5))) {
      return Colors.red;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height / 0.5,
      width: MediaQuery.sizeOf(context).width / 3,
      child: SingleChildScrollView(
        child: Card(
            elevation: 4.0,
            margin: EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Iterate through each school year and create a column for it
                  ...studentpos.schoolYears.map<Widget>((schoolyear) {
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // School Year Header
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            color: Colors.blue.withOpacity(0.3),
                            child: Center(
                              child: Text(
                                schoolyear.name,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  8.0), // Space between school year and terms

                          // Terms and Courses
                          Container(
                            margin: const EdgeInsets.all(
                                8.0), // Margin around the entire container
                            padding: const EdgeInsets.all(
                                8.0), // Padding inside the container
                            decoration: BoxDecoration(
                              color: Colors
                                  .white, // Background color for the container
                              borderRadius:
                                  BorderRadius.circular(12.0), // Border radius
                              border: Border.all(
                                color: Colors.grey
                                    .withOpacity(0.5), // Border color
                                width: 1.0, // Border width
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Create a container for each term within the school year
                                    ...schoolyear.terms.map<Widget>((term) {
                                      return Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.all(8.0),
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                8.0), // Rounded corners for term container
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255,
                                                  82,
                                                  82,
                                                  82), // Border color for term container
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Term name
                                              Text(
                                                term.name,
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),

                                              // Check for thesis or capstone courses in termcourses and enrolledcourses
                                              if (term.termcourses.any(
                                                  (course) =>
                                                      course.type
                                                          .toLowerCase()
                                                          .contains('thesis') &&
                                                      studentpos.enrolledCourses
                                                          .any((c) => c.type
                                                              .toLowerCase()
                                                              .contains(
                                                                  'thesis'))))
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4.0),
                                                  child: Text(
                                                    '(Thesis stage)',
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Color.fromARGB(
                                                          255, 2, 224, 32),
                                                    ),
                                                  ),
                                                )
                                              else if (term.termcourses.any(
                                                  (course) =>
                                                      course.type
                                                          .toLowerCase()
                                                          .contains(
                                                              'capstone') &&
                                                      studentpos.enrolledCourses
                                                          .any((c) => c.type
                                                              .toLowerCase()
                                                              .contains(
                                                                  'capstone'))))
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4.0),
                                                  child: Text(
                                                    '(Capstone stage)',
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Color.fromARGB(
                                                          255, 2, 224, 32),
                                                    ),
                                                  ),
                                                ),

                                              SizedBox(
                                                  height:
                                                      8.0), // Space between term name and courses

                                              // List of courses under each term
                                              ...term.termcourses
                                                  .map<Widget>((course) {
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 8.0),
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: checkCourseColor(
                                                        course),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0), // Rounded corners for course container
                                                    border: Border.all(
                                                      color: checkCourseColor(
                                                          course),
                                                    ), // Border color for course container
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        course.coursecode,
                                                        style: TextStyle(
                                                          fontSize: 13.0,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        course.type,
                                                        style: TextStyle(
                                                          fontSize: 11.0,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),

                                              // Timeline summary
                                              ..._buildTimelineSummary(
                                                  term.name, schoolyear.name),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            )),
      ),
    );
  }

  String normalize(String str) => str.trim().toLowerCase();
// Function to build timeline summary for a given term and school year
  List<Widget> _buildTimelineSummary(String termName, String schoolYearName) {
    // Filter timelines based on the current term and school year
    List<Timeline> filteredTimelines = [];
    for (Timeline timeline in this.timelines) {
      if (normalize(timeline.syAndterm) ==
          normalize("$schoolYearName $termName")) {
        filteredTimelines.add(timeline);
      }
    }

    if (filteredTimelines.isEmpty) {
      return [
        Text(
          'No timelines for $schoolYearName $termName',
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.red,
          ),
        )
      ];
    }

    // Group timelines by title and summarize details
    final Map<String, List<FormattedDetail>> timelinesByTitle = {};
    for (var timeline in filteredTimelines) {
      if (!timelinesByTitle.containsKey(timeline.title)) {
        timelinesByTitle[timeline.title] = [];
      }

      // Format the details based on title
      if (timeline.title == "Grade submitted") {
        FormattedDetail formattedDetail =
            formatGradeDetail(timeline.description);
        timelinesByTitle[timeline.title]!.add(formattedDetail);
      } else if (timeline.title.toLowerCase().contains('enrollment')) {
        List<String> formattedCourses =
            formatEnrollmentDetail(timeline.description);
        timelinesByTitle[timeline.title]!.addAll(
          formattedCourses
              .map((course) => FormattedDetail(course, Colors.black)),
        );
      } else if (timeline.title == "Submitted Document") {
        List<String> formattedDocuments =
            formatSubmittedDocumentDetail(timeline.description);
        timelinesByTitle[timeline.title]!.addAll(
          formattedDocuments.map((doc) => FormattedDetail(doc, Colors.black)),
        );
      } else {
        timelinesByTitle[timeline.title]!
            .add(FormattedDetail(timeline.description, Colors.black));
      }
    }

    // Build widgets for each title
    return timelinesByTitle.entries.map<Widget>((entry) {
      final title = entry.key;
      final details = entry.value;

      return Container(
        margin: const EdgeInsets.only(top: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.blue.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            // Group details by title
            ...details.map<Widget>((detail) {
              return Text(
                detail.text,
                style: TextStyle(
                  fontSize: 12.0,
                  color: detail.color,
                ),
              );
            }).toList(),
          ],
        ),
      );
    }).toList();
  }

  List<String> formatSubmittedDocumentDetail(String description) {
    final regex = RegExp(r'Uploaded document for (\w+)');
    final match = regex.firstMatch(description);

    if (match != null) {
      final documentCode = match.group(1);
      if (documentCode != null && documentCode.isNotEmpty) {
        return [documentCode];
      }
    }
    return [description]; // Fallback in case the format doesn't match
  }

  List<String> formatEnrollmentDetail(String description) {
    final regex = RegExp(r'Enrollment to course (.+)');
    final match = regex.firstMatch(description);

    if (match != null) {
      final coursesString = match.group(1);
      if (coursesString != null && coursesString.isNotEmpty) {
        // Split by commas or newlines
        final courses = coursesString
            .split(RegExp(r',|\n'))
            .map((course) => course.trim())
            .where((course) => course.isNotEmpty) // Ensure no empty courses
            .toList();
        return [...courses];
      } else {
        // Fallback in case the coursesString is null or empty
        return ['Courses enrolled:'];
      }
    } else {
      // Fallback in case the format doesn't match
      return [description];
    }
  }

  bool isFinished(String courseCode, List<PastCourse> pastCourses) {
    return pastCourses.any((pastCourse) =>
        pastCourse.coursecode == courseCode && pastCourse.grade >= 2.0);
  }

  void checkCourseCompletion(List<SchoolYear> schoolYears) {
    for (var schoolYear in schoolYears) {
      for (var term in schoolYear.terms) {
        // Group courses by type
        Map<String, List<String>> coursesByType = {
          'elective': [],
          'foundation': [],
          'remedial': [],
        };

        for (var course in term.termcourses) {
          if (coursesByType.containsKey(course.type.toLowerCase())) {
            coursesByType[course.type.toLowerCase()]!.add(course.coursecode);
          }
        }

        // Check if all courses of each type are finished
        coursesByType.forEach((type, courses) {
          bool allFinished = courses.every(
              (courseCode) => isFinished(courseCode, studentpos.pastCourses));

          if (allFinished) {
            // Add timeline entry
            addTimelineEntry(
                schoolYear.name, term.name, '$type courses completed');
          }
        });
      }
    }
  }

  void addTimelineEntry(
      String schoolYearName, String termName, String description) {
    timelines.add(Timeline(
      syAndterm: '$schoolYearName $termName',
      title: '$description',
      description: '$description completed for $schoolYearName $termName',
      type: 'Completion',
    ));
  }
}

class FormattedDetail {
  final String text;
  final Color color;

  FormattedDetail(this.text, this.color);
}

FormattedDetail formatGradeDetail(String description) {
  final regex = RegExp(r'Grade for course (\w+): (\d+)');
  final match = regex.firstMatch(description);

  if (match != null) {
    final courseCode = match.group(1);
    final grade = int.tryParse(match.group(2) ?? '') ?? 0;

    // Determine the color based on the grade
    final color = grade < 2.0 ? Colors.red : Colors.black;

    // Return the formatted detail with the appropriate color
    return FormattedDetail('$courseCode: $grade', color);
  } else {
    return FormattedDetail(description, Colors.black); // Fallback color
  }
}
