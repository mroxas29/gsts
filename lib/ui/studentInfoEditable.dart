import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/ui/addcourse.dart';

class StudentInfoEditablePage extends StatefulWidget {
  final StudentPOS studentpos;
  final String uid;
  StudentInfoEditablePage({required this.studentpos, required this.uid});

  @override
  _StudentInfoEditableState createState() => _StudentInfoEditableState();
}

List<Course> foundCourse = courses;
List<String> _schoolYearRanges = List.generate(
  DateTime.now().year - 2015 + 1,
  (index) {
    int startYear = 2015 + index;
    int endYear = startYear + 1;
    int nextYear = endYear + 1;
    return '$startYear-$endYear to $endYear-$nextYear to $nextYear-${nextYear + 1}';
  },
);
List<Term> defaultTerm = List<Term>.generate(3, (termIndex) {
  return Term('Term ${termIndex + 1}', []);
});

class _StudentInfoEditableState extends State<StudentInfoEditablePage> {
  Student fetchStudentInfo(Student student) {
    // Replace this with your actual data fetching logic
    // For now, dummy data is used for illustration

    return Student(
        uid: student.uid,
        displayname: student.displayname,
        role: student.role,
        email: student.email,
        idnumber: student.idnumber,
        enrolledCourses: student.enrolledCourses,
        pastCourses: student.pastCourses,
        degree: student.degree,
        status: student.status);
  }

  String _capitalize(String input) {
    if (input.isEmpty) {
      return '';
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  void runCourseFilter(String query) {
    List<Course> results = [];
    if (query.isEmpty) {
      results = courses;
    } else {
      results = courses
          .where((courses) =>
              courses.coursecode
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              courses.coursename.toLowerCase().contains(query.toLowerCase()) ||
              courses.numstudents
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              courses.facultyassigned
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (query.toLowerCase() == "active" && courses.isactive ||
                  query.toLowerCase() == "inactive" && !courses.isactive))
          .toList();
    }
    setState(() {
      foundCourse = results;
      foundCourse.sort((a, b) => a.coursecode.compareTo(b.coursecode));
    });
  }

  bool posEdited = false;
  String selectedSYRange = _schoolYearRanges[_schoolYearRanges.length - 1];

  // Function to extract and store the year ranges from the selectedSYRange list
  void updateYearRanges(List<String> ranges) {
    List<String> selectedSYYearRange = selectedSYRange
        .split(' to ')
        .map((range) => range.substring(0, 9))
        .toList();

    setState(() {
      widget.studentpos.schoolYears[0].name = selectedSYYearRange[0];
      widget.studentpos.schoolYears[0].terms = defaultTerm;

      widget.studentpos.schoolYears[1].name = selectedSYYearRange[1];
      widget.studentpos.schoolYears[1].terms = defaultTerm;

      widget.studentpos.schoolYears[2].name = selectedSYYearRange[2];
      widget.studentpos.schoolYears[2].terms = defaultTerm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Existing Student POS'),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Program of Study",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        DropdownButton<String>(
                          value: selectedSYRange,
                          onChanged: (String? newValue) {
                            setState(() {
                              List<String> newRange = newValue!
                                  .split(' to ')
                                  .map((range) => range.substring(0, 9))
                                  .toList();
                              selectedSYRange = newValue;
                              updateYearRanges(newRange);
                              // Implement logic to update the program of study based on the selected school year range
                            });
                          },
                          items: _schoolYearRanges
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: posEdited
                              ? () {
                                  // Implement logic to save studentPOS
                                  setState(() {
                                    posEdited = false;

                                    final FirebaseFirestore firestore =
                                        FirebaseFirestore.instance;
                                    Map<String, dynamic> studentPosData =
                                        widget.studentpos.toJson();
                                    firestore
                                        .collection('studentpos')
                                        .doc(widget.uid)
                                        .set(studentPosData);

                                    retrieveAllPOS();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Program of Study updated'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  });
                                }
                              : null, // Disable the button when no course is added
                          child: Text("Save changes"),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    // Allow horizontal scrolling
                    child: Column(
                      children:
                          widget.studentpos.schoolYears.map<Widget>((year) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Theme(
                                data: ThemeData(
                                  dividerColor:
                                      Colors.transparent, // Remove border
                                ),
                                child: ExpansionTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        "S.Y ${year.name}",
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    ...year.terms.expand<Widget>((term) {
                                      return [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: ExpansionTile(
                                            title: Text(
                                              term.name,
                                              style: TextStyle(fontSize: 14.0),
                                            ),
                                            children: [
                                              ...term.termcourses.map((course) {
                                                return ListTile(
                                                  title: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          course.coursecode,
                                                          style: TextStyle(
                                                              fontSize: 12.0),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () {
                                                          // Implement logic to delete the course
                                                          // For example:
                                                          // setState(() {
                                                          //   // Assuming term.termcourses is a List<Course>
                                                          //   term.termcourses.remove(course);
                                                          // });
                                                          setState(() {
                                                            int syIndex =
                                                                studentPOS
                                                                    .schoolYears
                                                                    .indexOf(
                                                                        year);
                                                            int termIndex =
                                                                studentPOS
                                                                    .schoolYears[
                                                                        syIndex]
                                                                    .terms
                                                                    .indexOf(
                                                                        term);
                                                            studentPOS
                                                                .schoolYears[
                                                                    syIndex]
                                                                .terms[
                                                                    termIndex]
                                                                .termcourses
                                                                .remove(course);
                                                            posEdited = true;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: Text(
                                                    course.coursename,
                                                    style: TextStyle(
                                                        fontSize: 12.0),
                                                  ),
                                                );
                                              }).toList(),
                                              SizedBox(
                                                  height:
                                                      8.0), // Add space between course tiles
                                              AddCourseButton(
                                                onCourseAdded: (course) {
                                                  setState(() {
                                                    int syIndex = widget
                                                        .studentpos.schoolYears
                                                        .indexOf(year);
                                                    int termIndex = widget
                                                        .studentpos
                                                        .schoolYears[syIndex]
                                                        .terms
                                                        .indexOf(term);
                                                    widget
                                                        .studentpos
                                                        .schoolYears[syIndex]
                                                        .terms[termIndex]
                                                        .termcourses
                                                        .add(course);
                                                    posEdited = true;
                                                  });
                                                },
                                                allCourses: courses,
                                                selectedStudentPOS:
                                                    widget.studentpos,
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                8.0), // Add space between sub-expansion tiles
                                      ];
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}

class Coursetest {
  final String courseName;
  final String courseCode;

  Coursetest({required this.courseName, required this.courseCode});
}

class Section {
  final String sectionName;
  final List<Coursetest> courses;
  bool isExpanded;

  Section(
      {required this.sectionName,
      required this.courses,
      this.isExpanded = false});
}
