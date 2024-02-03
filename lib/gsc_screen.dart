import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:sysadmindb/app/models/coursedemand.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/faculty.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/ui/form.dart';
import 'package:sysadmindb/ui/studentinfopopup.dart';

void main() {
  runApp(
    MaterialApp(home: Gscscreen()),
  );
}

class Gscscreen extends StatefulWidget {
  const Gscscreen({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<Gscscreen> {
  final controller = TextEditingController();
  var collection = FirebaseFirestore.instance.collection('faculty');
  late List<Map<String, dynamic>> items;
  bool isLoaded = true;
  late String texttest;
  List<Faculty> foundFaculty = [];
  List<Student> foundStudents = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<List<Student>> graduateStudents = convertToStudentList(users);
  List<Course> foundCourse = [];
  String? selectedCourseDemand;
  String? selectedCourseState = 'Active';
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  bool isValidPass = false;
  bool isEditing = false;

  /// The currently selected index of the bar
  int selectedIndex = 0;

  @override
  initState() {
    setState(() {
      foundCourse = courses;
      foundFaculty = facultyList;
      foundStudents = studentList;
    });

    print("set state for found users");
    super.initState();
    //getCourseDemandsFromFirestore();
  }

  void _editFacultyData(BuildContext context, Faculty faculty) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController firstNameController =
        TextEditingController(text: faculty.displayname['firstname']);
    TextEditingController lastNameController =
        TextEditingController(text: faculty.displayname['lastname']);
    TextEditingController emailController =
        TextEditingController(text: faculty.email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Faculty'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildEditableField('First Name', firstNameController, false),
                _buildEditableField('Last Name', lastNameController, false),
                _buildEditableField('Email', emailController, false),
              ],
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
                          'Are you sure you want to delete this faculty member?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false); // No, do not delete
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
                    // Update the facultyassigned field in courses
                    QuerySnapshot courseSnapshot = await FirebaseFirestore
                        .instance
                        .collection('courses')
                        .where('facultyassigned',
                            isEqualTo: faculty.displayname)
                        .get();

                    for (QueryDocumentSnapshot courseDoc
                        in courseSnapshot.docs) {
                      String courseId = courseDoc.id;

                      await FirebaseFirestore.instance
                          .collection('courses')
                          .doc(courseId)
                          .update({
                        'facultyassigned':
                            'UNASSIGNED', // Set to an appropriate value
                      });
                    }

                    // Delete the faculty member
                    await FirebaseFirestore.instance
                        .collection('faculty')
                        .doc(faculty.uid)
                        .delete();

                    // Show a SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Faculty member deleted'),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Close the dialog
                    Navigator.pop(context);
                  } catch (e) {
                    print('Error deleting faculty member: $e');
                    // Handle the error
                  }

                  // If you want to refresh the faculty list after deleting a member

                  getFacultyList();
                  getCoursesFromFirestore();
                }
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Save the edited data locally
                setState(() {
                  faculty.displayname['firstname'] = firstNameController.text;
                  faculty.displayname['lastname'] = lastNameController.text;
                  faculty.email = emailController.text;
                });

                // Update the data in Firestore
                try {
                  await FirebaseFirestore.instance
                      .collection('faculty')
                      .doc(faculty
                          .uid) // Assuming you have a 'uid' field in your User class
                      .update({
                    'displayname': {
                      'firstname': firstNameController.text,
                      'lastname': lastNameController.text,
                    },
                    'email': emailController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Faculty updated'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  getCoursesFromFirestore();

                  // Trigger a rebuild
                  Navigator.pop(context);
                } catch (e) {
                  print('Error updating faculty data: $e');
                  // Handle the error
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editCourseData(BuildContext context, Course course) {
    bool hasStudents = false;
    List<String> status = ['true', 'false'];

    List<String> degrees = ['No degree', 'MIT', 'MSIT'];
    List<String> programs = ['MIT/MSIT', 'MIT', 'MSIT'];
    List<String> type = [
      'Bridging/Remedial Courses',
      'Foundation Courses',
      'Elective Courses',
      'Capstone',
      'Exam Course',
      'Specialized Courses'
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

    graduateStudents.then((List<Student> graduateStudentList) {
      graduateStudentList.forEach((student) {
        student.enrolledCourses.forEach((enrolledCourse) {
          if (enrolledCourse.coursecode == course.coursecode) {
            enrolledStudent.add(student);
          }
        });
      });
    });

    if (course.numstudents > 0) {
      print('!EMPTY');
      hasStudents = true;
    } else {
      print('EMPTY');
      hasStudents = false;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Course'),
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
                          decoration: InputDecoration(labelText: 'Course Type'),
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
                          decoration: InputDecoration(labelText: 'Is active?'),
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
                          'Enrolled Students',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        for (int i = 0; i < enrolledStudent.length; i++)
                          GestureDetector(
                            onTap: () {
                              // Handle the click event for the ListTile
                              currentStudent = enrolledStudent[i];
                              studentPOS = StudentPOS(
                                  studentIdNumber: enrolledStudent[i].idnumber,
                                  schoolYears: defaultschoolyears,
                                  uid: enrolledStudent[i].uid,
                                  displayname: enrolledStudent[i].displayname,
                                  role: enrolledStudent[i].role,
                                  email: enrolledStudent[i].email,
                                  idnumber: enrolledStudent[i].idnumber,
                                  enrolledCourses:
                                      enrolledStudent[i].enrolledCourses,
                                  pastCourses: enrolledStudent[i].pastCourses,
                                  degree: enrolledStudent[i].degree,
                                  status: enrolledStudent[i].status
                                  );

                              retrieveStudentPOS(enrolledStudent[i].uid);
                              _showStudentInfo(context, enrolledStudent[i]);
                            },
                            child: ListTile(
                              title: Text(
                                '${enrolledStudent[i].displayname['firstname']!} ${enrolledStudent[i].displayname['lastname']!}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(enrolledStudent[i].email),
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
                      content:
                          Text('Are you sure you want to delete this course?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false); // No, do not delete
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

  void runFacultyFilter(String query) {
    List<Faculty> results = [];
    if (query.isEmpty) {
      results = facultyList;
    } else {
      results = facultyList
          .where((faculty) =>
              faculty.displayname
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              faculty.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {
      foundFaculty = results; // Update foundFaculty with search results
    });
  }

  void runStudentFilter(String query) {
    List<Student> results = [];
    if (query.isEmpty) {
      results = studentList;
    } else {
      results = studentList
          .where((student) =>
              student.displayname
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              student.email.toLowerCase().contains(query.toLowerCase()) ||
              student.idnumber.toString().contains(query.toLowerCase()) ||
              student.enrolledCourses.any((course) {
                return course.coursecode
                    .toLowerCase()
                    .contains(query.toLowerCase());
              }) ||
              student.pastCourses.any((course) {
                return course.coursecode
                    .toLowerCase()
                    .contains(query.toLowerCase());
              }))
          .toList();
    }
    setState(() {
      foundStudents = results; // Update foundFaculty with search results
    });
  }

  void _showStudentInfo(BuildContext context, Student student) {
    StudentInfoPopup(student);
  }

  void changeScreen(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void savePasswordChanges(
      String newPassword,
      bool isMatching,
      bool isatmost64chars,
      bool hasNum,
      bool hasSpecial,
      bool curpassinc,
      bool is12chars) async {
    if (isMatching &&
        isatmost64chars &&
        hasNum &&
        hasSpecial &&
        curpassinc &&
        is12chars) {
      try {
        // Update password if successfully reauthenticated
        await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password changed successfully'),
            duration: Duration(seconds: 5),
          ),
        );
        setState(() {
          curpass = newPassword;
        });
      } catch (updateError) {
        print('Error updating password: $updateError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating password: $updateError'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } else {
      if (!curpassinc) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Current password is incorrect'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('See password requirements'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  bool is12charslong(String password) {
    return password.length >= 12;
  }

  bool isatmost64chars(String password) {
    return password.length <= 64;
  }

  bool hasSpecialChar(String password) {
    // Replace this with your logic to check if password has at least one special character
    RegExp specialCharRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
    return specialCharRegex.hasMatch(password);
  }

  bool hasNumber(String password) {
    // Replace this with your logic to check if password has at least one number
    RegExp numberRegex = RegExp(r'\d');
    return numberRegex.hasMatch(password);
  }

// check if the password meets the specified requirements
  String _capitalize(String input) {
    if (input.isEmpty) {
      return '';
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDemandData = uniqueCourses.firstWhere(
      (course) => course['coursecode'] == selectedCourseDemand,
      orElse: () => {'coursecode': '', 'demandCount': 0, 'uniqueDates': []},
    );
    // Extract demand count and unique dates
    final uniqueDates = selectedDemandData['uniqueDates'];

    // Prepare data for the BarChart
    final trendData = <BarChartGroupData>[];
    for (int i = 0; i < uniqueDates.length; i++) {
      final date = uniqueDates[i];
      final parts = date.split('/');
      final month = int.tryParse(parts[0]);
      // Check if trendData already contains data for this month

      // Determine how many times the current month appears in uniqueDates
      final monthCount = uniqueDates
          .where((date) => date.toString().startsWith("$month/"))
          .length;
      final existingDataIndex = trendData.indexWhere((data) => data.x == month);

      // Add demandCount to trendData and then subtract 1
      if (existingDataIndex != -1) {
      } else {
        trendData.add(
          BarChartGroupData(
            x: month!,
            barRods: [
              BarChartRodData(
                toY: monthCount.toDouble(),
                width: 15,
                color: Colors.amber,
              ),
            ],
          ),
        );
      }
    }

    // Convert Set to List and sort it
    final sortedTrendData = trendData.toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    // Clear the original Set and add sorted data back to it
    trendData.clear();
    trendData.addAll(sortedTrendData);

    bool is12chars = is12charslong(newPasswordController.text);
    bool isAtMost64chars = isatmost64chars(newPasswordController.text);
    bool hasSpecial = hasSpecialChar(newPasswordController.text);
    bool hasNum = hasNumber(newPasswordController.text);
    bool isMatching =
        confirmNewPasswordController.text == newPasswordController.text;
    bool curpassinc = false;

    /// Views to display
    List<Widget> views = [
      Scaffold(
        appBar: AppBar(
          title: Text("Dashboard"),
          backgroundColor: const Color.fromARGB(255, 23, 71, 25),
        ),
        body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: []),
      ),

      //COURSES SCREEN
      MaterialApp(
        home: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Program Management'),
                bottom: TabBar(
                  tabs: [
                    Tab(
                      text: 'Courses',
                    ),
                    Tab(text: 'Faculty'),
                    Tab(
                      text: 'Student POS',
                    )
                  ],
                  indicator: BoxDecoration(
                      color: Color.fromARGB(255, 15, 136, 31),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 10.0,
                            offset: Offset(0, 3))
                      ]),
                ),
                backgroundColor: const Color.fromARGB(255, 23, 71, 25),
              ),
              body: TabBarView(
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 25),
                                  child: Text("Courses",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      )),
                                )
                              ],
                            ),
                            Spacer(),
                            Column(
                              children: [
                                SizedBox(
                                    width: 500,
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            hintText: ' ',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.blue),
                                            )),
                                        onChanged: (value) =>
                                            runCourseFilter(value),
                                      ),
                                    )),
                              ],
                            ),
                            Column(children: [
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: TextButton(
                                    onPressed: () {
                                      showAddCourseForm(context, _formKey);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.all(20),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25))),
                                    child: Icon(Icons.post_add)),
                              )
                            ])
                          ],
                        ),
                        Expanded(
                            child: SizedBox(
                          width: 100.0,
                          height: 200.0,
                          child: ListView.builder(
                              // shrinkWrap: true,

                              itemCount: foundCourse.length,
                              itemBuilder: (context, index) => InkWell(
                                    onTap: () {
                                      enrolledStudent.clear();
                                      _editCourseData(
                                          context, foundCourse[index]);
                                    },
                                    child: Card(
                                      key: ValueKey(foundCourse[index]),
                                      color: Colors.white,
                                      elevation: 4,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 5),
                                      child: ListTile(
                                        title: Text(
                                          foundCourse[index].coursecode,
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "${foundCourse[index].facultyassigned}\n${foundCourse[index].coursename}"),
                                            Text(
                                              foundCourse[index].isactive
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style: TextStyle(
                                                color:
                                                    foundCourse[index].isactive
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                            )
                                          ],
                                        ),
                                        trailing: Text(
                                            "Enrolled Students: ${foundCourse[index].numstudents.toString()}"),
                                      ),
                                    ),
                                  )),
                        ))
                      ]),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 25),
                                  child: Text("Faculty",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      )),
                                )
                              ],
                            ),
                            Spacer(),
                            Column(
                              children: [
                                SizedBox(
                                    width: 500,
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            hintText: ' ',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.blue),
                                            )),
                                        onChanged: (value) =>
                                            runFacultyFilter(value),
                                      ),
                                    )),
                              ],
                            ),
                            Column(children: [
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        showAddFacultyForm(context, _formKey);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.all(20),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25))),
                                    child: Icon(Icons.domain_add_sharp)),
                              )
                            ])
                          ],
                        ),
                        Expanded(
                            child: SizedBox(
                          width: 100.0,
                          height: 200.0,
                          child: ListView.builder(
                              // shrinkWrap: true,

                              itemCount: foundFaculty.length,
                              itemBuilder: (context, index) => InkWell(
                                    onTap: () {
                                      _editFacultyData(
                                          context, foundFaculty[index]);
                                    },
                                    child: Card(
                                      key: ValueKey(foundFaculty[index]),
                                      color: Colors.white,
                                      elevation: 4,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 5),
                                      child: ListTile(
                                        title: Text(
                                          "${foundFaculty[index].displayname['firstname']} ${foundFaculty[index].displayname['lastname']}",
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(foundFaculty[index].email),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                        ))
                      ]),
                  Column(children: [
                    //* Student list on the left half, upon click -  student info on the right half //
                  ]),
                ],
              ),
            )),
      ),

      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Text("Calendar")]),
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Text("Inbox")]),
      SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 560,
                      child: SingleChildScrollView(
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 200, 70),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align text to the left
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Your profile",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  "${_capitalize(currentUser.displayname['firstname']!)} ${_capitalize(currentUser.displayname['lastname']!)} ",
                                  style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 23, 71, 25)),
                                ),
                                Text(currentUser.email),
                                
                               
                                Text('Status: ${currentUser.status}'),
                                Text(
                                  isValidPass
                                      ? '🔒 Your password is secure'
                                      : '✖ Your password is not secure',
                                  style: TextStyle(
                                      color: isValidPass
                                          ? Colors.green
                                          : Colors.red),
                                )
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
                    width: 560, // Set your desired width
                    child: SingleChildScrollView(
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 200, 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Password Management",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              TextFormField(
                                controller: currentPasswordController,
                                enabled: isEditing,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Current Password',
                                ),
                                validator: (value) {
                                  if (value != curpass) {
                                    curpassinc = false;
                                    return 'Current password is incorrect';
                                  }
                                  return null;
                                },
                              ),
                              TextField(
                                controller: newPasswordController,
                                enabled: isEditing,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                ),
                                onChanged: (password) {
                                  setState(() {
                                    is12chars = is12charslong(password);
                                    isAtMost64chars = isatmost64chars(password);
                                    hasSpecial = hasSpecialChar(password);
                                    hasNum = hasNumber(password);
                                    isMatching =
                                        confirmNewPasswordController.text ==
                                            newPasswordController.text;
                                  });
                                },
                              ),
                              TextField(
                                controller: confirmNewPasswordController,
                                enabled: isEditing,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Confirm New Password',
                                ),
                                onChanged: (passwordTextController) {
                                  setState(() {
                                    isMatching =
                                        confirmNewPasswordController.text ==
                                            newPasswordController.text;
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Password Requirements:',
                                    style: TextStyle(
                                      color: isEditing
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    is12chars
                                        ? '✔ At least 12 characters long'
                                        : '✖ At least 12 characters long',
                                    style: TextStyle(
                                      color: is12chars
                                          ? Colors.green
                                          : (isEditing
                                              ? Colors.red
                                              : Colors.grey),
                                    ),
                                  ),
                                  Text(
                                    isAtMost64chars
                                        ? '✔ At most 64 characters long'
                                        : '✖ At most 64 characters long',
                                    style: TextStyle(
                                      color: isEditing
                                          ? (isAtMost64chars
                                              ? Colors.green
                                              : Colors.red)
                                          : Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    hasSpecial
                                        ? '✔ Contains at least one special character'
                                        : '✖ Contains at least one special character',
                                    style: TextStyle(
                                      color: hasSpecial
                                          ? Colors.green
                                          : (isEditing
                                              ? Colors.red
                                              : Colors.grey),
                                    ),
                                  ),
                                  Text(
                                    hasNum
                                        ? '✔ Contains at least one number'
                                        : '✖ Contains at least one number',
                                    style: TextStyle(
                                      color: hasNum
                                          ? Colors.green
                                          : (isEditing
                                              ? Colors.red
                                              : Colors.grey),
                                    ),
                                  ),
                                  Text(
                                    isMatching
                                        ? '✔ New passwords match'
                                        : '✖ Passwords do not match',
                                    style: TextStyle(
                                      color: isEditing
                                          ? (isMatching
                                              ? Colors.green
                                              : Colors.red)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isEditing = !isEditing;
                                    if (!isEditing) {
                                      // Save changes when editing is done
                                      //updateUserProfile();
                                      if (currentPasswordController.text ==
                                          curpass) {
                                        curpassinc = true;
                                      }
                                      savePasswordChanges(
                                        newPasswordController.text,
                                        isMatching,
                                        isAtMost64chars,
                                        hasNum,
                                        hasSpecial,
                                        curpassinc,
                                        is12chars,
                                      );
                                      // Clear password fields
                                      currentPasswordController.clear();
                                      newPasswordController.clear();
                                      confirmNewPasswordController.clear();
                                    }
                                  });
                                },
                                child: Text(
                                  isEditing
                                      ? 'Save Password'
                                      : 'Change Password',
                                  style: TextStyle(
                                      color: isEditing
                                          ? const Color.fromARGB(
                                              255, 23, 71, 25)
                                          : Colors.grey),
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
          )),
    ];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // The row is needed to display the current view

        body: Row(
          children: [
            /// Pretty similar to the BottomNavigationBar!
            SideNavigationBar(
              header: SideNavigationBarHeader(
                  image: CircleAvatar(),
                  title: Text(
                    "${currentUser.displayname['firstname']!} ${currentUser.displayname['lastname']!}",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Text(
                    emailTextController.text.toLowerCase(),
                    style: TextStyle(
                      color: Color(0xFF747475),
                      fontSize: 12,
                    ),
                  )),
              footer: SideNavigationBarFooter(
                  label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.logout,
                      color: Color(0xFF747475),
                    ),
                    label: Text(
                      'Log Out',
                      style: TextStyle(color: Color(0xFF747475)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: () {
                      users.clear();
                      courses.clear();
                      activecourses.clear();
                      studentList.clear();

                      correctCreds = false;
                      foundCourse.clear();
                      wrongCreds = false;
                      enrolledStudent.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ],
              )),
              selectedIndex: selectedIndex,
              items: const [
                SideNavigationBarItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                ),
                SideNavigationBarItem(
                  icon: Icons.book,
                  label: 'Program Management',
                ),
                SideNavigationBarItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'Calendar',
                ),
                SideNavigationBarItem(
                  icon: Icons.message,
                  label: 'Inbox',
                ),
                SideNavigationBarItem(
                    icon: Icons.settings, label: 'Profile Settings')
              ],
              onTap: changeScreen,
              toggler: SideBarToggler(
                  expandIcon: Icons.keyboard_arrow_right,
                  shrinkIcon: Icons.keyboard_arrow_left,
                  onToggle: () {
                    print('Toggle');
                  }),
              theme: SideNavigationBarTheme(
                itemTheme: SideNavigationBarItemTheme(
                  labelTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 14),
                  unselectedItemColor: Color(0xFF747475),
                  selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
                  iconSize: 20,
                ),
                backgroundColor: Color(0xF0151718),
                togglerTheme: SideNavigationBarTogglerTheme(
                    expandIconColor: Colors.white,
                    shrinkIconColor: Colors.white),
                dividerTheme: SideNavigationBarDividerTheme.standard(),
              ),
            ),

            Expanded(
              child: views.elementAt(selectedIndex),
            )
          ],
        ),
      ),
    );
  }
}
