import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:kanban_board/custom/board.dart';
import 'package:kanban_board/models/inputs.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';

class StudentInfoPage extends StatefulWidget {
  final Student student;
  final StudentPOS studentpos;

  StudentInfoPage({required this.student, required this.studentpos});

  @override
  _StudentInfoPageState createState() => _StudentInfoPageState();
}

class _StudentInfoPageState extends State<StudentInfoPage> {
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

  @override
  Widget build(BuildContext context) {
    Student studentInfo = fetchStudentInfo(widget.student);
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Information'),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: MediaQuery.sizeOf(context).width / 3,
                          child: SingleChildScrollView(
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              elevation: 4.0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 200, 70),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Align text to the left
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Student profile",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      "${_capitalize(studentInfo.displayname['firstname']!)} ${_capitalize(studentInfo.displayname['lastname']!)} ",
                                      style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 23, 71, 25)),
                                    ),
                                    Text(studentInfo.degree.endsWith('SIT')
                                        ? 'Master of Science in Information Technology - ${studentInfo.idnumber.toString()}'
                                        : 'Master in Information Technology - ${studentInfo.idnumber.toString()}'),
                                    Text(studentInfo.email),
                                    Text(
                                        'Enrollment Status: ${studentInfo.status}'),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width /
                            3, // Set your desired width
                        child: SingleChildScrollView(
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 4.0,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Academic Progress",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Enrolled courses",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 150, // Set your desired height

                                    child: ListView.builder(
                                      itemCount:
                                          studentInfo.enrolledCourses.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final enrolledCourse =
                                            studentInfo.enrolledCourses[index];
                                        return ListTile(
                                          title: Text(
                                            "${enrolledCourse.coursecode}: ${enrolledCourse.coursename}",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          // Add any other details you want to display
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Past courses",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 150, // Set your desired height

                                    child: ListView.builder(
                                      itemCount: studentInfo.pastCourses.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final pastCourse =
                                            studentInfo.pastCourses[index];
                                        return ListTile(
                                          title: Text(
                                            "${pastCourse.coursecode}: ${pastCourse.coursename} (Grade:  ${pastCourse.grade.toDouble()})",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          // Add any other details you want to display
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Program of Study",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SingleChildScrollView(
                    // Allow horizontal scrolling
                    child: Column(
                      children: studentPOS.schoolYears.map<Widget>((year) {
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
                                  title: Text(
                                    year.name,
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  children: year.terms.expand<Widget>((term) {
                                    return [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: ExpansionTile(
                                          title: Text(
                                            term.name,
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                          children:
                                              term.termcourses.map((course) {
                                            return ListTile(
                                              title: Text(
                                                course.coursecode,
                                                style:
                                                    TextStyle(fontSize: 12.0),
                                              ),
                                              subtitle: Text(
                                                course.coursename,
                                                style:
                                                    TextStyle(fontSize: 12.0),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              8.0), // Add space between sub-expansion tiles
                                    ];
                                  }).toList(),
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
