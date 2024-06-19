import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/api/email/invoice_service.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/DeviatedStudents.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/en-19.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/ui/forms/addcourse.dart';
import 'package:sysadmindb/ui/dashboard/gsc_dash.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviatedInfoPage extends StatefulWidget {
  final DeviatedStudent student;
  StudentPOS studentpos;
  EN19Form? en19;
  DeviatedInfoPage(
      {required this.student,
      required this.studentpos,
      required EN19Form en19});

  @override
  _DeviatedInfoPage createState() => _DeviatedInfoPage();
}

late Future<ListResult> documentations;
late Future<ListResult> defenseForms;

class _DeviatedInfoPage extends State<DeviatedInfoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  DeviatedStudent fetchStudentInfo(DeviatedStudent student) {
    return DeviatedStudent(
        studentPOS: widget.studentpos,
        deviatedCourses: widget.student.deviatedCourses);
  }

  bool isStillDeviated(String currentTerm, String foundTerm, Course course) {
    if (currentTerm != foundTerm) {
      return true;
    } else {
      return false;
    }
  }

  String _capitalize(String input) {
    if (input.isEmpty) {
      return '';
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  bool isStudentDeviated() {
    if (deviatedStudentList.any((devStudent) =>
        devStudent.studentPOS.idnumber == widget.studentpos.idnumber)) {
      return true;
    }

    return false;
  }

  String findSYTerm(Course course) {
    for (int i = 0; i < widget.studentpos.schoolYears.length; i++) {
      SchoolYear sy = widget.studentpos.schoolYears[i];
      for (int j = 0; j < sy.terms.length; j++) {
        Term term = sy.terms[j];

        if (term.termcourses.any((c) => c.coursecode == course.coursecode)) {
          return '${sy.name} ${term.name}';
        }
      }
    }
    return '(not found on POS)';
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

  void updateProgramOfStudy() async {
    // Set the flag to false before starting asynchronous operations
    setState(() {
      posEdited = false;
    });

    // Update deviated students
    getDeviatedStudents();

    // Set Firestore data
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> studentPosData = widget.studentpos.toJson();
    await firestore
        .collection('studentpos')
        .doc(widget.student.studentPOS.uid)
        .set(studentPosData);

    // Retrieve all POS data
    await retrieveAllPOS();

    // Show a snackbar after the asynchronous operations complete
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Program of Study updated'),
        duration: Duration(seconds: 2),
      ),
    );

    // Update the state after all asynchronous operations complete
    setState(() {});
  }

  void restructurePOS() async {
    // Set the flag to false before starting asynchronous operations
    setState(() {
      posEdited = true;
    });

    // Determine the maximum number of units based on the student's status
    int maxUnits = (widget.studentpos.status == 'Part Time') ? 6 : 12;

    // Set to track attempted moves
    Set<Course> attemptedToMove = {};

    // Iterate through school years
    for (int i = 0; i < widget.studentpos.schoolYears.length; i++) {
      SchoolYear year = widget.studentpos.schoolYears[i];
      bool movedToNextTerm = false;

      // Iterate through terms within the current year
      for (int j = 0; j < year.terms.length; j++) {
        Term term = year.terms[j];
        int termUnits =
            term.termcourses.fold(0, (acc, course) => acc + course.units);

        // Check if the current term is the same as the current SY and term
        if (getCurrentSYandTerm().contains(term.name) &&
            getCurrentSYandTerm().contains(year.name)) {
          // Add deviated courses to the term if there's space
          for (int devCourseIndex = 0;
              devCourseIndex < widget.student.deviatedCourses.length;
              devCourseIndex++) {
            Course devCourse = widget.student.deviatedCourses[devCourseIndex];

            // Check if the course has already been attempted to be moved
            if (attemptedToMove.contains(devCourse)) {
              continue;
            }

            if (!term.termcourses.contains(devCourse) &&
                termUnits + devCourse.units <= maxUnits) {
              // There's space in the current term, add the deviated course
              term.termcourses.add(devCourse);
              termUnits += devCourse.units;
              attemptedToMove
                  .add(devCourse); // Mark course as attempted to move
              widget.student.deviatedCourses.removeAt(devCourseIndex);
            }
          }

          // Try moving other courses to subsequent terms if the current term is full
          for (int k = 0; k < term.termcourses.length; k++) {
            Course courseToMove = term.termcourses[k];
            int remainingSpace = maxUnits - termUnits;
            if (remainingSpace < courseToMove.units) {
              // Try moving to subsequent terms
              for (int nextTermIndex = j + 1;
                  nextTermIndex < year.terms.length;
                  nextTermIndex++) {
                Term nextTerm = year.terms[nextTermIndex];
                int nextTermUnits = nextTerm.termcourses
                    .fold(0, (acc, course) => acc + course.units);
                int spaceInNextTerm = maxUnits - nextTermUnits;
                if (spaceInNextTerm >= courseToMove.units) {
                  // There's space in the next term, move the course
                  term.termcourses.removeAt(k);
                  nextTerm.termcourses.add(courseToMove);
                  termUnits -= courseToMove.units;
                  movedToNextTerm = true;
                  break; // Exit loop after moving a course
                }
              }
            }
          }
        }

        // If courses were moved to the next term, break out of the loop to prevent infinite processing
        if (movedToNextTerm) {
          break;
        }
      }
      // If courses were moved to the next term, break out of the outer loop as well
      if (movedToNextTerm) {
        break;
      }
    }

    // Clear attempted moves after restructuring
    attemptedToMove.clear();

    // Further processing such as handling unmovable courses or updating UI
    getDeviatedStudents();
  }

  bool posEdited = false;
  late Future<ListResult> futurefiles;
  PlatformFile? pickedFile;

  @override
  void initState() {
    super.initState();

    futurefiles = FirebaseStorage.instance
        .ref('/${widget.studentpos.idnumber}')
        .listAll();
    _tabController = TabController(length: 3, vsync: this);
  }

  List<DataRow> rows = [];
  final PdfInvoiceService service = PdfInvoiceService();

  List<Course> recommendedRemedialCourses = [];
  List<Course> recommendedPriorityCourses = [];

  @override
  Widget build(BuildContext context) {
    if (widget.studentpos.degree.contains('MIT')) {
      rows = capstonecourses.map((capstoneCourse) {
        return isCoursePassed(capstoneCourse, context);
      }).toList();
    } else if (widget.studentpos.degree.contains('MSIT')) {
      rows = thesiscourses.map((thesisCourse) {
        return isCoursePassed(thesisCourse, context);
      }).toList();
    }
    DeviatedStudent studentInfo = fetchStudentInfo(widget.student);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${_capitalize(studentInfo.studentPOS.displayname['firstname']!)}\'s profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Student Information'),
            Tab(text: 'Program of Study'),
            Tab(
              text: (studentInfo.studentPOS.degree == 'MIT')
                  ? 'Capstone Progress'
                  : 'Thesis Progress',
            )
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [
        SingleChildScrollView(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  padding: const EdgeInsets.fromLTRB(
                                      10, 10, 200, 70),
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
                                        "${_capitalize(studentInfo.studentPOS.displayname['firstname']!)} ${_capitalize(studentInfo.studentPOS.displayname['lastname']!)} ",
                                        style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 23, 71, 25)),
                                      ),
                                      Text(studentInfo.studentPOS.degree
                                              .contains('MSIT')
                                          ? 'Master of Science in Information Technology - ${studentInfo.studentPOS.idnumber.toString()}'
                                          : 'Master in Information Technology - ${studentInfo.studentPOS.idnumber.toString()}'),
                                      Text(studentInfo.studentPOS.email),
                                      Text(
                                          'Enrollment Status: ${studentInfo.studentPOS.status}'),
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
                                        itemCount: studentInfo
                                            .studentPOS.enrolledCourses.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final enrolledCourse = studentInfo
                                              .studentPOS
                                              .enrolledCourses[index];
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
                                        itemCount: studentInfo
                                            .studentPOS.pastCourses.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final pastCourse = studentInfo
                                              .studentPOS.pastCourses[index];
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
              ],
            )),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Program of Study",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: posEdited
                              ? () {
                                  // Implement logic to save studentPOS
                                  updateProgramOfStudy();
                                }
                              : null, // Disable the button when no course is added
                          child: Text("Save changes"),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Implement logic to save studentPOS
                            restructurePOS();
                          }, // Disable the button when no course is added
                          child: Text("Restructure POS"),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Student enrolled in:",
                          style: TextStyle(fontSize: 14),
                        ),
                        for (Course course in widget.studentpos.enrolledCourses)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Course ${course.coursecode}: ${course.coursename}  is supposed to be taken on ${findSYTerm(course)}",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: widget.student.deviatedCourses.any(
                                            (element) =>
                                                element.coursecode ==
                                                course.coursecode)
                                        ? Colors.red
                                        : Colors.black),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          )
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                          style: isStudentDeviated()
                                              ? getCurrentSYandTerm()
                                                      .contains(year.name)
                                                  ? TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors.red)
                                                  : TextStyle(
                                                      fontSize: 16.0,
                                                    )
                                              : TextStyle(fontSize: 16.0),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      ...year.terms.expand<Widget>((term) {
                                        return [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: ExpansionTile(
                                              title: Text(
                                                term.name,
                                                style: term.termcourses.any(
                                                        (termcourse) => widget
                                                            .student
                                                            .deviatedCourses
                                                            .any((devcourse) =>
                                                                devcourse
                                                                    .coursecode ==
                                                                termcourse
                                                                    .coursecode))
                                                    ? TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.red)
                                                    : TextStyle(fontSize: 14.0),
                                              ),
                                              children: [
                                                ...term.termcourses
                                                    .map((course) {
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
                                                            setState(() {
                                                              setState(() {
                                                                recommendedRemedialCourses.removeWhere(
                                                                    (toremove) =>
                                                                        toremove
                                                                            .coursecode ==
                                                                        course
                                                                            .coursecode);

                                                                recommendedPriorityCourses.removeWhere(
                                                                    (toremove) =>
                                                                        toremove
                                                                            .coursecode ==
                                                                        course
                                                                            .coursecode);
                                                                getDeviatedStudents();
                                                                term.termcourses
                                                                    .remove(
                                                                        course);
                                                                posEdited =
                                                                    true;
                                                              });

                                                              getDeviatedStudents();
                                                              term.termcourses
                                                                  .remove(
                                                                      course);
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
                                                }),
                                                SizedBox(
                                                    height:
                                                        8.0), // Add space between course tiles
                                                AddCourseButton(
                                                  onCourseAdded: (course) {
                                                    setState(() {
                                                      int syIndex = widget
                                                          .studentpos
                                                          .schoolYears
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

                                                      if (!isStillDeviated(
                                                          widget
                                                              .studentpos
                                                              .schoolYears[
                                                                  syIndex]
                                                              .terms[termIndex]
                                                              .name,
                                                          findSYTerm(course),
                                                          course)) {
                                                        for (int i = 0;
                                                            i <
                                                                widget
                                                                    .student
                                                                    .deviatedCourses
                                                                    .length;
                                                            i++) {
                                                          if (widget
                                                                  .student
                                                                  .deviatedCourses[
                                                                      i]
                                                                  .coursecode ==
                                                              course
                                                                  .coursecode) {
                                                            widget.student
                                                                .deviatedCourses
                                                                .removeAt(i);
                                                          }
                                                        }
                                                      }

                                                      getDeviatedStudents();
                                                    });
                                                  },
                                                  allCourses: courses,
                                                  selectedStudentPOS:
                                                      widget.studentpos,
                                                  syAndTerm:
                                                      "${widget.studentpos.schoolYears[widget.studentpos.schoolYears.indexOf(year)].name} ${widget.studentpos.schoolYears[widget.studentpos.schoolYears.indexOf(year)].terms[widget.studentpos.schoolYears[widget.studentpos.schoolYears.indexOf(year)].terms.indexOf(term)].name}",
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
                    SizedBox(
                      width: 10,
                    ),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: widget.studentpos.schoolYears
                                      .expand<Widget>((year) {
                                    return [
                                      Container(
                                        color: Colors.blue.withOpacity(0.3),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildSchoolYearRow(year),
                                          ],
                                        ),
                                      ),
                                      ...year.terms.expand<Widget>((term) {
                                        return [
                                          Container(
                                            color:
                                                Colors.green.withOpacity(0.3),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                _buildTermRow(term),
                                              ],
                                            ),
                                          ),
                                          if (getCurrentSYandTerm()
                                                  .contains(term.name) &&
                                              getCurrentSYandTerm()
                                                  .contains(year.name))
                                            Row(
                                              children: widget
                                                  .student.deviatedCourses
                                                  .map<Widget>((devCourse) =>
                                                      _buildSuggestedCourseRow(
                                                          devCourse,
                                                          year,
                                                          term))
                                                  .toList(),
                                            ),
                                          Row(
                                            children: term.termcourses
                                                .map<Widget>((course) {
                                              return Expanded(
                                                child: _buildCourseRow(course,
                                                    year.name, term.name),
                                              );
                                            }).toList(),
                                          ),
                                        ];
                                      }).toList(),
                                    ];
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Thesis Courses List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height:
                            8), // Optional: Adjust the space from top if needed
                    Center(
                      child: DataTable(
                        columns: columns,
                        rows: rows,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }

  DataCell buildDocDataCell(
    Course course,
    BuildContext context,
    String reference,
  ) {
    // Get the download URL of the file from Firebase Storage
    Reference emptyReference =
        FirebaseStorage.instance.ref(); // Or any other path

    return DataCell(
      SizedBox(
        width: MediaQuery.of(context).size.width / 7,
        child: FutureBuilder<ListResult>(
          future: futurefiles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              var files = snapshot.data!.items;

              // Find the file with the specified course code
              var file = files.firstWhere(
                  (file) => file.name.contains(course.coursecode),
                  orElse: (() => emptyReference));

              if (file != emptyReference) {
                return ListTile(
                  title: Text(
                    file.name,
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () async {
                          final imageUrl = await FirebaseStorage.instance
                              .ref()
                              .child(reference)
                              .getDownloadURL();
                          if (await canLaunch(imageUrl.toString())) {
                            await launch(imageUrl.toString());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to download file'),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                );
              } else {
                // No file found for the course code
                return ListTile(
                  title: Text(
                    'No file attached',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              }
            } else {
              return Center(
                child: Text('No data'),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> uploadFile(String coursecode) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName =
          '${widget.studentpos.idnumber}/${coursecode}_${widget.studentpos.idnumber}.pdf';

      Uint8List fileBytes = file.bytes!;
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putData(fileBytes);
    }

    setState(() {
      futurefiles = FirebaseStorage.instance
          .ref('/${widget.studentpos.idnumber}')
          .listAll();
    });
  }

  DataRow isCoursePassed(Course course, BuildContext context) {
    final bool isPassed = widget.studentpos.pastCourses.any((pastCourse) =>
        pastCourse.coursecode == course.coursecode && pastCourse.grade >= 2.0);
    final bool isNotPassed = widget.studentpos.pastCourses.any((pastCourse) =>
        pastCourse.coursecode == course.coursecode && pastCourse.grade < 2.0);
    final bool isInProgress = widget.studentpos.enrolledCourses.any(
        (enrolledCourse) => enrolledCourse.coursecode == course.coursecode);
    final bool isNotEnrolled = !isPassed && !isNotPassed && !isInProgress;

    Color color;
    IconData icon;
    String status;

    if (isPassed) {
      color = Colors.green;
      icon = Icons.check;
      status = 'Passed';
    } else if (isNotPassed) {
      color = Colors.red;
      icon = Icons.running_with_errors_outlined;
      status = 'Not Passed';
    } else if (isInProgress) {
      color = Colors.orange;
      icon = Icons.incomplete_circle;
      status = 'In Progress';
    } else {
      color = Colors.grey;
      icon = Icons.error;
      status = 'Not Enrolled';
    }

    return DataRow(cells: [
      DataCell(Text(
        course.coursecode,
        style: TextStyle(color: color),
      )),
      DataCell(Text(course.coursename, style: TextStyle(color: color))),
      DataCell(Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          SizedBox(width: 5),
          Text(status, style: TextStyle(color: color)),
        ],
      )),
      buildDocDataCell(course, context,
          "${widget.studentpos.idnumber}/${course.coursecode}_${widget.studentpos.idnumber}.pdf")
    ]);
  }

  List<DataColumn> columns = [
    DataColumn(
        label: Text(
      'Course Code',
      style: TextStyle(fontWeight: FontWeight.bold),
    )),
    DataColumn(
        label: Text(
      'Course Name',
      style: TextStyle(fontWeight: FontWeight.bold),
    )),
    DataColumn(
        label: Text(
      'Status',
      style: TextStyle(fontWeight: FontWeight.bold),
    )),
    DataColumn(
        label: Text(
      'Document ',
      style: TextStyle(fontWeight: FontWeight.bold),
    )),
  ];
  Widget _buildSchoolYearRow(SchoolYear year) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Text(
        "S.Y ${year.name}",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTermRow(Term term) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Text(
        term.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSuggestedCourseRow(Course course, SchoolYear year, Term term) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            // Add the course to the POS in the specified school year and term
            setState(() {
              int syIndex = widget.studentpos.schoolYears.indexOf(year);
              int termIndex =
                  widget.studentpos.schoolYears[syIndex].terms.indexOf(term);

              for (int i = 0; i < widget.student.deviatedCourses.length; i++) {
                if (widget.student.deviatedCourses[i].coursecode ==
                    course.coursecode) {
                  widget.student.deviatedCourses.removeAt(i);
                }
              }

              for (int i = 0; i < widget.studentpos.schoolYears.length; i++) {
                for (int j = 0;
                    j < widget.studentpos.schoolYears[i].terms.length;
                    j++) {
                  for (int k = 0;
                      k <
                          widget.studentpos.schoolYears[i].terms[j].termcourses
                              .length;
                      k++) {
                    for (int a = 0;
                        a <
                            widget.studentpos.schoolYears[i].terms[j]
                                .termcourses.length;
                        a++) {
                      if (widget.studentpos.schoolYears[i].terms[j]
                              .termcourses[a].coursecode ==
                          course.coursecode) {
                        widget.studentpos.schoolYears[i].terms[j].termcourses
                            .removeAt(a);
                      }
                    }
                  }
                }
              }
              widget
                  .studentpos.schoolYears[syIndex].terms[termIndex].termcourses
                  .add(course);
              posEdited = true;

              isStillDeviated(
                  widget.studentpos.schoolYears[syIndex].terms[termIndex].name,
                  findSYTerm(course),
                  course);
              getDeviatedStudents();
            });
          },
          child: ListTile(
            title: Text(
              course.coursecode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            subtitle: Text(
              course.coursename,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseRow(Course course, String year, String term) {
    if (widget.student.deviatedCourses.isNotEmpty) {
      for (Course c in widget.student.deviatedCourses) {
        if (c.coursecode == course.coursecode) {
          return ListTile(
            title: Text(
              course.coursecode,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            subtitle: Text(course.coursename,
                style: TextStyle(fontSize: 12, color: Colors.red)),
          );
        }
      }
    }

    return ListTile(
      title: Text(
        course.coursecode,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(course.coursename, style: TextStyle(fontSize: 12)),
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
