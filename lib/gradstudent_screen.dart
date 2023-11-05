import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:side_navigation/side_navigation.dart';
import 'package:sysadmindb/app/models/coursedemand.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/schoolYear.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
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
  void _deleteEnrolledCourse(
    EnrolledCourseData enrolledCourse,
  ) async {
    int indextodelete = currentStudent.enrolledCourses.indexOf(enrolledCourse);
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
    String coursetoDeleteuid = '';
    for (var course in courses) {
      if (course.coursecode == enrolledCourse.coursecode) {
        coursetoDeleteuid = course.uid;
      }
    }

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
        for (Student student in studentList) {
          if (student.enrolledCourses.any((course) =>
              course.coursecode == activecourses[indextodelete].coursecode)) {
            print("Student with the same course: ${student.displayname}");

            await FirebaseFirestore.instance
                .collection('users')
                .doc(student.uid)
                .get()
                .then((userDoc) {
              if (userDoc.exists) {
                List<dynamic> enrolledCoursesData =
                    userDoc['enrolledCourses'] as List<dynamic>;

                // Update the numstudents field for the course to decrement by 1
                enrolledCoursesData.forEach((enrolledCourseData) {
                  if (enrolledCourseData is Map<String, dynamic> &&
                      enrolledCourseData['coursecode'] ==
                          activecourses[indextodelete].coursecode) {
                    if (enrolledCourseData['numstudents'] is int) {
                      enrolledCourseData['numstudents'] =
                          (enrolledCourseData['numstudents'] as int) - 1;
                    }
                  }
                });

                // Update the user's enrolledCourses field
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(student.uid)
                    .update({'enrolledCourses': enrolledCoursesData});
              }
            });
          }
        }

        await FirebaseFirestore.instance
            .collection('courses')
            .doc(coursetoDeleteuid)
            .update({'numstudents': FieldValue.increment(-1)});

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
    Course? selectedCourse = blankCourse;
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
                      items: [blankCourse, ...activecourses].map((course) {
                        return DropdownMenuItem<Course>(
                          value: course,
                          child: Text(course.coursecode),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCourse = value;
                          // Handle the selection of the blank option here
                          if (value == blankCourse) {
                            // Close the popup and show a message

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('No course chosen.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            // Handle the selection of a valid course
                            selectedCourseIndex =
                                activecourses.indexOf(selectedCourse!);
                            courseAlreadyExists = false;
                          }
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

                      if (selectedCourse != blankCourse) {
                        if (currentStudent.enrolledCourses.any((course) =>
                            course.coursecode == selectedCourse?.coursecode)) {
                          // Check if the course is already in enrolledCourses
                          setState(() {
                            courseAlreadyExists = true;
                          });
                        } else {
                          late EnrolledCourseData enrolledCourse;

                          enrolledCourse = EnrolledCourseData(
                            uid: generateUID(),
                            coursecode: selectedCourse!.coursecode,
                            coursename: selectedCourse!.coursename,
                            isactive: selectedCourse!.isactive,
                            facultyassigned: selectedCourse!.facultyassigned,
                            numstudents: selectedCourse!.numstudents + 1,
                            units: selectedCourse!.units,
                            type: selectedCourse!.type,
                          );
                          onAddEnrolledCourse(enrolledCourse);

                          try {
                            // Get the current user ID (replace with your method to get the user ID)
                            String userId = currentUser.uid;

                            // Update numstudents in the Courses collection
                            print(
                                " NUM STUDENTS 1 ${activecourses[selectedCourseIndex!].numstudents}");
                            await FirebaseFirestore.instance
                                .collection('courses')
                                .doc(activecourses[selectedCourseIndex!].uid)
                                .update(
                                    {'numstudents': FieldValue.increment(1)});

                            // Update user data in Firestore
                            print(studentList.toList());
                            for (Student student in studentList) {
                              print("Checking student: ${student.idnumber}");
                              if (student.enrolledCourses.any((course) =>
                                  course.coursecode ==
                                  activecourses[selectedCourseIndex!]
                                      .coursecode)) {
                                print(
                                    "Student with the same course: ${student.displayname}");

                                // Get the student's document reference
                                final DocumentReference studentDocRef =
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(student.uid);

                                // Retrieve the student's data
                                final DocumentSnapshot studentDoc =
                                    await studentDocRef.get();

                                if (studentDoc.exists) {
                                  final Map<String, dynamic>? studentData =
                                      studentDoc.data()
                                          as Map<String, dynamic>?;

                                  if (studentData != null) {
                                    final List<dynamic>? enrolledCoursesData =
                                        studentData['enrolledCourses']
                                            as List<dynamic>?;

                                    if (enrolledCoursesData != null) {
                                      // Update the numstudents field within enrolledCourses
                                      enrolledCoursesData
                                          .forEach((enrolledCourseData) {
                                        if (enrolledCourseData
                                                is Map<String, dynamic> &&
                                            enrolledCourseData['coursecode'] ==
                                                activecourses[
                                                        selectedCourseIndex!]
                                                    .coursecode) {
                                          if (enrolledCourseData['numstudents']
                                              is int) {
                                            enrolledCourseData['numstudents'] =
                                                (enrolledCourseData[
                                                        'numstudents'] as int) +
                                                    1;
                                          }
                                        }
                                      });

                                      // Update the enrolledCourses field in the Firestore document
                                      await studentDocRef.update({
                                        'enrolledCourses': enrolledCoursesData
                                      });
                                    }
                                  }
                                }
                              }
                            }

                            getCoursesFromFirestore();

                            // Update user data in Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .update({
                              'enrolledCourses': FieldValue.arrayUnion(
                                  [enrolledCourse.toJson()]),
                            });
                            Navigator.pop(context);
                            // Display a success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Enrolled in course successfully'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } catch (e) {
                            print('Error enrolling in course: $e');
                            // Handle the error and display a relevant message
                          }
                        }
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No course selected'),
                            duration: Duration(seconds: 2),
                          ),
                        );
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

  // Declare a variable to hold the selected course

  void showCourseDemandForm(
    BuildContext context,
    int studentIdNumber,
    List<Course> inactiveCourses,
    List<CourseDemand> courseDemands,
  ) {
    Course? selectedCourse;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Demand a Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select a course to demand:'),
              SizedBox(height: 10),
              DropdownButtonFormField<Course>(
                value: selectedCourse,
                items: [...inactiveCourses].map((course) {
                  return DropdownMenuItem<Course>(
                    value: course,
                    child: Text(course.coursecode),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCourse = value;
                  });
                },
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedCourse != null && selectedCourse != blankCourse) {
                  if (courseDemands.any((demand) =>
                      demand.coursecode == selectedCourse?.coursecode &&
                      demand.studentidnumber == studentIdNumber)) {
                    // Course demand already exists
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('You have already demanded this course.'),
                      duration: Duration(seconds: 2),
                    ));
                  } else {
                    // Submit the course demand to Firestore
                    submitDemandToFirestore(selectedCourse, studentIdNumber);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Course demand submitted successfully'),
                      duration: Duration(seconds: 2),
                    ));
                  }
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void submitDemandToFirestore(
      Course? selectedCourse, int studentIdNumber) async {
    // Get the current date and time
    DateTime currentDate = DateTime.now();
    // Format the current date as a string (MM/dd/yyyy)
    String formattedDate =
        "${currentDate.month}/${currentDate.day}/${currentDate.year}/${currentDate.millisecond}";

    // Create a Firestore document for the course demand with the current date
    await FirebaseFirestore.instance.collection('offerings').add({
      'coursecode': selectedCourse!.coursecode,
      'studentIdNumber': studentIdNumber,
      'date': formattedDate, // Store the current date as a Firestore Timestamp
      // Add other fields as needed
    });

    // You can also display a success message or perform other actions here
    getCourseDemandsFromFirestore();
    updateCourseData();
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
                          grade: enteredGrade!,
                          type:
                              selectedCourse!.type, // Assign the entered grade
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
      setState(() {
        getCoursesFromFirestore();
      });
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
                onTap: () async {
                  await getCoursesFromFirestore();
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
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text.rich(
                  TextSpan(
                    text:
                        "Wish to demand for a course that isn't offered? Click ",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                    children: [
                      TextSpan(
                        text: "here",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue, // You can customize the color
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Handle the click action, e.g., navigate to a new screen or show a dialog
                            // You can replace this with your desired behavior
                            showCourseDemandForm(
                                context,
                                currentStudent.idnumber,
                                inactivecourses,
                                courseDemands);
                          },
                      ),
                    ],
                  ),
                ),
              ),
            )
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

  void changeScreen(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void addSelectedCourseToTermAndCloseDialog(
    Course? selectedCourse,
    Term term,
    List<SchoolYear> schoolyears,
    BuildContext context,
  ) {
    if (selectedCourse != null) {
      // Check if the course exists in other terms within the same school year
      bool courseExistsInSameSchoolYear =
          term.termcourses.contains(selectedCourse);

      // Check if the course exists in other school years
      bool courseExistsInOtherSchoolYears = schoolyears.any((otherSchoolYear) =>
          otherSchoolYear != schoolyears &&
          otherSchoolYear.terms.any((otherTerm) =>
              otherTerm != term &&
              otherTerm.termcourses.contains(selectedCourse)));

      if (!courseExistsInSameSchoolYear && !courseExistsInOtherSchoolYears) {
        setState(() {
          term.termcourses.add(selectedCourse);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course added'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Course already exists in another term or school year. Courses cannot be taken more than once.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      Navigator.pop(context);
    }
  }

  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // print(currentStudent.pastCourses[1]);
    List<Widget> views = [
      Center(
        child: Text(
          'Dashboard',
          textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: 'Inter'),
        ),
      ),
      Center(
          child: Column(
        children: [
          Text(
            'Program of Study',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SingleChildScrollView(
            child: Table(
              border: TableBorder.all(),
              children: schoolyears.map((schoolYear) {
                return TableRow(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 221, 221, 221),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // School Year Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 104, 177, 106),
                                      border: Border.all(),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.zero,
                                        bottomRight: Radius.zero,
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            schoolYear.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                // School Year's Terms and Courses
                                Row(
                                  children: schoolYear.terms.map((term) {
                                    return Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(),
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                            topLeft: Radius.zero,
                                            topRight: Radius.zero,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                term.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: term.termcourses
                                                  .map((termcourse) {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Text(
                                                              "${termcourse.coursecode}: ${termcourse.coursename}"),
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () {
                                                        // Display a confirmation dialog before deleting
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  "Delete Course"),
                                                              content: Text(
                                                                  "Are you sure you want to delete the course: ${termcourse.coursecode}?"),
                                                              actions: [
                                                                TextButton(
                                                                  child: Text(
                                                                      "Cancel"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child: Text(
                                                                      "Delete"),
                                                                  onPressed:
                                                                      () {
                                                                    // Identify the course you want to delete
                                                                    Course
                                                                        courseToDelete =
                                                                        termcourse;

                                                                    // Find the index of the course in the term's course list
                                                                    int courseIndex = term
                                                                        .termcourses
                                                                        .indexOf(
                                                                            courseToDelete);

                                                                    if (courseIndex !=
                                                                        -1) {
                                                                      // Remove the course from the term's course list
                                                                      setState(
                                                                          () {
                                                                        term.termcourses
                                                                            .removeAt(courseIndex);
                                                                      });

                                                                      // Print a message or perform any additional actions
                                                                      print(
                                                                          "Deleted course: ${courseToDelete.coursecode}");
                                                                    } else {
                                                                      // Handle the case where the course was not found
                                                                      print(
                                                                          "Course not found: ${courseToDelete.coursecode}");
                                                                    }
                                                                    // Close the confirmation dialog
                                                                    print(
                                                                        "Delete ${schoolYear.name} ${term.name} ${termcourse.coursecode} ${termcourse.coursename}");
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    )
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // Handle the click event
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    Course?
                                                        selectedCourse; // Initialize as nullable

                                                    return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                        return SimpleDialog(
                                                          title: Text(
                                                              'Select a Course to add for ${term.name} AY ${schoolYear.name}'),
                                                          children: <Widget>[
                                                            DropdownButton<
                                                                Course>(
                                                              items: courses
                                                                  .map(
                                                                      (course) {
                                                                return DropdownMenuItem<
                                                                    Course>(
                                                                  value: course,
                                                                  child: Text(
                                                                      "${course.coursecode}: ${course.coursename}"), // Replace with the course name attribute
                                                                );
                                                              }).toList(),
                                                              onChanged:
                                                                  (Course?
                                                                      course) {
                                                                setState(() {
                                                                  selectedCourse =
                                                                      course;
                                                                });
                                                              },
                                                              value:
                                                                  selectedCourse,
                                                            ),
                                                            if (selectedCourse !=
                                                                null)
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    'Course Details:',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    'Course Code: ${selectedCourse!.coursecode}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    'Course Name: ${selectedCourse!.coursename}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    'Course Type: ${selectedCourse!.type}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  // Add more course details here
                                                                ],
                                                              ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                addSelectedCourseToTermAndCloseDialog(
                                                                    selectedCourse,
                                                                    term,
                                                                    schoolyears,
                                                                    context);
                                                              },
                                                              child: Text('OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text(
                                                'add course for ${term.name} A.Y. ${schoolYear.name}',
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: Colors
                                                      .blue, // You can choose the color you prefer
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      )),
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
                      courses.clear();
                      studentList.clear();
                      activecourses.clear();
                      currentStudent.enrolledCourses.clear();
                      currentStudent.pastCourses.clear();
                      wrongCreds = false;

                      correctCreds = false;
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
                  label: 'Program of Study',
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
              child: views.length > selectedIndex
                  ? views.elementAt(selectedIndex)
                  : Center(
                      child: Text('Invalid view index: $selectedIndex'),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
