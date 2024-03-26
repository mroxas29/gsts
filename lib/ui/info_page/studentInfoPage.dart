import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/DeviatedStudents.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/ui/forms/addcourse.dart';
import 'package:sysadmindb/ui/dashboard/gsc_dash.dart';

class StudentInfoPage extends StatefulWidget {
  final Student student;
  final StudentPOS studentpos;

  StudentInfoPage({required this.student, required this.studentpos});

  @override
  _StudentInfoPageState createState() => _StudentInfoPageState();
}


class _StudentInfoPageState extends State<StudentInfoPage> with SingleTickerProviderStateMixin{
  bool studentDeviated = false;
  late TabController _tabController;

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

  bool isStudentDeviated() {
    if (deviatedStudentList.any((devStudent) =>
        devStudent.studentPOS.idnumber == widget.studentpos.idnumber)) {
      setState(() {
        studentDeviated = true;
      });
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

  bool posEdited = false;

      @override
      void initState(){
        super.initState();
        _tabController = TabController(length: 2, vsync: this);
      }


  @override
  Widget build(BuildContext context) {
    Student studentInfo = fetchStudentInfo(widget.student);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.student.displayname['firstname']}\'s profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
          Tab(text: 'Student Information'),
          Tab(text: 'Program of Study'),
        ],),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
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
                                        "${_capitalize(studentInfo.displayname['firstname']!)} ${_capitalize(studentInfo.displayname['lastname']!)} ",
                                        style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 23, 71, 25)),
                                      ),
                                      Text(studentInfo.degree.contains('MSIT')
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
                                          final enrolledCourse = studentInfo
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
                                        itemCount:
                                            studentInfo.pastCourses.length,
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
               ],
            )),


            SingleChildScrollView(
              child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        setState(() {
                                          posEdited = false;
                                          getDeviatedStudents();
                                          isStudentDeviated();
                                          final FirebaseFirestore firestore =
                                              FirebaseFirestore.instance;
                                          Map<String, dynamic> studentPosData =
                                              widget.studentpos.toJson();
                                          firestore
                                              .collection('studentpos')
                                              .doc(widget.student.uid)
                                              .set(studentPosData);

                                          retrieveAllPOS();

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Program of Study updated'),
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
                          isStudentDeviated()
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Student enrolled in:",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    for (Course course
                                        in widget.studentpos.enrolledCourses)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Course ${course.coursecode}: ${course.coursename} supposed to be taken on ${findSYTerm(course)}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.red),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                  ],
                                )
                              : SizedBox(height: 0),
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
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: ExpansionTile(
                                              title: Text(
                                                term.name,
                                                style:
                                                    TextStyle(fontSize: 14.0),
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
                                                      getDeviatedStudents();
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
              
            )
        ]

      ),
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
