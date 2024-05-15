import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/DeviatedStudents.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/faculty.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/ui/info_page/deviatedInfoPage.dart';
import 'package:sysadmindb/ui/forms/form.dart';
import 'package:sysadmindb/ui/info_page/studentInfoPage.dart';
import 'package:sysadmindb/ui/dashboard_utils/ineligible_list.dart';
import 'package:sysadmindb/ui/dashboard_utils/profileBox.dart';
import 'package:sysadmindb/ui/dashboard_utils/studentList.dart';
import 'package:sysadmindb/ui/dashboard_utils/deviatedList.dart';

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

List<String> sytermParts = getCurrentSYandTerm().split(" ");
Future<List<Student>> graduateStudents = convertToStudentList(users);

List<Course> foundCourse = courses;
Widget _buildEditableField(
    String label, TextEditingController controller, bool hasStudents) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          enabled: !hasStudents, // Disable TextField if hasStudents is true
        ),
      ],
    ),
  );
}

List<StudentPOS> getDeviatedStudents() {
  // Iterate through each studentPOS
  deviatedStudentList.clear();

  List<StudentPOS> posss = [];

  for (StudentPOS pos in studentPOSList) {
    List<Course> deviatedCoursesList = [];

    for (int i = 0; i < pos.schoolYears.length; i++) {
      SchoolYear sy = pos.schoolYears[i];
      for (int j = 0; j < sy.terms.length; j++) {
        Term term = sy.terms[j];
        if (sy.name == sytermParts[0] &&
            term.name == '${sytermParts[1]} ${sytermParts[2]}') {
          for (Course enrolledCourse in pos.enrolledCourses) {
            if (!sy.terms[j].termcourses.any(
                (course) => course.coursecode == enrolledCourse.coursecode)) {
              print(
                  "${pos.displayname.toString()} ${sy.name} ${term.name} ${enrolledCourse.coursecode}");
              deviatedCoursesList.add(enrolledCourse);
            }
          }

          if (deviatedCoursesList.isNotEmpty) {
            deviatedStudentList.add(DeviatedStudent(
                studentPOS: pos, deviatedCourses: deviatedCoursesList));
          }
        }
      }
    }
  }

  return posss;
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  String filter = '';

  List<StudentPOS> deviated = getDeviatedStudents();

  List<Student> filteredStudents = studentList; // Declare filteredStudents
  int toShow = 5;
  bool showClicked = false;

  Widget buildRanking(List<StudentPOS> studentpos) {
    // Calculate occurrences of each course for the next term of the current school year

    Map<Course, int> occurrences = {};

    void editCourseData(BuildContext context, Course course,
        List<StudentPOS> fulfillingStudentPOS) {
      bool hasStudents = false;
      List<String> status = ['true', 'false'];
      List<String> programs = ['MIT/MSIT', 'MIT', 'MSIT'];
      List<String> type = [
        'Bridging/Remedial Courses',
        'Foundation Courses',
        'Elective Courses',
        'Capstone',
        'Exam Course',
        'Specialized Courses',
        'Thesis Course'
      ];

      String selectedProgram = course.program;
      String selectedStatus = course.isactive.toString();
      String selectedType = course.type.toString();
      String selectedFaculty = course.facultyassigned.toString();

      final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
      TextEditingController coursecodeController =
          TextEditingController(text: course.coursecode);
      TextEditingController coursenameController =
          TextEditingController(text: course.coursename);
      TextEditingController unitsController =
          TextEditingController(text: course.units.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Course information'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEditableField(
                              'Course code', coursecodeController, hasStudents),
                          _buildEditableField(
                              'Course Name', coursenameController, hasStudents),
                          DropdownButtonFormField<String>(
                            value: selectedFaculty,
                            items: facultyList.map((faculty) {
                              return DropdownMenuItem<String>(
                                value:
                                    "${faculty.displayname['firstname']} ${faculty.displayname['lastname']}",
                                child: Text(getFullname(faculty)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedFaculty = value!;
                              });
                            },
                            decoration:
                                InputDecoration(labelText: 'Faculty Assigned'),
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedProgram,
                            items: programs.map((program) {
                              return DropdownMenuItem<String>(
                                value: program,
                                child: Text(program),
                              );
                            }).toList(),
                            onChanged: !hasStudents
                                ? (value) {
                                    setState(() {
                                      selectedProgram = value!;
                                    });
                                  }
                                : null,
                            decoration: InputDecoration(labelText: 'Program'),
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedType,
                            items: type.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: !hasStudents
                                ? (type) {
                                    setState(() {
                                      selectedType = type!;
                                    });
                                  }
                                : null,
                            decoration:
                                InputDecoration(labelText: 'Course Type'),
                          ),
                          _buildEditableField(
                              'Units', unitsController, hasStudents),
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            items: status.map((role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: !hasStudents
                                ? (value) {
                                    setState(() {
                                      selectedStatus = value!;
                                    });
                                  }
                                : null,
                            decoration:
                                InputDecoration(labelText: 'Is active?'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),

                    
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Predicted Students',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          for (int i = 0; i < fulfillingStudentPOS.length; i++)
                            GestureDetector(
                              onTap: () async {
                                // Handle the click event for the ListTile
                                await retrieveStudentPOS(
                                    fulfillingStudentPOS[i].uid);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentInfoPage(
                                      student: fulfillingStudentPOS[i],
                                      studentpos: fulfillingStudentPOS[i],
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                mouseCursor: SystemMouseCursors.click,
                                title: Text(
                                  '${fulfillingStudentPOS[i].displayname['firstname']!} ${fulfillingStudentPOS[i].displayname['lastname']!}',
                                  style: fulfillingStudentPOS[i]
                                          .enrolledCourses
                                          .any(
                                            (enrolledCourse) =>
                                                enrolledCourse.coursecode ==
                                                course.coursecode,
                                          )
                                      ? TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red, // Set color to red
                                        )
                                      : TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  fulfillingStudentPOS[i].email,
                                  style: fulfillingStudentPOS[i]
                                          .enrolledCourses
                                          .any(
                                            (enrolledCourse) =>
                                                enrolledCourse.coursecode ==
                                                course.coursecode,
                                          )
                                      ? TextStyle(
                                          color: Colors.red) // Set color to red
                                      : TextStyle(), // Or use default color
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Show a confirmation dialog before deletion
                  bool confirmDelete = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Delete'),
                        content: Text(
                            'Are you sure you want to delete this course?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context, false); // No, do not delete
                            },
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true); // Yes, delete
                            },
                            child: Text('Yes'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete == true) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('courses')
                          .doc(course.uid)
                          .delete();
                      courses.clear();

                      getCoursesFromFirestore()
                          .then((value) => {foundCourse = courses});
                      // Show a SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Course deleted'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // Close the dialog
                      Navigator.pop(context);
                    } catch (e) {
                      print('Error deleting course: $e');
                      // Handle the error
                    }
                  }
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Save the edited data locally
                    setState(() {
                      course.coursecode = coursecodeController.text;
                      course.coursename = coursenameController.text;
                      course.facultyassigned = selectedFaculty;
                      course.units = int.parse(unitsController.text);
                      course.isactive = bool.parse(selectedStatus);
                      course.type = selectedType;
                      course.program = selectedProgram;
                    });

                    // Update the data in Firestore
                    try {
                      await FirebaseFirestore.instance
                          .collection('courses')
                          .doc(course.uid)
                          .update({
                        'coursecode': course.coursecode,
                        'coursename': course.coursename,
                        'facultyassigned': course.facultyassigned,
                        'units': course.units,
                        'isactive': course.isactive,
                        'type': course.type,
                        'program': course.program,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Course updated'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      print('Error updating course data: $e');
                    }
                  }
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }

    // Get the next SY and term
    List<String> sytermParts = getNextSYandTerm().split(" ");
    print("NEXT SY AND TERM: ${sytermParts.toString()}");

    List<Course> generalCourses = [];
// Iterate through each StudentPOS
    for (int i = 0; i < studentpos.length; i++) {
      StudentPOS pos = studentpos[i];

      // Iterate through each schoolYear
      for (int j = 0; j < pos.schoolYears.length; j++) {
        SchoolYear sy = pos.schoolYears[j];

        // Check if the schoolYear matches the specified term
        if (sytermParts[0] == sy.name) {
          // Find the corresponding term
          Term term = sy.terms.firstWhere(
            (term) => term.name == '${sytermParts[1]} ${sytermParts[2]}',
          );
          for (int m = 0; m < term.termcourses.length; m++) {
            Course course = term.termcourses[m];

            generalCourses.add(course);
          }
        }
      }
    }

    List<MapEntry<Course, int>> uniqueCourses = [];

    for (Course course in generalCourses) {
      if (!uniqueCourses
          .any((entry) => entry.key.coursecode == course.coursecode)) {
        int occurrence = 0;
        for (Course c in generalCourses) {
          if (c.coursecode == course.coursecode) {
            occurrence += 1;
          }
        }

        if (occurrence > 0) {
          uniqueCourses.add(MapEntry(course, occurrence));
        }
      }
    }

// Sort uniqueCourses based on occurrence count
    uniqueCourses.sort((a, b) => b.value.compareTo(a.value));
    print(
        "UNIQUE COURSES:::  ${uniqueCourses.length} ${getCurrentSYandTerm()}");
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course demand for ${getNextSYandTerm()}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Material(
                elevation: 4, // Adjust elevation as needed
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Color.fromARGB(255, 82, 138, 84),
                    padding: EdgeInsets.fromLTRB(
                        16, 16, 16, 16), // Increase padding as needed
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < toShow; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0), // Set margin as needed
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 34, 80,
                                  52), // Set your desired background color here
                              borderRadius: BorderRadius.circular(
                                  10.0), // Set border radius as needed
                            ),
                            padding: const EdgeInsets.all(12.0),

                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${uniqueCourses[i].value}',
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'students',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      uniqueCourses[i].key.coursecode,
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    Text(uniqueCourses[i].key.type,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.white))
                                  ],
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // Handle information icon tap here
                                    Course selectedCourse =
                                        uniqueCourses[i].key;
                                    List<StudentPOS> fulfillingStudentPOS = [];
                                    for (int i = 0;
                                        i < studentpos.length;
                                        i++) {
                                      StudentPOS pos = studentpos[i];
                                      for (int j = 0;
                                          j < pos.schoolYears.length;
                                          j++) {
                                        SchoolYear sy = pos.schoolYears[j];
                                        if (sytermParts[0] == sy.name) {
                                          for (int k = 0;
                                              k < sy.terms.length;
                                              k++) {
                                            Term term = sy.terms[k];
                                            if (term.name ==
                                                '${sytermParts[1]} ${sytermParts[2]}') {
                                              for (Course course
                                                  in term.termcourses) {
                                                if (course.coursecode ==
                                                    selectedCourse.coursecode) {
                                                  fulfillingStudentPOS.add(pos);
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    editCourseData(
                                        context,
                                        uniqueCourses[i].key,
                                        fulfillingStudentPOS);
                                  },
                                ),
                              ],
                            ),
                          ),
                        Center(
                          child: TextButton(
                            onPressed: !showClicked
                                ? () {
                                    setState(() {
                                      toShow = uniqueCourses
                                          .length; // Assuming you have a variable named 'toShow' to keep track of how many more to show
                                      showClicked = true;
                                    });
                                  }
                                : () {
                                    setState(() {
                                      toShow =
                                          5; // Assuming you have a variable named 'toShow' to keep track of how many more to show
                                      showClicked = false;
                                    });
                                  },
                            child: !showClicked
                                ? Text(
                                    'Show ${uniqueCourses.length - toShow} more',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : Text(
                                    'minimize',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool totalStudentsClicked = false;
  bool newStudentsClicked = false;
  bool deviatedStudentsClicked = true;
  bool graduatingStudentsClicked = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
              fontSize: 38, fontFamily: 'inter', fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(75.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Updates",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      AspectRatio(
                        aspectRatio: 4,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: SizedBox(
                              width: double.infinity,
                              child: GridView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const PageScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  mainAxisSpacing: 20.0,
                                  crossAxisSpacing: 4.0,
                                  crossAxisCount: 1,
                                  childAspectRatio: 1,
                                ),
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  // Dummy data for counts (replace with actual data)
                                  int totalStudents = studentList
                                      .length; // Total number of students

                                  int newStudents = studentList
                                      .where((student) => student.idnumber
                                          .toString()
                                          .startsWith('123'))
                                      .length; // Number of new students
                                  int deviatedStudents = deviatedStudentList
                                      .length; // Number of deviated students

                                  return GestureDetector(
                                    onTap: () {
                                      if (index == 0) {
                                        print('Total Students Clicked');
                                        setState(() {
                                          totalStudentsClicked = true;
                                          newStudentsClicked = false;
                                          deviatedStudentsClicked = false;
                                          graduatingStudentsClicked = false;
                                        });
                                      }
                                      if (index == 1) {
                                        print('New Students Clicked');
                                        setState(() {
                                          totalStudentsClicked = false;
                                          newStudentsClicked = true;
                                          deviatedStudentsClicked = false;
                                          graduatingStudentsClicked = false;
                                        });
                                      }
                                      if (index == 2) {
                                        print('Deviated Students Clicked');
                                        setState(() {
                                          totalStudentsClicked = false;
                                          newStudentsClicked = false;
                                          deviatedStudentsClicked = true;
                                          graduatingStudentsClicked = false;
                                          getDeviatedStudents();
                                        });
                                      }
                                      if (index == 3) {
                                        print('Ineligible Students Clicked');
                                        setState(() {
                                          totalStudentsClicked = false;
                                          newStudentsClicked = false;
                                          deviatedStudentsClicked = false;
                                          graduatingStudentsClicked = false;
                                        });
                                      }
                                      if (index == 4) {
                                        print('Graduating Students Clicked');
                                        setState(() {
                                          totalStudentsClicked = false;
                                          newStudentsClicked = false;
                                          deviatedStudentsClicked = false;
                                          graduatingStudentsClicked = true;
                                        });
                                      }
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: ProfileBox(
                                        totalStudents: totalStudents,
                                        newStudents: newStudentList.length,
                                        deviatedStudents: deviatedStudents,
                                        ineligibleStudents:
                                            ineligibleStudentList.length,
                                        cardCount: index,
                                        graduatingStudents:
                                            graduatingStudentsList.length,
                                      ),
                                    ),
                                  );
                                },
                              )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    totalStudentsClicked
                        ? "Total Students (${getCurrentSYandTerm()})"
                        : newStudentsClicked
                            ? "New Students (${getCurrentSYandTerm()})"
                            : deviatedStudentsClicked
                                ? "Deviated Students (${getCurrentSYandTerm()})"
                                : graduatingStudentsClicked
                                    ? ' Graduating Students'
                                    : "Ineligible Students (${getCurrentSYandTerm()})", // Empty string if none of the buttons are clicked
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  if (totalStudentsClicked)
                    Expanded(
                        child: ListView.builder(
                            itemCount: studentList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  await retrieveStudentPOS(
                                      studentList[index].uid);

                                  late DeviatedStudent devStudent;
                                  bool isDeviated = false;
                                  for (DeviatedStudent student
                                      in deviatedStudentList) {
                                    if (student.studentPOS.idnumber ==
                                        studentList[index].idnumber) {
                                      devStudent = student;
                                      isDeviated = true;
                                    }
                                  }
                                  if (isDeviated) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DeviatedInfoPage(
                                          student: devStudent,
                                          studentpos: studentPOS,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StudentInfoPage(
                                          student: studentList[index],
                                          studentpos: studentPOS,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: StudentList(
                                    student: studentList[index],
                                  ),
                                ),
                              );
                            })),
                  if (newStudentsClicked)
                    Expanded(
                        child: newStudentList.isNotEmpty
                            ? ListView.builder(
                                itemCount: newStudentList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      await retrieveStudentPOS(
                                          newStudentList[index].uid);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StudentInfoPage(
                                            student: newStudentList[index],
                                            studentpos: studentPOS,
                                          ),
                                        ),
                                      );
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: StudentList(
                                        student: newStudentList[index],
                                      ),
                                    ),
                                  );
                                })
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'No new Students',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                  if (deviatedStudentsClicked)
                    Expanded(
                        child: deviatedStudentList.isNotEmpty
                            ? ListView.builder(
                                itemCount: deviatedStudentList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      await retrieveStudentPOS(
                                          deviatedStudentList[index]
                                              .studentPOS
                                              .uid);
                                      for (Course c
                                          in deviatedStudentList[index]
                                              .deviatedCourses) {
                                        print('before:${c.coursecode}');
                                      }
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DeviatedInfoPage(
                                            student: deviatedStudentList[index],
                                            studentpos: studentPOS,
                                          ),
                                        ),
                                      );
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: StudentTile(
                                        student: deviatedStudentList[index],
                                      ),
                                    ),
                                  );
                                })
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'No deviated Students',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                  if (!deviatedStudentsClicked &&
                      !newStudentsClicked &&
                      !totalStudentsClicked &&
                      !graduatingStudentsClicked)
                    Expanded(
                        child: ineligibleStudentList.isNotEmpty
                            ? ListView.builder(
                                itemCount: ineligibleStudentList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      await retrieveStudentPOS(
                                          ineligibleStudentList[index].uid);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StudentInfoPage(
                                              student:
                                                  ineligibleStudentList[index],
                                              studentpos: studentPOS),
                                        ),
                                      );
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: IneligibleList(
                                        student: ineligibleStudentList[index],
                                      ),
                                    ),
                                  );
                                })
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'No ineligible Students',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                  if (graduatingStudentsClicked)
                    Expanded(
                        child: graduatingStudentsList.isNotEmpty
                            ? ListView.builder(
                                itemCount: graduatingStudentsList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      await retrieveStudentPOS(
                                          graduatingStudentsList[index].uid);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StudentInfoPage(
                                              student:
                                                  graduatingStudentsList[index],
                                              studentpos: studentPOS),
                                        ),
                                      );
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: StudentList(
                                        student: graduatingStudentsList[index],
                                      ),
                                    ),
                                  );
                                })
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'No graduating Students',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                ],
              ),
            ),
            buildRanking(studentPOSList),
          ],
        ),
      ),
    );
  }
}
