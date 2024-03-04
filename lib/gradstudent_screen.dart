import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:side_navigation/side_navigation.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/ui/CircularProgressWidget.dart';
import 'package:sysadmindb/app/models/coursedemand.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/ui/form.dart';
import 'package:sysadmindb/ui/calendar.dart';
import 'package:sysadmindb/ui/EventDetailsScreen.dart';
import 'package:table_calendar/table_calendar.dart';

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

int unitsCompleted =
    currentStudent!.pastCourses.fold(0, (int sum, PastCourse pastCourse) {
  return sum + pastCourse.units;
});

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool isEditing = false;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  bool isValidPass = false;

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

  String _capitalize(String input) {
    if (input.isEmpty) {
      return '';
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    bool is12chars = is12charslong(newPasswordController.text);
    bool isAtMost64chars = isatmost64chars(newPasswordController.text);
    bool hasSpecial = hasSpecialChar(newPasswordController.text);
    bool hasNum = hasNumber(newPasswordController.text);
    bool isMatching =
        confirmNewPasswordController.text == newPasswordController.text;
    bool curpassinc = false;

    if (user == null) {
      // User not logged in
      return Center(
        child: Text('User not logged in'),
      );
    }

    if (is12charslong(curpass) &&
        isatmost64chars(curpass) &&
        hasSpecialChar(curpass) &&
        hasNumber(curpass) &&
        hasSpecialChar(curpass)) {
      setState(() {
        isValidPass = true;
      });
    } else {
      setState(() {
        isValidPass = false;
      });
    }

    return SingleChildScrollView(
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
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "${_capitalize(firstNameController.text)} ${_capitalize(lastNameController.text)} ",
                                style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 23, 71, 25)),
                              ),
                              Text(currentStudent!.degree.endsWith('SIT')
                                  ? 'Master of Science in Information Technology - ${currentStudent!.idnumber.toString()}'
                                  : 'Master in Information Technology - ${currentStudent!.idnumber.toString()}'),
                              Text(currentStudent!.email),
                              Text('Enrollment Status: ${currentUser.status}'),
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
                                    color:
                                        isEditing ? Colors.black : Colors.grey,
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
                                isEditing ? 'Save Password' : 'Change Password',
                                style: TextStyle(
                                    color: isEditing
                                        ? const Color.fromARGB(255, 23, 71, 25)
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
        ));
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

class CurriculumAuditScreen extends StatefulWidget {
  @override
  State<CurriculumAuditScreen> createState() => _CurriculumAuditScreenState();
}

class _CurriculumAuditScreenState extends State<CurriculumAuditScreen> {
  void _deleteEnrolledCourse(
    EnrolledCourseData enrolledCourse,
  ) async {
    int indextodelete = currentStudent!.enrolledCourses.indexOf(enrolledCourse);
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
          currentStudent!.enrolledCourses.remove(enrolledCourse);
        });

        // Update Firestore to reflect the changes
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentStudent!.uid)
            .update({
          'enrolledCourses': currentStudent!.enrolledCourses
              .map((course) => course.toJson())
              .toList(),
        });

        await FirebaseFirestore.instance
            .collection('studentpos')
            .doc(currentStudent!.uid)
            .update({
          'enrolledCourses': currentStudent!.enrolledCourses
              .map((course) => course.toJson())
              .toList(),
        });
        for (Student student in studentList) {
          if (student.enrolledCourses.any((course) =>
              course.coursecode == activecourses[indextodelete].coursecode)) {
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

// ADD COURSES IN CURRICULUM AUDIT
  void showAddEnrolledCoursePopup(
    BuildContext context,
    GlobalKey<FormState> formKey,
    List<Course> course,
    Function(EnrolledCourseData) onAddEnrolledCourse,
  ) {
    Course? selectedCourse = blankCourse;
    int? selectedCourseIndex;
    bool courseAlreadyExists = false;
    String selectedRadio = '';

    // Get the current date

    // Determine the current term
    String currentTerm = getCurrentSYandTerm();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Add currently enrolled course for $currentTerm'),
              content: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio = 'Bridging/Remedial';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor:
                                      selectedRadio == 'Bridging/Remedial'
                                          ? const Color.fromARGB(255, 23, 71,
                                              25) // Text color when selected
                                          : null,
                                  backgroundColor: selectedRadio ==
                                          'Bridging/Remedial'
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio == 'Bridging/Remedial'
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  'Bridging/Remedial',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio = 'Foundation';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor: selectedRadio == 'Foundation'
                                      ? const Color.fromARGB(255, 23, 71,
                                          25) // Text color when selected
                                      : null,
                                  backgroundColor: selectedRadio == 'Foundation'
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio == 'Foundation'
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  'Foundation',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio = 'Elective';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor: selectedRadio == 'Elective'
                                      ? const Color.fromARGB(255, 23, 71,
                                          25) // Text color when selected
                                      : null,
                                  backgroundColor: selectedRadio == 'Elective'
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio == 'Elective'
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  'Elective',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio = 'Specialized';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor:
                                      selectedRadio == 'Specialized'
                                          ? Color.fromARGB(255, 0, 0,
                                              0) // Text color when selected
                                          : null,
                                  backgroundColor: selectedRadio ==
                                          'Specialized'
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio == 'Specialized'
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  'Specialized',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio = 'Exam';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor: selectedRadio == 'Exam'
                                      ? const Color.fromARGB(255, 23, 71,
                                          25) // Text color when selected
                                      : null,
                                  backgroundColor: selectedRadio == 'Exam'
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio == 'Exam'
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  'Exam',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio =
                                        currentStudent!.degree == 'MIT'
                                            ? 'Capstone'
                                            : 'Thesis';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor: selectedRadio ==
                                          (currentStudent!.degree == 'MIT'
                                              ? 'Capstone'
                                              : 'Thesis')
                                      ? Color.fromARGB(255, 0, 0,
                                          0) // Text color when selected
                                      : null,
                                  backgroundColor: selectedRadio ==
                                          (currentStudent!.degree == 'MIT'
                                              ? 'Capstone'
                                              : 'Thesis')
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio ==
                                            (currentStudent!.degree == 'MIT'
                                                ? 'Capstone'
                                                : 'Thesis')
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  currentStudent!.degree == 'MIT'
                                      ? 'Capstone'
                                      : 'Thesis',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 200,
                          width: MediaQuery.of(context).size.width / 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(34, 54, 233,
                                  60), // Set your desired background color
                              borderRadius: BorderRadius.circular(
                                  10), // Set your desired border radius
                            ),
                            child: ListView.builder(
                              itemCount: activecourses
                                  .where((course) =>
                                      course.program
                                          .contains(currentStudent!.degree) &&
                                      course.type.toLowerCase().contains(
                                          selectedRadio.toLowerCase()))
                                  .length,
                              itemBuilder: (BuildContext context, int index) {
                                final course = activecourses
                                    .where((course) =>
                                        course.program
                                            .contains(currentStudent!.degree) &&
                                        course.type.toLowerCase().contains(
                                            selectedRadio.toLowerCase()))
                                    .toList()[index];

                                return ListTile(
                                  title: Text(
                                      "${course.coursecode}: ${course.coursename}"),
                                  onTap: () {
                                    setState(() {
                                      selectedCourse = course;
                                      selectedCourseIndex = activecourses
                                          .indexOf(selectedCourse!);
                                      courseAlreadyExists = false;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        if (courseAlreadyExists)
                          Text(
                            'This course is already added',
                            style: TextStyle(color: Colors.red),
                          ),
                        if (selectedCourse != null)
                          Text(
                            "Course name",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        Text(
                          selectedCourse!.coursename,
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Faculty name",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          selectedCourse?.facultyassigned ==
                                  'UNASSIGNED UNASSIGNED'
                              ? 'No faculty assigned'
                              : '${selectedCourse?.facultyassigned}',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Units",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          selectedCourse!.units.toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Number of students",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          selectedCourse!.numstudents.toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )),
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
                        if (currentStudent!.enrolledCourses.any((course) =>
                                course.coursecode ==
                                selectedCourse?.coursecode) ||
                            currentStudent!.pastCourses.any((course) =>
                                course.coursecode ==
                                selectedCourse?.coursecode)) {
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
                              program: selectedCourse!.program);
                          onAddEnrolledCourse(enrolledCourse);

                          try {
                            // Get the current user ID (replace with your method to get the user ID)
                            String userId = currentUser.uid;

                            // Update numstudents in the Courses collection

                            await FirebaseFirestore.instance
                                .collection('courses')
                                .doc(activecourses[selectedCourseIndex!].uid)
                                .update(
                                    {'numstudents': FieldValue.increment(1)});

                            // Update user data in Firestore
                            for (Student student in studentList) {
                              print("Checking student: ${student.idnumber}");
                              if (student.enrolledCourses.any((course) =>
                                  course.coursecode ==
                                  activecourses[selectedCourseIndex!]
                                      .coursecode)) {
                                // Get the student's document reference
                                final DocumentReference studentDocRef =
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(student.uid);

                                final DocumentReference studentPOSRef =
                                    FirebaseFirestore.instance
                                        .collection('studentpos')
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

                            await FirebaseFirestore.instance
                                .collection('studentpos')
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

// ADD PAST COURSE IN CURRICULUM AUDIT
  void showAddPastCourse(
    BuildContext context,
    GlobalKey<FormState> formKey,
    Function(PastCourse) onAddPastCourse,
  ) {
    Course? selectedCourse = courses.isNotEmpty ? courses[0] : null;
    int? selectedCourseIndex;
    bool courseAlreadyExists = false;
    double? enteredGrade; // Variable to store the entered grade
    String selectedRadio = '';

    void handleRadioValueChanged(String coursetype) {
      setState(() {
        selectedRadio = coursetype;
      });
    }

    Widget radioSelectionButton(String value) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          onPressed: () {
            setState(() {
              selectedRadio = value;
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: selectedRadio == value
                ? const Color.fromARGB(
                    255, 23, 71, 25) // Text color when selected
                : null,
            backgroundColor: null, // Fully transparent background
            side: BorderSide(
              color: selectedRadio == value
                  ? const Color.fromARGB(
                      255, 23, 71, 25) // Border color when selected
                  : Colors
                      .transparent, // Transparent border color when not selected
            ),
          ),
          child: Text(value),
        ),
      );
    }

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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio = 'Bridging/Remedial';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor:
                                      selectedRadio == 'Bridging/Remedial'
                                          ? const Color.fromARGB(255, 23, 71,
                                              25) // Text color when selected
                                          : null,
                                  backgroundColor: selectedRadio ==
                                          'Bridging/Remedial'
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio == 'Bridging/Remedial'
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  'Bridging/Remedial',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio = 'Foundation';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor: selectedRadio == 'Foundation'
                                      ? const Color.fromARGB(255, 23, 71,
                                          25) // Text color when selected
                                      : null,
                                  backgroundColor: selectedRadio == 'Foundation'
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio == 'Foundation'
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  'Foundation',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio = 'Elective';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor: selectedRadio == 'Elective'
                                      ? const Color.fromARGB(255, 23, 71,
                                          25) // Text color when selected
                                      : null,
                                  backgroundColor: selectedRadio == 'Elective'
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio == 'Elective'
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  'Elective',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio = 'Specialized';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor:
                                      selectedRadio == 'Specialized'
                                          ? Color.fromARGB(255, 0, 0,
                                              0) // Text color when selected
                                          : null,
                                  backgroundColor: selectedRadio ==
                                          'Specialized'
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio == 'Specialized'
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  'Specialized',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio = 'Exam';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor: selectedRadio == 'Exam'
                                      ? const Color.fromARGB(255, 23, 71,
                                          25) // Text color when selected
                                      : null,
                                  backgroundColor: selectedRadio == 'Exam'
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio == 'Exam'
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  'Exam',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRadio =
                                        currentStudent!.degree == 'MIT'
                                            ? 'Capstone'
                                            : 'Thesis';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor: selectedRadio ==
                                          (currentStudent!.degree == 'MIT'
                                              ? 'Capstone'
                                              : 'Thesis')
                                      ? Color.fromARGB(255, 0, 0,
                                          0) // Text color when selected
                                      : null,
                                  backgroundColor: selectedRadio ==
                                          (currentStudent!.degree == 'MIT'
                                              ? 'Capstone'
                                              : 'Thesis')
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio ==
                                            (currentStudent!.degree == 'MIT'
                                                ? 'Capstone'
                                                : 'Thesis')
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  currentStudent!.degree == 'MIT'
                                      ? 'Capstone'
                                      : 'Thesis',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 200,
                          width: MediaQuery.of(context).size.width / 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(34, 54, 233,
                                  60), // Set your desired background color
                              borderRadius: BorderRadius.circular(
                                  10), // Set your desired border radius
                            ),
                            child: ListView.builder(
                              itemCount: courses
                                  .where((course) =>
                                      course.program
                                          .contains(currentStudent!.degree) &&
                                      course.type.toLowerCase().contains(
                                          selectedRadio.toLowerCase()))
                                  .length,
                              itemBuilder: (BuildContext context, int index) {
                                final course = courses
                                    .where((course) =>
                                        course.program
                                            .contains(currentStudent!.degree) &&
                                        course.type.toLowerCase().contains(
                                            selectedRadio.toLowerCase()))
                                    .toList()[index];

                                return ListTile(
                                  title: Text(
                                      "${course.coursecode}: ${course.coursename}"),
                                  onTap: () {
                                    setState(() {
                                      selectedCourse = course;
                                      selectedCourseIndex = activecourses
                                          .indexOf(selectedCourse!);
                                      courseAlreadyExists = false;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        if (courseAlreadyExists)
                          Text(
                            'This course is already added',
                            style: TextStyle(color: Colors.red),
                          ),
                        if (selectedCourse != null)
                          Text(
                            "Course name",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        Text(
                          selectedCourse!.coursename,
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Units",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          selectedCourse!.units.toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Enter Grade",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Grade'),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the grade';
                            }

                            if (int.parse(value) > 4.0 ||
                                int.parse(value) < 0.0) {
                              return 'Invalid grade';
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
                  )),
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
                      if (currentStudent!.enrolledCourses.any((course) =>
                              course.coursecode ==
                              selectedCourse?.coursecode) ||
                          currentStudent!.pastCourses.any((course) =>
                              course.coursecode ==
                              selectedCourse?.coursecode)) {
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
                            type: selectedCourse!.type,
                            program: selectedCourse!
                                .program // Assign the entered grade
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
                          await FirebaseFirestore.instance
                              .collection('studentpos')
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

                          unitsCompleted = pastCourses.fold(0,
                              (int sum, PastCourse pastCourse) {
                            return sum + pastCourse.units;
                          });
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
        currentStudent!.pastCourses.remove(pastCourse);
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

        await FirebaseFirestore.instance
            .collection('studentpos')
            .doc(userId)
            .update({
          'pastCourses': FieldValue.arrayRemove([pastCourse.toJson()]),
        });
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
              rows: currentStudent!.enrolledCourses
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
                      currentStudent!.enrolledCourses.add(enrolledCourse);
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
                      'Grade',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataColumn(
                        label: Text(
                      'Units',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataColumn(
                        label: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                  rows: currentStudent!.pastCourses
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
                                currentStudent!.pastCourses.add(pastCourse);
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
                                currentStudent!.idnumber,
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

DataCell capstoneCell(PastCourse pastCourse) {
  for (var i = 0; i < currentStudent!.pastCourses.length;) {
    if (currentStudent!.pastCourses[i].coursecode.contains('Capstone')) {
      return DataCell(Text(
          "${pastCourse.coursecode}: ${pastCourse.coursename}\n${pastCourse.grade}",
          style: TextStyle(color: Colors.red)));
    }
  }

  return DataCell(Text(''));
}

class CapstoneProjectScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    List<DataColumn> columns = [
      DataColumn(label: Text('Course Code')),
      DataColumn(label: Text('Course Name')),
      DataColumn(label: Text('Status')),
    ];

    List<DataRow> rows = [];

    if (currentStudent!.degree == 'MIT') {
      rows = capstonecourses.map((capstoneCourse) {
        return DataRow(cells: [
          DataCell(Text(capstoneCourse.coursecode)),
          DataCell(Text(capstoneCourse.coursename)),
          DataCell(Text('Passed')),
        ]);
      }).toList();
    } else if (currentStudent!.degree == 'MSIT') {
      rows = thesiscourses.map((thesisCourse) {
        return DataRow(cells: [
          DataCell(Text(thesisCourse.coursecode)),
          DataCell(Text(thesisCourse.coursename)),
          DataCell(Text('Passed')),
        ]);
      }).toList();
    }

    return Column(
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
        SizedBox(height: 8), // Optional: Adjust the space from top if needed
        Center(
          child: DataTable(
            columns: columns,
            rows: rows,
          ),
        ),
      ],
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
        changeinPOS = true;
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

  Color getColorForCourseType(Course course) {
    if (currentStudent!.pastCourses
        .any((pastcourse) => pastcourse.coursecode == course.coursecode)) {
      return Colors.grey;
    } else {
      if (course.type.toLowerCase().contains('bridging')) {
        return Colors.blue;
      } // Choose the color you want for Bridging
      else if (course.type.toLowerCase().contains('foundation')) {
        return Colors.green;
      } // Choose the color you want for Foundation
      else if (course.type.toLowerCase().contains('exam')) {
        return Colors.red;
      } // Choose the color you want for Exam
      else if (course.type.toLowerCase().contains('elective')) {
        return Colors.orange;
      } // Choose the color you want for Elective
      else {
        return Colors.black;
      } // Default color for unknown types
    }
  }

  bool changeinPOS = false;
  SchoolYear? selectedSchoolYear = studentPOS.schoolYears[1];

  @override
  Widget build(BuildContext context) {
    // print(currentStudent.pastCourses[1]);
    List<Widget> views = [
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
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: studentPOS.schoolYears.map((schoolYear) {
                return Row(
                  children: [
                    SizedBox(width: 10), // Add some spacing between buttons
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedSchoolYear =
                              schoolYear; // Update the selected school year
                        });
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                            Size(120, 50)), // Enlarge the button size
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                          return selectedSchoolYear == schoolYear
                              ? Color.fromARGB(50, 13, 105,
                                  16) // Background color when selected
                              : null; // Background color when not selected
                        }),
                        side: MaterialStateProperty.resolveWith<BorderSide>(
                            (Set<MaterialState> states) {
                          return BorderSide(
                            color: selectedSchoolYear == schoolYear
                                ? const Color.fromARGB(255, 23, 71,
                                    25) // Border color when selected
                                : Colors
                                    .transparent, // Transparent border color when not selected
                          );
                        }),
                      ),
                      child: Text(
                        schoolYear.name, // Display the name of the school year
                        style: TextStyle(
                          fontSize: 16, // Enlarge the text size
                          color: selectedSchoolYear == schoolYear
                              ? Color.fromARGB(
                                  255, 0, 0, 0) // Text color when selected
                              : null, // Text color when not selected
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add some spacing between buttons
                  ],
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: selectedSchoolYear!.terms.map((term) {
              return Expanded(
                child: Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          term.name, // Display the name of the term
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        children: term.termcourses.map((course) {
                          if (course.type == 'Elective Courses') {
                            // Increment the elective count for each elective course encountered
                            return ListTile(
                              title: Text(
                                  'Elective Course'), // Display the elective count
                              subtitle: Text('Enroll in any elective course'),
                            );
                          } else {
                            return ListTile(
                              title: Text(
                                  course.coursecode), // Display the course code
                              subtitle: Text(
                                  course.coursename), // Display the course name
                            );
                          }
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      )),

      // CALENDAR PAGE || Following guide: https://www.youtube.com/watch?v=6Gxa-v7Zh7I&ab_channel=AIwithFlutter
      Calendar(),

      Center(
        child: Text(
          'Inbox',
          textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: 'Inter', fontSize: 100),
        ),
      ),
      Scaffold(
        appBar: AppBar(
          title: Text('Student Hub', style: TextStyle(color: Colors.white)),
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
            labelColor: Colors.white,
            labelPadding: EdgeInsets.only(left: 10),
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 4.0, color: Colors.white),
                insets: EdgeInsets.symmetric(horizontal: 16.0)),
          ),
          backgroundColor: const Color.fromARGB(255, 23, 71, 25),
          automaticallyImplyLeading: false,
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
                      if (changeinPOS == true) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Unsaved Changes'),
                                content: Text(
                                    'You have made changes in your POS, are you sure you want to leave without saving?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      courses.clear();
                                      studentList.clear();
                                      activecourses.clear();
                                      currentStudent!.uid = '';
                                      currentStudent!.enrolledCourses.clear();
                                      currentStudent!.pastCourses.clear();
                                      setState(() {
                                        studentPOSDefault();
                                      });
                                      wrongCreds = false;
                                      // studentPOS = null;
                                      correctCreds = false;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginPage()), //Leave Page
                                      );
                                    },
                                    child: Text(
                                      'Leave without saving',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(false); //Stay on Page
                                    },
                                    child: Text('Stay'),
                                  )
                                ],
                              );
                            });
                      } else {
                        courses.clear();
                        studentList.clear();
                        activecourses.clear();
                        currentStudent!.uid = '';
                        currentStudent!.enrolledCourses.clear();
                        currentStudent!.pastCourses.clear();
                        setState(() {
                          studentPOSDefault();
                        });
                        wrongCreds = false;
                        // studentPOS = null;
                        correctCreds = false;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPage()), //Leave Page
                        );
                      }
                    },
                  ),
                ],
              )),
              selectedIndex: selectedIndex,
              items: const [
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
