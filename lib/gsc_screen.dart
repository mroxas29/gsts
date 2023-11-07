import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:sysadmindb/app/models/coursedemand.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/faculty.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/ui/form.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<List<Student>> graduateStudents = convertToStudentList(users);
  List<Course> foundCourse = [];
  String? selectedCourseDemand;
  String? selectedCourseState;

  /// The currently selected index of the bar
  int selectedIndex = 0;

  @override
  initState() {
    setState(() {
      foundCourse = courses;
      foundFaculty = facultyList;
    });

    print("set state for found users");
    super.initState();
    //getCourseDemandsFromFirestore();
  }

  void _editFacultyData(BuildContext context, Faculty faculty) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController fullNameController =
        TextEditingController(text: faculty.fullName);
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
                _buildEditableField('Full Name', fullNameController),
                _buildEditableField('Email', emailController),
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
                        .where('facultyassigned', isEqualTo: faculty.fullName)
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
                  faculty.fullName = fullNameController.text;
                  faculty.email = emailController.text;
                });

                // Update the data in Firestore
                try {
                  await FirebaseFirestore.instance
                      .collection('faculty')
                      .doc(faculty
                          .uid) // Assuming you have a 'uid' field in your User class
                      .update({
                    'fullName': fullNameController.text,
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
    List<String> status = ['true', 'false'];
    List<String> type = [
      'Bridging/Remedial Courses',
      'Foundation Courses',
      'Elective Courses',
      'Capstone',
      'Exam Course'
    ];
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
            enrolledStudentNames.add(
                "${student.displayname['firstname']!} ${student.displayname['lastname']!}");
            enrolledStudentEmails.add(student.email);
            print(
                "${student.displayname['firstname']!} ${student.displayname['lastname']!}");
          }
        });
      });
    });

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
                            'Course code', coursecodeController),
                        _buildEditableField(
                            'Course Name', coursenameController),
                        DropdownButtonFormField<String>(
                          value: selectedFaculty,
                          items: facultyList.map((faculty) {
                            return DropdownMenuItem<String>(
                              value: faculty.fullName,
                              child: Text(faculty.fullName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFaculty = value!;
                              print(selectedFaculty);
                            });
                          },
                          decoration:
                              InputDecoration(labelText: 'Faculty Assigned'),
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          items: type.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (type) {
                            setState(() {
                              selectedType = type!;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Course Type'),
                        ),
                        _buildEditableField('Units', unitsController),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          items: status.map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
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
                        for (int i = 0; i < enrolledStudentNames.length; i++)
                          ListTile(
                            title: Text(
                              enrolledStudentNames[i],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(enrolledStudentEmails[i]),
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

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: controller),
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
              faculty.fullName
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              faculty.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {
      foundFaculty = results; // Update foundFaculty with search results
      foundFaculty.sort((a, b) => a.fullName.compareTo(b.fullName));
    });
  }

  void changeScreen(int index) {
    setState(() {
      selectedIndex = index;
    });
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
    int demandCount = selectedDemandData['demandCount'];
    print("demandcount: $demandCount");
    for (int i = 0; i < uniqueDates.length; i++) {
      final date = uniqueDates[i];
      final parts = date.split('/');
      final month = int.tryParse(parts[0]);
      // Check if trendData already contains data for this month

      // Determine how many times the current month appears in uniqueDates
      final monthCount = uniqueDates
          .where((date) => date.toString().startsWith("$month/"))
          .length;
      print("$month: $monthCount");

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

    /// Views to display
    List<Widget> views = [
      Scaffold(
        appBar: AppBar(
          title: Text("Dashboard"),
          backgroundColor: const Color.fromARGB(255, 23, 71, 25),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      )
                    ]),
                constraints: BoxConstraints(maxWidth: 600, maxHeight: 500),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Course Demands: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(
                              child: Align(
                            alignment: Alignment.centerLeft,
                            child: DropdownButton<String>(
                              value: selectedCourseDemand,
                              style: TextStyle(fontSize: 20),
                              onChanged: (String? uniqueCourses) {
                                setState(() {
                                  selectedCourseDemand = uniqueCourses!;
                                });
                              },
                              items: uniqueCourses.map((course) {
                                final courseCode = course['coursecode'];
                                return DropdownMenuItem<String>(
                                  value: courseCode,
                                  child: Text(courseCode),
                                );
                              }).toList(),
                            ),
                          )),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                          width: 600,
                          height: 300,
                          child: BarChart(BarChartData(
                              borderData: FlBorderData(
                                  border: const Border(
                                      top: BorderSide.none,
                                      right: BorderSide.none,
                                      left: BorderSide(width: 1),
                                      bottom: BorderSide(width: 1))),
                              titlesData: FlTitlesData(
                                  topTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                    showTitles: false,
                                  )),
                                  rightTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                    showTitles: false,
                                  )),
                                  bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 1:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('Jan'));
                                        case 2:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('Feb'));
                                        case 3:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('Mar'));

                                        case 4:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('Apr'));

                                        case 5:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('May'));

                                        case 6:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('Jun'));

                                        case 7:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('Jul'));

                                        case 8:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('Aug'));

                                        case 9:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('Sep'));

                                        case 10:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('Oct'));

                                        case 11:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('Nov'));

                                        case 12:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text('Dec'));
                                        default:
                                          return SideTitleWidget(
                                              axisSide: AxisSide.left,
                                              child: Text(''));
                                      }
                                    },
                                  ))),
                              groupsSpace: 10,
                              barGroups: trendData)))
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                height: 500, // Adjust the height as needed
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                constraints: BoxConstraints(
                  maxWidth: 650,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(width: 20),
                          Text(
                            'Courses: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: DropdownButton<String>(
                                value: selectedCourseState,
                                style: TextStyle(fontSize: 20),
                                onChanged: (String? status) {
                                  setState(() {
                                    selectedCourseState = status!;
                                  });
                                },
                                items: <DropdownMenuItem<String>>[
                                  DropdownMenuItem<String>(
                                    value: 'Active',
                                    child: Text('Active Courses'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Inactive',
                                    child: Text('Inactive Courses'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: selectedCourseState == 'Active'
                              ? activecourses.length
                              : inactivecourses.length,
                          itemBuilder: (context, index) {
                            final course = selectedCourseState == 'Inactive'
                                ? inactivecourses[index]
                                : activecourses[index];

                            return GestureDetector(
                              onTap: () {
                                // Handle the course click here, e.g., navigate to a course details page
                                // You can access the 'course' object to get details about the clicked course
                                _editCourseData(context, course);
                              },
                              child: ListTile(
                                title: Text(course.coursecode),
                                subtitle: Text(course.coursename),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
            // Other widgets can be added here
          ],
        ),
      ),

      //COURSES SCREEN
      MaterialApp(
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Program Management'),
                bottom: TabBar(
                  tabs: [
                    Tab(
                      text: 'Courses',
                    ),
                    Tab(text: 'Faculty'),
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
                                      enrolledStudentEmails.clear();
                                      enrolledStudentNames.clear();
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
                                          foundFaculty[index].fullName,
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
                    emailTextController.text,
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
                      setState(() {
                        enrolledStudentNames.clear();
                        enrolledStudentEmails.clear();
                      });

                      print(enrolledStudentEmails);
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
