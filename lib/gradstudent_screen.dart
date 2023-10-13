import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:side_navigation/side_navigation.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/ui/form.dart';

void main() {
  runApp(
    MaterialApp(home: GradStudentscreen()),
  );
}

class GradStudentscreen extends StatefulWidget {
  const GradStudentscreen({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class StudentProfileScreen extends StatefulWidget {
  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool isEditing = false;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Set initial values
      firstNameController.text = currentUser.displayname['firstname']!;
      lastNameController.text = currentUser.displayname['lastname']!;
      idNumberController.text = currentUser.idnumber.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User not logged in
      return Center(
        child: Text('User not logged in'),
      );
    }

    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'User Profile:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            SizedBox(height: 16),
            // Editable fields
            Container(
              height: 16,
            ),
            TextField(
              controller: firstNameController,
              enabled: isEditing,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              enabled: isEditing,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: idNumberController,
              enabled: isEditing,
              decoration: InputDecoration(labelText: 'ID Number'),
            ),
            // Non-editable fields
            Container(
              height: 16,
            ),
            Text(
              'Email: ${user.email}',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                  if (!isEditing) {
                    // Save changes when editing is done
                    updateUserProfile();
                  }
                });
              },
              child: Text(isEditing ? 'Save' : 'Edit'),
            ),
            SizedBox(height: 16),
          ],
        ));
  }

  void updateUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'displayname': {
          'firstname': firstNameController.text,
          'lastname': lastNameController.text,
        },
        'idnumber': int.parse(idNumberController.text),
        // Add other fields as needed
      });

      // Show a SnackBar or any other feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User data updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating user data: $e');
      // Handle the error or show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user data: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class CurriculumAuditScreen extends StatefulWidget {
  @override
  State<CurriculumAuditScreen> createState() => _CurriculumAuditScreenState();
}

class _CurriculumAuditScreenState extends State<CurriculumAuditScreen> {
  void _deleteEnrolledCourse(EnrolledCourseData enrolledCourse) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this course?'),
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
        // Remove the course from the enrolledCourses list
        setState(() {
          currentStudent.enrolledCourses.remove(enrolledCourse);
        });

        // Update Firestore to reflect the changes
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentStudent.uid)
            .update({
          'enrolledCourses': currentStudent.enrolledCourses
              .map((course) => course.toJson())
              .toList(),
        });

        // Display a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Error deleting enrolled course: $e');
        // Handle the error and display a relevant message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting course. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void showAddEnrolledCoursePopup(
    BuildContext context,
    GlobalKey<FormState> formKey,
    List<Course> course,
    Function(EnrolledCourseData) onAddEnrolledCourse,
  ) {
    Course? selectedCourse = activecourses.isNotEmpty ? activecourses[0] : null;
    int? selectedCourseIndex;
    bool courseAlreadyExists = false;
    print(currentStudent.enrolledCourses);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Enrolled Course'),
              content: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    DropdownButtonFormField<Course>(
                      value: selectedCourse,
                      items: activecourses.map((course) {
                        return DropdownMenuItem<Course>(
                          value: course,
                          child: Text(course.coursecode),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCourse = value;
                          selectedCourseIndex =
                              activecourses.indexOf(selectedCourse!);
                          courseAlreadyExists = false;
                        });
                      },
                      onSaved: (value) {},
                      decoration: InputDecoration(labelText: 'Select Course'),
                    ),
                    if (courseAlreadyExists)
                      Text(
                        'This course is already added',
                        style: TextStyle(color: Colors.red),
                      ),
                    if (selectedCourse != null)
                      Column(
                        children: [
                          Text('Course Name: ${selectedCourse?.coursename}'),
                          Text(
                              'Faculty Assigned: ${selectedCourse?.facultyassigned}'),
                          Text('Units: ${selectedCourse?.units}'),
                          Text(
                              'Number of Students: ${selectedCourse?.numstudents}'),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Validate and save form data
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      if (currentStudent.enrolledCourses.any((course) =>
                          course.coursecode == selectedCourse?.coursecode)) {
                        // Check if the course is already in enrolledCourses
                        setState(() {
                          courseAlreadyExists = true;
                        });
                      } else {
                        final enrolledCourse = EnrolledCourseData(
                          uid: generateUID(),
                          coursecode: selectedCourse!.coursecode,
                          coursename: selectedCourse!.coursename,
                          isactive: selectedCourse!.isactive,
                          facultyassigned: selectedCourse!.facultyassigned,
                          numstudents: selectedCourse!.numstudents,
                          units: selectedCourse!.units,
                        );

                        onAddEnrolledCourse(enrolledCourse);

                        // Close the popup
                        Navigator.pop(context);

                        try {
                          // Get the current user ID (replace with your method to get the user ID)
                          String userId = currentUser.uid;

                          // Update user data in Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .update({
                            'enrolledCourses': FieldValue.arrayUnion(
                                [enrolledCourse.toJson()]),
                          });

                          // Update numstudents in the Courses collection
                          if (selectedCourseIndex != null) {
                            await FirebaseFirestore.instance
                                .collection('courses')
                                .doc(activecourses[selectedCourseIndex!].uid)
                                .update(
                                    {'numstudents': FieldValue.increment(1)});
                          }

                          // Display a success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Enrolled in course successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          print('Error enrolling in course: $e');
                          // Handle the error and display a relevant message
                        }
                      }
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAddPastCourse(
    BuildContext context,
    GlobalKey<FormState> formKey,
    Function(PastCourse) onAddPastCourse,
  ) {
    Course? selectedCourse = courses.isNotEmpty ? courses[0] : null;
    int? selectedCourseIndex;
    bool courseAlreadyExists = false;
    double? enteredGrade; // Variable to store the entered grade

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Past Course'),
              content: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    DropdownButtonFormField<Course>(
                      value: selectedCourse,
                      items: courses.map((course) {
                        return DropdownMenuItem<Course>(
                          value: course,
                          child: Text(course.coursecode),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCourse = value;
                          selectedCourseIndex =
                              courses.indexOf(selectedCourse!);
                          courseAlreadyExists = false;
                        });
                      },
                      onSaved: (value) {},
                      decoration: InputDecoration(labelText: 'Select Course'),
                    ),
                    if (courseAlreadyExists)
                      Text(
                        'This course is already added',
                        style: TextStyle(color: Colors.red),
                      ),
                    if (selectedCourse != null)
                      Column(
                        children: [
                          Text('Course Name: ${selectedCourse?.coursename}'),
                          Text(
                              'Faculty Assigned: ${selectedCourse?.facultyassigned}'),
                          Text('Units: ${selectedCourse?.units}'),
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Enter Grade'),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the grade';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // Parse the entered value to double
                              enteredGrade = double.tryParse(value ?? '');
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Validate and save form data
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      if (currentStudent.pastCourses.any((course) =>
                          course.coursecode == selectedCourse?.coursecode)) {
                        // Check if the course is already in pastCourses
                        setState(() {
                          courseAlreadyExists = true;
                        });
                      } else {
                        final pastCourse = PastCourse(
                          uid: generateUID(),
                          coursecode: selectedCourse!.coursecode,
                          coursename: selectedCourse!.coursename,
                          facultyassigned: selectedCourse!.facultyassigned,
                          units: selectedCourse!.units,
                          numstudents: selectedCourse!.numstudents,
                          isactive: selectedCourse!.isactive,
                          grade: enteredGrade!, // Assign the entered grade
                        );

                        onAddPastCourse(pastCourse);

                        // Close the popup
                        Navigator.pop(context);

                        try {
                          // Get the current user ID (replace with your method to get the user ID)
                          String userId = currentUser.uid;

                          // Update user data in Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .update({
                            'pastCourses':
                                FieldValue.arrayUnion([pastCourse.toJson()]),
                          });

                          // Display a success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Past course added successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          print('Error adding past course: $e');
                          // Handle the error and display a relevant message
                        }
                      }
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deletePastCourse(PastCourse pastCourse) async {
    // Show a confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this past course?'),
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

    // If the user confirms the deletion, proceed
    if (confirmDelete == true) {
      setState(() {
        currentStudent.pastCourses.remove(pastCourse);
      });

      try {
        // Get the current user ID (replace with your method to get the user ID)
        String userId = currentUser.uid;

        // Update user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'pastCourses': FieldValue.arrayRemove([pastCourse.toJson()]),
        });

        // Display a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Past course deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Error deleting past course: $e');
        // Handle the error and display a relevant message
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Enrolled Courses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            DataTable(
              columns: [
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
                  'Units',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                DataColumn(
                    label: Text(
                  'Enrolled',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                DataColumn(
                    label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
              ],
              rows: currentStudent.enrolledCourses
                  .map(
                    (enrolledCourse) => DataRow(
                      cells: [
                        DataCell(Text(enrolledCourse.coursecode)),
                        DataCell(Text(enrolledCourse.coursename)),
                        DataCell(Text(enrolledCourse.units.toString())),
                        DataCell(Text(enrolledCourse.numstudents.toString())),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                // Handle delete action
                                _deleteEnrolledCourse(enrolledCourse);
                              },
                            ),
                          ],
                        )),
                      ],
                    ),
                  )
                  .toList(),
            ),
            SizedBox(
              height: 8,
            ),
            Center(
              child: InkWell(
                onTap: () {
                  showAddEnrolledCoursePopup(context, _formKey, activecourses,
                      (enrolledCourse) {
                    setState(() {
                      currentStudent.enrolledCourses.add(enrolledCourse);
                    });
                    // Handle the added enrolled course
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Add enrolled course',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.grey)),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
                child: Column(
              children: [
                Text(
                  'Past Courses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                DataTable(
                  columns: [
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
                      'Units',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataColumn(
                        label: Text(
                      'Grade',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataColumn(
                        label: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                  rows: currentStudent.pastCourses
                      .map(
                        (pastCourse) => DataRow(
                          cells: [
                            DataCell(Text(pastCourse.coursecode)),
                            DataCell(Text(pastCourse.coursename)),
                            DataCell(Text(pastCourse.grade.toString())),
                            DataCell(Text(pastCourse.units.toString())),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    // Handle delete action
                                    _deletePastCourse(pastCourse);
                                  },
                                ),
                              ],
                            )),
                          ],
                        ),
                      )
                      .toList(),
                ),
                SizedBox(
                  height: 8,
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      showAddPastCourse(
                          context,
                          _formKey,
                          (pastCourse) => setState(() {
                                currentStudent.pastCourses.add(pastCourse);
                              }));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Add past course',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.grey)),
                    ),
                  ),
                )
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class CapstoneProjectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Capstone Project Screen'),
    );
  }
}

class _MainViewState extends State<GradStudentscreen>
    with SingleTickerProviderStateMixin {
  /// Views to display
  late TabController _tabController;
  int selectedIndex = 0;
  void changeScreen(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    print(currentStudent.pastCourses[1]);
    List<Widget> views = [
      Center(
        child: Text(
          'Dashboard',
          textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: 'Inter'),
        ),
      ),
      Center(
        child: Text(
          'Courses',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontFamily: 'Inter',
          ),
        ),
      ),
      Center(
        child: Text(
          'Calendar',
          textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: 'Inter', fontSize: 100),
        ),
      ),
      Center(
        child: Text(
          'Inbox',
          textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: 'Inter', fontSize: 100),
        ),
      ),
      Scaffold(
        appBar: AppBar(
          title: Text('Student Hub'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: 'Student Profile',
              ),
              Tab(
                text: 'Curriculum Audit',
              ),
              Tab(
                text: 'Capstone Project',
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
          controller: _tabController,
          children: [
            StudentProfileScreen(),
            CurriculumAuditScreen(),
            CapstoneProjectScreen(),
          ],
        ),
      ),
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
                    "${currentUser.displayname['firstname']} ${currentUser.displayname['lastname']!}",
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
                  label: 'Courses',
                ),
                SideNavigationBarItem(
                  icon: Icons.event,
                  label: 'Calendar',
                ),
                SideNavigationBarItem(
                  icon: Icons.message,
                  label: 'Inbox',
                ),
                SideNavigationBarItem(
                  icon: Icons.school,
                  label: 'Student Hub',
                ),
              ],
              onTap: (index) {
                setState(() {
                  changeScreen(index);
                });
              },
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
