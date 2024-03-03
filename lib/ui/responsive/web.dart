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
import 'package:sysadmindb/ui/form.dart';
import 'package:sysadmindb/ui/studentInfoPage.dart';
import 'package:sysadmindb/ui/utils/profileBox.dart';
import 'package:sysadmindb/ui/utils/studentTile.dart';

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

List<String> sytermParts = getCurrentSYandTerm().split(" ");
Future<List<Student>> graduateStudents = convertToStudentList(users);

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

  Widget buildRanking(List<StudentPOS> studentpos) {
    // Calculate occurrences of each course for the next term of the current school year
    Map<Course, int> occurrences = {};

    // Get the next SY and term
    List<String> sytermParts = getNextSYandTerm().split(" ");

    void editCourseData(
        BuildContext context, Course course, List<StudentPOS> studentposes) {
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
                          for (int i = 0; i < studentposes.length; i++)
                            GestureDetector(
                              onTap: () async {
                                // Handle the click event for the ListTile

                                await retrieveStudentPOS(studentposes[i].uid);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StudentInfoPage(
                                              student: studentposes[i],
                                              studentpos: studentposes[i],
                                            )));
                              },
                              child: ListTile(
                                mouseCursor: SystemMouseCursors.click,
                                title: Text(
                                  '${studentposes[i].displayname['firstname']!} ${studentposes[i].displayname['lastname']!}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(studentposes[i].email),
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

// Iterate through each StudentPOS
    for (int i = 0; i < studentpos.length; i++) {
      StudentPOS pos = studentpos[i];
      for (int j = 0; j < pos.schoolYears.length; j++) {
        SchoolYear sy = pos.schoolYears[j];
        if (sytermParts[0] == sy.name) {
          for (int k = 0; k < sy.terms.length; k++) {
            Term term = sy.terms[k];
            if (term.name == '${sytermParts[1]} ${sytermParts[2]}') {
              for (int m = 0; m < term.termcourses.length; m++) {
                Course course = term.termcourses[m];
                occurrences[course] = (occurrences[course] ?? 0) + 1;
              }
            }
          }
        }
      }
    }

    // Sort courses based on occurrences
    List<MapEntry<Course, int>> sortedCourses = occurrences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      child: Expanded(
        child: Material(
          elevation: 4, // Adjust elevation as needed
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Color.fromARGB(255, 25, 87, 27),
              padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.sizeOf(context).height /
                      2), // Increase padding as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course demand for ${getNextSYandTerm()}',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  for (int i = 0; i < sortedCourses.length; i++)
                    Row(
                      children: [
                        Text(
                          '${i + 1}. ${sortedCourses[i].key.coursecode} - ${sortedCourses[i].value} planned takers',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Handle information icon tap here
                            List<StudentPOS> fulfillingStudentPOS = [];
                            for (int i = 0; i < studentpos.length; i++) {
                              StudentPOS pos = studentpos[i];
                              for (int j = 0; j < pos.schoolYears.length; j++) {
                                SchoolYear sy = pos.schoolYears[j];
                                if (sytermParts[0] == sy.name) {
                                  for (int k = 0; k < sy.terms.length; k++) {
                                    Term term = sy.terms[k];
                                    if (term.name ==
                                        '${sytermParts[1]} ${sytermParts[2]}') {
                                      for (int m = 0;
                                          m < term.termcourses.length;
                                          m++) {
                                        fulfillingStudentPOS.add(pos);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                            editCourseData(context, sortedCourses[i].key,
                                fulfillingStudentPOS);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                            "New Students",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "Filter: ",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: filter == 'MIT'
                                  ? MaterialStateProperty.all(Colors.blue)
                                  : null, // Change background color based on selection
                            ),
                            onPressed: () {
                              setState(() {
                                filter = 'MIT';
                                filteredStudents = studentList
                                    .where(
                                        (student) => student.degree == filter)
                                    .toList();
                              });
                            },
                            child: Text(
                              'MIT',
                              style: TextStyle(
                                color: filter == 'MIT' ? Colors.white : null,
                              ),
                            ),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: filter == 'MSIT'
                                  ? MaterialStateProperty.all(Colors.blue)
                                  : null, // Change background color based on selection
                            ),
                            onPressed: () {
                              setState(() {
                                filter = 'MSIT';
                                filteredStudents = studentList
                                    .where(
                                        (student) => student.degree == filter)
                                    .toList();
                              });
                            },
                            child: Text('MSIT',
                                style: TextStyle(
                                  color: filter == 'MSIT' ? Colors.white : null,
                                )),
                          ),
                          SizedBox(
                            width: 10,
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
                                        childAspectRatio: 1),
                                itemCount: filteredStudents.length,
                                itemBuilder: ((context, index) {
                                  StudentPOS filteredStudentPOS =
                                      studentPOSList.firstWhere(
                                    (pos) =>
                                        pos.uid == filteredStudents[index].uid,
                                  );
                                  return ProfileBox(
                                    student: filteredStudents[index],
                                    pos: filteredStudentPOS,
                                  );
                                })),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Deviated Students (${getCurrentSYandTerm()})",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                          itemCount: deviatedStudentList.length,
                          itemBuilder: (context, index) {
                            return StudentTile(
                              student: deviatedStudentList[index],
                            );
                          })),
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
