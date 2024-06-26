import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:confetti/confetti.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:sysadmindb/api/email/invoice_service.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/coursedemand.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/en-19.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/ui/forms/form.dart';
import 'package:sysadmindb/api/calendar/test_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:html' as html;

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

int getTotalUnits() {
  int totalUnitsCompleted = currentStudent!.pastCourses
      .where((course) => course.grade >= 2.0)
      .fold(0, (sum, course) => sum + course.units);
  return totalUnitsCompleted;
}

int unitsCompleted =
    currentStudent!.pastCourses.fold(0, (int sum, PastCourse pastCourse) {
  return sum + pastCourse.units;
});
late Future<ListResult> documentations;
late Future<ListResult> defenseForms;

String _capitalize(String input) {
  if (input.isEmpty) {
    return '';
  }
  return input[0].toUpperCase() + input.substring(1);
}

ConfettiController _confettiController =
    ConfettiController(duration: const Duration(seconds: 5));

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
                          borderRadius: BorderRadius.circular(8.0),
                        ),
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
                                  color: Color.fromARGB(255, 23, 71, 25),
                                ),
                              ),
                              Text(
                                currentStudent!.degree.contains('MSIT')
                                    ? 'Master of Science in Information Technology - ${currentStudent!.idnumber}'
                                    : 'Master in Information Technology - ${currentStudent!.idnumber}',
                              ),
                              Text(currentStudent!.email),
                              Row(
                                children: [
                                  Text('Enrollment Status: '),
                                  DropdownButton<String>(
                                    value: currentUser.status,
                                    items: <String>[
                                      'Full Time',
                                      'Part Time',
                                      'LOA'
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirm Change'),
                                              content: Text(
                                                  'Are you sure you want to change your enrollment status to $newValue?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      currentUser.status =
                                                          newValue;
                                                      // Update the user's enrollment status in the database or other storage here
                                                    });
                                                    // Update Firestore to reflect the changes
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(currentUser.uid)
                                                        .update({
                                                      'status':
                                                          currentUser.status,
                                                    });
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: Text('Confirm'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                isValidPass
                                    ? '🔒 Your password is secure'
                                    : '✖ Your password is not secure',
                                style: TextStyle(
                                  color:
                                      isValidPass ? Colors.green : Colors.red,
                                ),
                              ),
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

void addEnrollEdCourse() {}

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
    bool fromEnrolled,
  ) async {
    int indextodelete = 0;

    for (int i = 0; i < currentStudent!.enrolledCourses.length; i++) {
      if (currentStudent!.enrolledCourses[i].coursecode ==
          enrolledCourse.coursecode) {
        indextodelete = i;
      }
    }
    bool confirmDelete = true;
    if (!fromEnrolled) {
      confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this course?'),
            actions: [
              TextButton(
                onPressed: () {
                  confirmDelete = false;
                  Navigator.pop(context, false); // No, do not delete
                },
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  confirmDelete = true;
                  Navigator.pop(context, true); // Yes, delete
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
    }

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
          currentStudent!.enrolledCourses.removeAt(indextodelete);
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

  bool checkPrerequisites(Course selectedCourse, Student student) {
    if (student.degree.contains('MIT')) {
      if (selectedCourse.coursecode == 'CIS411M') {
        return true; // No prerequisites for CIS801M in MSIT
      } else if (selectedCourse.coursecode == 'CAPROP') {
        // Check for CIS411M in past courses with a passing grade
        bool hasCIS411M = student.pastCourses.any((course) =>
            course.coursecode == 'CIS411M' &&
            course.grade >= 2.0 &&
            course.grade <= 4);
        return hasCIS411M;
      } else if (selectedCourse.coursecode == 'CAPFIND') {
        // Check for CIS411M and Capstone Project Proposal in past courses
        bool hasCIS411M = student.pastCourses.any((course) =>
            course.coursecode == 'CIS411M' &&
            course.grade >= 2.0 &&
            course.grade <= 4);
        bool hasProposal = student.pastCourses.any((course) =>
            course.coursename == 'Capstone Project Proposal' &&
            course.grade >= 2.0 &&
            course.grade <= 4);
        return hasCIS411M && hasProposal;
      }
    } else if (student.degree.contains('MSIT')) {
      if (selectedCourse.coursecode == 'CIS801M') {
        return true; // No prerequisites for CIS801M in MSIT
      } else if (selectedCourse.coursecode == 'THWR1') {
        // Check for CIS801M in past courses with a passing grade
        bool hasCIS801M = student.pastCourses.any((course) =>
            course.coursecode == 'CIS801M' &&
            course.grade >= 2.0 &&
            course.grade <= 4);
        return hasCIS801M;
      } else if (selectedCourse.coursecode == 'THPROD') {
        // Check for THWR1 in past courses with a passing grade
        bool hasTHWR1 = student.pastCourses.any((course) =>
            course.coursecode == 'THWR1' &&
            course.grade >= 2.0 &&
            course.grade <= 4);
        return hasTHWR1;
      } else if (selectedCourse.coursecode == 'THWR2') {
        // Check for THPROD in past courses with a passing grade
        bool hasTHPROD = student.pastCourses.any((course) =>
            course.coursecode == 'THPROD' &&
            course.grade >= 0 &&
            course.grade <= 4);
        return hasTHPROD;
      } else if (selectedCourse.coursecode == 'THFIND') {
        // Check for THWR2 in past courses with a passing grade
        bool hasTHWR2 = student.pastCourses.any((course) =>
            course.coursecode == 'THWR2' &&
            course.grade >= 0 &&
            course.grade <= 4);
        return hasTHWR2;
      }
    }
    return false; // Return false if prerequisites are not fulfilled
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
    bool hasPreReq = true;
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
                                        currentStudent!.degree.contains('MIT')
                                            ? 'Capstone'
                                            : 'Thesis';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor: selectedRadio ==
                                          (currentStudent!.degree
                                                  .contains('MIT')
                                              ? 'Capstone'
                                              : 'Thesis')
                                      ? Color.fromARGB(255, 0, 0,
                                          0) // Text color when selected
                                      : null,
                                  backgroundColor: selectedRadio ==
                                          (currentStudent!.degree
                                                  .contains('MIT')
                                              ? 'Capstone'
                                              : 'Thesis')
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio ==
                                            (currentStudent!.degree
                                                    .contains('MIT')
                                                ? 'Capstone'
                                                : 'Thesis')
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  currentStudent!.degree.contains('MIT')
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
                                      (currentStudent!.degree
                                              .contains(course.program) ||
                                          course.program.contains('/')) &&
                                      course.type.toLowerCase().contains(
                                          selectedRadio.toLowerCase()))
                                  .length,
                              itemBuilder: (BuildContext context, int index) {
                                final course = activecourses
                                    .where((course) =>
                                        (currentStudent!.degree
                                                .contains(course.program) ||
                                            course.program.contains('/')) &&
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
                        if (!hasPreReq)
                          Text(
                            'This course has a pre-requisite course which you have not taken or passed',
                            style: TextStyle(color: Colors.red),
                          ),
                        if (selectedCourse != null)
                          Text(
                            "Course code",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        Text(
                          selectedCourse!.coursecode,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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
                      bool THEorCAP = false;
                      if (selectedCourse != blankCourse) {
                        // Check if the course is already enrolled or in past courses
                        if (currentStudent!.enrolledCourses.any((course) =>
                                course.coursecode ==
                                selectedCourse?.coursecode) ||
                            currentStudent!.pastCourses.any((course) =>
                                course.coursecode ==
                                selectedCourse?.coursecode)) {
                          setState(() {
                            courseAlreadyExists = true;
                          });
                          return;
                        } else {
                          if (selectedCourse!.type
                                  .toLowerCase()
                                  .contains('capstone') ||
                              selectedCourse!.type
                                  .toLowerCase()
                                  .contains('thesis')) {
                            THEorCAP = true;
                          }
                          // Check prerequisites
                          if (!checkPrerequisites(
                                  selectedCourse!, currentStudent!) &&
                              THEorCAP) {
                            setState(() {
                              hasPreReq = false;
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
                              program: selectedCourse!.program,
                            );

                            onAddEnrolledCourse(enrolledCourse);

                            try {
                              // Get the current user ID
                              String userId = currentUser.uid;

                              // Update numstudents in the Courses collection
                              await FirebaseFirestore.instance
                                  .collection('courses')
                                  .doc(activecourses[selectedCourseIndex!].uid)
                                  .update(
                                      {'numstudents': FieldValue.increment(1)});

                              // Update user data in Firestore
                              for (Student student in studentList) {
                                if (student.enrolledCourses.any((course) =>
                                    course.coursecode ==
                                    activecourses[selectedCourseIndex!]
                                        .coursecode)) {
                                  final DocumentReference studentDocRef =
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(student.uid);

                                  final DocumentReference studentPOSRef =
                                      FirebaseFirestore.instance
                                          .collection('studentpos')
                                          .doc(student.uid);

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
                                        enrolledCoursesData
                                            .forEach((enrolledCourseData) {
                                          if (enrolledCourseData
                                                  is Map<String, dynamic> &&
                                              enrolledCourseData[
                                                      'coursecode'] ==
                                                  activecourses[
                                                          selectedCourseIndex!]
                                                      .coursecode) {
                                            if (enrolledCourseData[
                                                'numstudents'] is int) {
                                              enrolledCourseData[
                                                      'numstudents'] =
                                                  (enrolledCourseData[
                                                              'numstudents']
                                                          as int) +
                                                      1;
                                            }
                                          }
                                        });

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
                          // Proceed to add the course
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
      Course? selectedCourse,
      Function(PastCourse) onAddPastCourse,
      bool fromEnrolled) {
    int? selectedCourseIndex;
    bool courseAlreadyExists = false;
    double? enteredGrade; // Variable to store the entered grade
    String selectedRadio = '';
    bool hasPreReq = true;
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
                                        currentStudent!.degree.contains('MIT')
                                            ? 'Capstone'
                                            : 'Thesis';
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20.0),
                                  foregroundColor: selectedRadio ==
                                          (currentStudent!.degree
                                                  .contains('MIT')
                                              ? 'Capstone'
                                              : 'Thesis')
                                      ? Color.fromARGB(255, 0, 0,
                                          0) // Text color when selected
                                      : null,
                                  backgroundColor: selectedRadio ==
                                          (currentStudent!.degree
                                                  .contains('MIT')
                                              ? 'Capstone'
                                              : 'Thesis')
                                      ? Color.fromARGB(50, 13, 105, 16)
                                      : null, // Fully transparent background
                                  side: BorderSide(
                                    color: selectedRadio ==
                                            (currentStudent!.degree
                                                    .contains('MIT')
                                                ? 'Capstone'
                                                : 'Thesis')
                                        ? const Color.fromARGB(255, 23, 71,
                                            25) // Border color when selected
                                        : Colors
                                            .transparent, // Transparent border color when not selected
                                  ),
                                ),
                                child: Text(
                                  currentStudent!.degree.contains('MIT')
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
                                      (currentStudent!.degree
                                              .contains(course.program) ||
                                          course.program.contains('/')) &&
                                      course.type.toLowerCase().contains(
                                          selectedRadio.toLowerCase()))
                                  .length,
                              itemBuilder: (BuildContext context, int index) {
                                final course = courses
                                    .where((course) =>
                                        (currentStudent!.degree
                                                .contains(course.program) ||
                                            course.program.contains('/')) &&
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
                        if (!hasPreReq)
                          Text(
                            'This course is has a pre-requisite course which you have not taken',
                            style: TextStyle(color: Colors.red),
                          ),
                        if (selectedCourse != null)
                          Text(
                            "Course code",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        Text(
                          selectedCourse!.coursecode,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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

                            // Check if the value is a double using a regular expression
                            final gradeRegex = RegExp(r'^[0-4]\.?[0-9]?$');
                            if (!gradeRegex.hasMatch(value)) {
                              return 'Invalid grade. Enter a value between 0.0 and 4.0.';
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
                    bool THEorCAP = false;
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      if ((currentStudent!.enrolledCourses.any((course) =>
                                  course.coursecode ==
                                  selectedCourse?.coursecode) ||
                              currentStudent!.pastCourses.any((course) =>
                                  course.coursecode ==
                                  selectedCourse?.coursecode)) &&
                          !fromEnrolled) {
                        // Check if the course is already in pastCourses
                        setState(() {
                          courseAlreadyExists = true;
                        });
                      } else {
                        if (selectedCourse!.type
                                .toLowerCase()
                                .contains('capstone') ||
                            selectedCourse!.type
                                .toLowerCase()
                                .contains('thesis')) {
                          THEorCAP = true;
                        }
                        if (!checkPrerequisites(
                                selectedCourse!, currentStudent!) &&
                            THEorCAP) {
                          setState(() {
                            hasPreReq = false;
                          });
                          return;
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
                          } catch (e) {
                            print('Error adding past course: $e');
                            // Handle the error and display a relevant message
                          }

                          if (fromEnrolled) {
                            _deleteEnrolledCourse(
                                EnrolledCourseData(
                                    uid: pastCourse.uid,
                                    coursecode: pastCourse.coursecode,
                                    coursename: pastCourse.coursename,
                                    isactive: pastCourse.isactive,
                                    facultyassigned: pastCourse.facultyassigned,
                                    numstudents: pastCourse.numstudents,
                                    units: pastCourse.units,
                                    type: pastCourse.type,
                                    program: pastCourse.program),
                                fromEnrolled);
                          }
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
      body: SingleChildScrollView(
        child: Padding(
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
                          DataCell(
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    showAddPastCourse(
                                        context,
                                        _formKey,
                                        enrolledCourse,
                                        (enrolledCourse) => setState(() {
                                              currentStudent!.pastCourses
                                                  .add(enrolledCourse);
                                            }),
                                        true);
                                  },
                                  child: Icon(
                                    Icons.done_all,
                                    color:
                                        const Color.fromARGB(255, 32, 102, 34),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    // Handle delete action
                                    _deleteEnrolledCourse(
                                        enrolledCourse, false);
                                  },
                                ),
                              ],
                            ),
                          ),
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
              Column(
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
                            courses.isNotEmpty ? courses[0] : null,
                            (pastCourse) => setState(() {
                                  currentStudent!.pastCourses.add(pastCourse);
                                }),
                            false);
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
              ),
            ],
          ),
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

final PdfInvoiceService service = PdfInvoiceService();

class RemoteFile {
  final String name;
  final String url; // Assuming you have a download URL for the file
  // Add other properties relevant to your file data

  const RemoteFile({required this.name, required this.url});
}

void downloadFile(Reference ref, BuildContext context) async {
  final String url = await ref.getDownloadURL();
}

class CapstoneProjectScreen extends StatefulWidget {
  @override
  State<CapstoneProjectScreen> createState() => _CapstoneProjectScreenState();
}

Reference emptyReference = FirebaseStorage.instance.ref(); // Or any other path

class _CapstoneProjectScreenState extends State<CapstoneProjectScreen> {
  PlatformFile? pickedFile;
  EN19Form? _retrievedForm;
  bool hasEn19Form = false;
  Future<void> retrieveEN19Form() async {
    EN19Form? form = await EN19Form.getFormFromFirestore(currentStudent!.uid);

    setState(() {
      _retrievedForm = form;
    });
  }

  Future<void> checkIfFormExists() async {
    bool exists = await EN19Form.hasEn19Form(currentStudent!.uid);

    setState(() {
      hasEn19Form = exists;
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfFormExists();
    retrieveEN19Form();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    List<DataRow> rows = [];

    Future<void> uploadDocFile(String coursecode) async {
      if (currentStudent!.enrolledCourses
              .any((course) => course.coursecode == coursecode) ||
          currentStudent!.pastCourses
              .any((course) => course.coursecode == coursecode)) {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        if (result != null) {
          PlatformFile file = result.files.first;
          String fileName =
              '${currentStudent!.idnumber}/Documentations/${coursecode}_${currentStudent!.idnumber}.pdf';

          Uint8List fileBytes = file.bytes!;
          final ref = FirebaseStorage.instance.ref().child(fileName);
          await ref.putData(fileBytes);
        }

        setState(() {
          documentations = FirebaseStorage.instance
              .ref('/${currentStudent!.idnumber}/Documentations')
              .listAll();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'You are not currently enrolled nor had completed this class'),
          ),
        );
      }
    }

    Future<void> uploadGeneratedPdf(Uint8List data, String form) async {
      String fileName =
          '${currentStudent!.idnumber}/Defense Forms/${form}_${currentStudent!.idnumber}.pdf';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putData(data);
      print('Generated PDF uploaded successfully');
    }

    Future<void> uploadEN19File(EN19Form formDetails) async {
      bool confirmSign = false;
      bool signedByGSC = false;
      bool signedByAdviser = false;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: Text('Confirm Signatories'),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Please confirm that the document that will be\nuploaded is signed by the Coordinator and your Adviser.'),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Signed by Coordinator?',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: signedByGSC,
                          onChanged: (bool? value) {
                            setState(() {
                              signedByGSC = value!;
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<bool>(
                          value: false,
                          groupValue: signedByGSC,
                          onChanged: (bool? value) {
                            setState(() {
                              signedByGSC = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Signed by adviser?',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: signedByAdviser,
                          onChanged: (bool? value) {
                            setState(() {
                              signedByAdviser = value!;
                            });
                          },
                        ),
                        Text('Yes'),
                        Radio<bool>(
                          value: false,
                          groupValue: signedByAdviser,
                          onChanged: (bool? value) {
                            setState(() {
                              signedByAdviser = value!;
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      confirmSign = false;
                      Navigator.pop(context, false); // No, do not delete
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() async {
                        confirmSign = true;
                        if (confirmSign) {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();
                          if (result != null) {
                            PlatformFile file = result.files.first;
                            String fileName =
                                '${currentStudent!.idnumber}/Defense Forms/EN-19Form_${currentStudent!.idnumber}.pdf';
                            Uint8List fileBytes = file.bytes!;

                            // Create EN19Form object
                            EN19Form form = EN19Form(
                              proposedTitle: formDetails.proposedTitle,
                              lastName: _capitalize(
                                  currentStudent!.displayname['lastname']!),
                              firstName: _capitalize(
                                  currentStudent!.displayname['firstname']!),
                              middleName: formDetails.middleName,
                              idNumber: currentStudent!.idnumber.toString(),
                              college: 'Computer Studies',
                              program: currentStudent!.degree,
                              passedComprehensiveExams: false,
                              submittedCertificate: false,
                              adviserName: formDetails.adviserName,
                              enrollmentStage: formDetails.enrollmentStage,
                              date: DateTime.now(),
                              leadPanel: formDetails.leadPanel,
                              panelMembers: formDetails.panelMembers,
                              defenseDate: formDetails.defenseDate,
                              signedByGSC: signedByGSC,
                              signedByAdviser: signedByAdviser,
                              defenseTime: formDetails.defenseTime,
                              mainTitle: formDetails.mainTitle,
                              defenseType: formDetails.defenseType,
                              verdict: formDetails.verdict,
                            );

                            form.saveFormToFirestore(form, currentStudent!.uid);
                            final ref =
                                FirebaseStorage.instance.ref().child(fileName);

                            await ref.putData(fileBytes);
                            setState(() {
                              retrieveEN19Form();
                            });

                            print('File uploaded successfully');
                            Navigator.pop(context, true);
                          } else {
                            print('No file selected');
                          }
                        }
                      });

                      Navigator.pop(context, true); // Yes, delete
                    },
                    child: Text('Proceed'),
                  ),
                ],
              ),
            );
          });
        },
      );
    }

    Future<void> showEN19FormDialog(BuildContext context) async {
      String selectedType = 'Thesis';
      int selectedNumber = 1;
      String adviserPrefix = 'Mr';
      TextEditingController adviserNameController = TextEditingController();
      TextEditingController mainTitleController = TextEditingController();
      bool isAdviserNameEmpty = false;
      bool isMainTitleEmpty = false;
      bool signedByAdviser = false;
      bool signedByGSC = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Fill EN19 Form'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Proposed Title',
                        style: TextStyle(fontSize: 15),
                      ),
                      DropdownButton<String>(
                        value: selectedType,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedType = newValue!;
                            selectedNumber =
                                1; // Reset the number on type change
                          });
                        },
                        items: ['Thesis', 'Dissertation']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Enrollment Stage',
                        style: TextStyle(fontSize: 15),
                      ),
                      DropdownButton<int>(
                        value: selectedNumber,
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedNumber = newValue!;
                          });
                        },
                        items: List.generate(selectedType == 'Thesis' ? 9 : 15,
                                (index) => index + 1)
                            .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$selectedType $value'),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Title',
                        style: TextStyle(fontSize: 15),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: mainTitleController,
                              decoration: InputDecoration(
                                  hintText: 'Enter title of $selectedType',
                                  errorText: isMainTitleEmpty
                                      ? 'This is a required field'
                                      : null),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Adviser',
                        style: TextStyle(fontSize: 15),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButton<String>(
                            value: adviserPrefix,
                            onChanged: (String? newValue) {
                              setState(() {
                                adviserPrefix = newValue!;
                              });
                            },
                            items: ['Mr', 'Ms']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: adviserNameController,
                              decoration: InputDecoration(
                                  hintText: 'Enter adviser name',
                                  errorText: isAdviserNameEmpty
                                      ? 'This is a required field'
                                      : null),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        isAdviserNameEmpty = adviserNameController.text.isEmpty;
                        isMainTitleEmpty = mainTitleController.text.isEmpty;
                      });
                      if (isAdviserNameEmpty) {
                        // Do not close the dialog if the adviser name is empty
                        return;
                      }

                      if (isMainTitleEmpty) {
                        // Do not close the dialog if the adviser name is empty
                        return;
                      }

                      // Collect form data
                      String adviserName =
                          '$adviserPrefix ${adviserNameController.text}';
                      String enrollmentStage = '$selectedType $selectedNumber';

                      // Create EN19Form object
                      EN19Form form = EN19Form(
                        proposedTitle: selectedType,
                        lastName: _capitalize(
                            currentStudent!.displayname['lastname']!),
                        firstName: _capitalize(
                            currentStudent!.displayname['firstname']!),
                        middleName: '',
                        idNumber: currentStudent!.idnumber.toString(),
                        college: 'Computer Studies',
                        program: currentStudent!.degree,
                        passedComprehensiveExams: false,
                        submittedCertificate: false,
                        adviserName: adviserName,
                        enrollmentStage: enrollmentStage,
                        date: DateTime.now(),
                        leadPanel: 'No lead panel assigned',
                        panelMembers: ['', '', '', ''],
                        defenseDate: 'No date set',
                        signedByGSC: signedByGSC,
                        signedByAdviser: signedByAdviser,
                        defenseTime: 'No time set',
                        mainTitle: _capitalize(mainTitleController.text),
                        defenseType: ' ',
                        verdict: ' ',
                      );

                      Navigator.of(context).pop();

                      // If the first dialog was successfully closed, proceed to open the second dialo
                      await uploadEN19File(form);
                    },
                    child: Text('Submit'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    DataCell buildDocDataCell(
      Course course,
      BuildContext context,
      String reference,
    ) {
      // Get the download URL of the file from Firebase Storage

      return DataCell(
        SizedBox(
          width: MediaQuery.of(context).size.width / 8,
          child: FutureBuilder<ListResult>(
            future: documentations,
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
                        IconButton(
                          icon: Icon(Icons.attach_file),
                          onPressed: () async {
                            // Prompt the user to select a file

                            await uploadDocFile(course.coursecode);
                          },
                        ),
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
                    trailing: IconButton(
                      icon: Icon(Icons.attach_file),
                      onPressed: () async {
                        // Prompt the user to select a file

                        await uploadDocFile(course.coursecode);
                      },
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

    DataRow isCoursePassed(Course course, BuildContext context) {
      final bool isPassed = currentStudent!.pastCourses.any((pastCourse) =>
          pastCourse.coursecode == course.coursecode &&
          pastCourse.grade >= 2.0);
      final bool isNotPassed = currentStudent!.pastCourses.any((pastCourse) =>
          pastCourse.coursecode == course.coursecode && pastCourse.grade < 2.0);
      final bool isInProgress = currentStudent!.enrolledCourses.any(
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
            "${currentStudent!.idnumber}/Documentations/${course.coursecode}_${currentStudent!.idnumber}.pdf")
      ]);
    }

    void showDefenseVerdictDialog(BuildContext context, EN19Form en19) {
      String selectedVerdict = ' ';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Defense Verdict'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Verdict',
                      style: TextStyle(fontSize: 15),
                    ),
                    DropdownButton<String>(
                      value: selectedVerdict,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedVerdict = newValue!;
                        });
                      },
                      items: [' ', 'Passed', 'Failed', 'Redefense']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child:
                              Text(value == ' ' ? 'Select a verdict' : value),
                        );
                      }).toList(),
                    ),
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
                    onPressed: () async {
                      if (selectedVerdict == ' ') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select a verdict'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Create EN19Form object with updated verdict

                      if (selectedVerdict == 'Redefense') {
                        en19.panelMembers.clear();
                        EN19Form form = EN19Form(
                          proposedTitle: en19.proposedTitle,
                          lastName: en19.lastName,
                          firstName: en19.firstName,
                          middleName: en19.middleName,
                          idNumber: en19.idNumber,
                          college: en19.college,
                          program: en19.program,
                          passedComprehensiveExams:
                              en19.passedComprehensiveExams,
                          submittedCertificate: en19.submittedCertificate,
                          adviserName: en19.adviserName,
                          enrollmentStage: en19.enrollmentStage,
                          date: DateTime.now(),
                          leadPanel: 'No lead panel assigned',
                          panelMembers: ['', '', '', ''],
                          defenseDate: 'No date set',
                          signedByGSC: en19.signedByGSC,
                          signedByAdviser: en19.signedByAdviser,
                          defenseTime: 'No time set',
                          mainTitle: en19.mainTitle,
                          defenseType: en19.defenseType,
                          verdict: selectedVerdict,
                        );
                        form.saveFormToFirestore(form, currentStudent!.uid);
                      } else {
                        EN19Form form = EN19Form(
                          proposedTitle: en19.proposedTitle,
                          lastName: en19.lastName,
                          firstName: en19.firstName,
                          middleName: en19.middleName,
                          idNumber: en19.idNumber,
                          college: en19.college,
                          program: en19.program,
                          passedComprehensiveExams:
                              en19.passedComprehensiveExams,
                          submittedCertificate: en19.submittedCertificate,
                          adviserName: en19.adviserName,
                          enrollmentStage: en19.enrollmentStage,
                          date: DateTime.now(),
                          leadPanel: en19.leadPanel,
                          panelMembers: en19.panelMembers,
                          defenseDate: en19.defenseDate,
                          signedByGSC: en19.signedByGSC,
                          signedByAdviser: en19.signedByAdviser,
                          defenseTime: en19.defenseTime,
                          mainTitle: en19.mainTitle,
                          defenseType: en19.defenseType,
                          verdict: selectedVerdict,
                        );
                        form.saveFormToFirestore(form, currentStudent!.uid);
                      }

                      Navigator.of(context).pop();
                    },
                    child: Text('Submit'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    void showDefenseFormDialog(BuildContext context, EN19Form en19) {
      String selectedDefenseType = 'Proposal Defense';
      final TextEditingController mainTitleController = TextEditingController();
      bool isMainTitleEmpty = false;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Fill Defense Form'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Type of Defense',
                        style: TextStyle(fontSize: 15),
                      ),
                      DropdownButton<String>(
                        value: selectedDefenseType,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDefenseType = newValue!;
                          });
                        },
                        items: [
                          'Proposal Defense',
                          'Final Defense',
                          'Defense without Proposal'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Title',
                        style: TextStyle(fontSize: 15),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: mainTitleController,
                              decoration: InputDecoration(
                                  hintText: en19.mainTitle,
                                  errorText: isMainTitleEmpty
                                      ? 'This is a required field'
                                      : null),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        isMainTitleEmpty = mainTitleController.text.isEmpty;
                      });

                      if (isMainTitleEmpty) {
                        return;
                      }

                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();

                      PlatformFile file = result!.files.first;
                      String fileName =
                          '${currentStudent!.idnumber}/Defense Forms/EN-18DefenseForm_${currentStudent!.idnumber}.pdf';

                      Uint8List fileBytes = file.bytes!;
                      final ref =
                          FirebaseStorage.instance.ref().child(fileName);
                      await ref.putData(fileBytes);

                      // Create EN19Form object
                      EN19Form form = EN19Form(
                        proposedTitle: en19.proposedTitle,
                        lastName: _capitalize(
                            currentStudent!.displayname['lastname']!),
                        firstName: _capitalize(
                            currentStudent!.displayname['firstname']!),
                        middleName: '',
                        idNumber: currentStudent!.idnumber.toString(),
                        college: 'Computer Studies',
                        program: currentStudent!.degree,
                        passedComprehensiveExams: en19.passedComprehensiveExams,
                        submittedCertificate: en19.submittedCertificate,
                        adviserName: en19.adviserName, // Adjust if necessary
                        enrollmentStage: en19.enrollmentStage,
                        date: DateTime.now(),
                        leadPanel: en19.leadPanel,
                        panelMembers: en19.panelMembers,
                        defenseDate: 'No date set',
                        signedByGSC: en19.signedByGSC,
                        signedByAdviser: en19.signedByAdviser,
                        defenseTime: 'No time set',
                        mainTitle: _capitalize(mainTitleController.text),
                        defenseType: selectedDefenseType,
                        verdict: ' ',
                      );

                      form.saveFormToFirestore(form, currentStudent!.uid);

                      Navigator.of(context).pop();
                    },
                    child: Text('Submit'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    if (currentStudent!.degree.contains('MIT')) {
      rows = capstonecourses.map((capstoneCourse) {
        return isCoursePassed(capstoneCourse, context);
      }).toList();
    } else if (currentStudent!.degree.contains('MSIT')) {
      rows = thesiscourses.map((thesisCourse) {
        return isCoursePassed(thesisCourse, context);
      }).toList();
    }

    bool checkProposalCourse() {
      // Assuming student.enrolledCourses is a list of courses with courseName property
      // Modify according to your actual data structure
      bool isProposalCourseEnrolled = currentStudent!.enrolledCourses.any(
          (course) => course.coursename.toLowerCase().contains('proposal'));

      return isProposalCourseEnrolled;
    }

    bool checkWritingCourse() {
      // Assuming student.enrolledCourses is a list of courses with courseName property
      // Modify according to your actual data structure
      bool isProposalCourseEnrolled = currentStudent!.enrolledCourses
          .any((course) => course.coursename.toLowerCase().contains('writing'));

      return isProposalCourseEnrolled;
    }

    return Row(
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
                  height: 8), // Optional: Adjust the space from top if needed
              Center(
                child: DataTable(
                  columns: columns,
                  rows: rows,
                ),
              ),
              SizedBox(
                  height: 10), // Optional: Adjust the space from top if needed
              Text(
                'Defense Requirements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DataTable(
                columns: [
                  DataColumn(label: Text('Document Type')),
                  DataColumn(label: Text('Signed by Coordinator')),
                  DataColumn(label: Text('Signed by Adviser')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text('EN-19 Form')),
                    DataCell(
                      Icon(
                        _retrievedForm!.signedByGSC
                            ? Icons.check_circle_outline
                            : Icons.cancel,
                        color: _retrievedForm!.signedByGSC
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    DataCell(
                      Icon(
                        _retrievedForm!.signedByAdviser
                            ? Icons.check_circle_outline
                            : Icons.cancel,
                        color: _retrievedForm!.signedByAdviser
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.file_download),
                          onPressed:
                              // Show the first dialog and wait until it is closed
                              hasEn19Form
                                  ? () async {
                                      String fileName =
                                          '${currentStudent!.idnumber}/Defense Forms/EN-19Form_${currentStudent!.idnumber}.pdf';
                                      final imageUrl = await FirebaseStorage
                                          .instance
                                          .ref()
                                          .child(fileName)
                                          .getDownloadURL();
                                      if (await canLaunch(
                                          imageUrl.toString())) {
                                        await launch(imageUrl.toString());
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Failed to download file'),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.file_upload),
                          onPressed: () async {
                            // Show the first dialog and wait until it is closed
                            await showEN19FormDialog(context);
                          },
                        ),
                        TextButton(
                          onPressed: () async {
                            String fileName =
                                'templates/EN-19 Thesis Writing Form.pdf';
                            final imageUrl = await FirebaseStorage.instance
                                .ref()
                                .child(fileName)
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
                          child: Text(
                            'Download EN-19 Template',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    )),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Defense Form')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.file_download),
                          onPressed: () async {
                            String fileName =
                                '${currentStudent!.idnumber}/Defense Forms/EN-18DefenseForm_${currentStudent!.idnumber}.pdf';
                            final imageUrl = await FirebaseStorage.instance
                                .ref()
                                .child(fileName)
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
                          tooltip: 'Download EN-18 Defense Form',
                        ),
                        IconButton(
                          icon: Icon(Icons.file_upload),
                          onPressed: () {
                            showDefenseFormDialog(context, _retrievedForm!);
                          },
                          tooltip: 'Upload EN-18 Defenes Form',
                        ),
                        TextButton(
                          onPressed: () {
                            showDefenseVerdictDialog(context, _retrievedForm!);
                          },
                          child: Text(
                            'Add verdict',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            String fileName =
                                'templates/EN-18-201904 Defense Form.pdf';
                            final imageUrl = await FirebaseStorage.instance
                                .ref()
                                .child(fileName)
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
                          child: Text(
                            'Download EN-18 Template',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    )),
                  ]),
                  // Add more rows here for other documents if needed
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  buildCompletedButton(unitsCompleted, rows.length),
                  Tooltip(
                    message:
                        'Total units completed is ${getTotalUnits()} units (Required: 36 units)', // Display the list of students
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCompletedButton(int unitsCompleted, int rowsLength) {
    return Column(
      children: [
        Text('Ready to graduate?'),
        SizedBox(height: 5),
        ElevatedButton(
          onPressed: unitsCompleted != 36
              ? null
              : () {
                  print(rowsLength);
                  _confettiController.play();

                  FirebaseFirestore.instance
                      .collection('graduatingStudents')
                      .doc(currentStudent!.uid)
                      .set(currentStudent!.toJson());

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Congratulations on completing the program!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
          child: Text('Completed'),
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
    documentations = FirebaseStorage.instance
        .ref('/${currentStudent!.idnumber}/Documentations')
        .listAll();
    defenseForms = FirebaseStorage.instance
        .ref('/${currentStudent!.idnumber}/Defense Forms')
        .listAll();
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
    int electiveCount = 1;
    List<Widget> views = [
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors
                            .white, // Set the background color of the table
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: DataTable(
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        dataRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.white,
                        ),
                        border: TableBorder.all(
                          width: 0.5,
                          color: Colors.black,
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              'Course Code',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Course Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Units',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Course Type',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: [
                          for (var year in studentPOS.schoolYears) ...[
                            DataRow(cells: [
                              DataCell(Text(
                                'S.Y: ${year.name}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              DataCell(Text(
                                '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              DataCell(Text('')), // Empty cell for units
                              DataCell(Text('')), // Empty cell for course type
                            ]),
                            for (var term in year.terms) ...[
                              DataRow(cells: [
                                DataCell(Text(
                                  term.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                DataCell(Text(
                                  '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                DataCell(Text('')), // Empty cell for units
                                DataCell(
                                    Text('')), // Empty cell for course type
                              ]),
                              for (var course in term.termcourses)
                                DataRow(cells: [
                                  // Always create two cells for the first column
                                  DataCell(Text(
                                      course.type != 'Elective Courses'
                                          ? course.coursecode
                                          : '')), // Course Code or empty string
                                  DataCell(Text(course.type ==
                                          'Elective Courses'
                                      ? 'Elective ${electiveCount++}'
                                      : course
                                          .coursename)), // Course Name (Elective or regular)
                                  DataCell(Text('${course.units}')),
                                  DataCell(Text(course.type)),
                                ]),
                            ],
                            // Add an empty row after processing all terms in the school year
                            DataRow(
                              cells: [
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                              ],
                              color: MaterialStateProperty.all(Colors.grey
                                  .withOpacity(
                                      0.2)), // Set a slightly transparent grey
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      Scaffold(
        appBar: AppBar(
          title: Text('Student Hub', style: TextStyle(color: Colors.white)),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: 'Curriculum Audit',
              ),
              Tab(
                text: currentStudent!.degree.contains('MIT')
                    ? 'Capstone Progress'
                    : 'Thesis Progress',
              ),
              Tab(
                text: 'Profile',
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
            CurriculumAuditScreen(),
            CapstoneProjectScreen(),
            StudentProfileScreen(),
          ],
        ),
      ),

      // CALENDAR PAGE || Following guide: https://www.youtube.com/watch?v=6Gxa-v7Zh7I&ab_channel=AIwithFlutter
      CalendarSF(),

      Center(
        child: Text(
          'Inbox',
          textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: 'Inter', fontSize: 100),
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
                    "${currentUser.displayname['firstname']} ${currentUser.displayname['lastname']!} (${currentUser.idnumber})",
                    style: TextStyle(color: Colors.white, fontSize: 20),
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
                  icon: Icons.school,
                  label: 'Student Hub',
                ),
                SideNavigationBarItem(
                  icon: Icons.event,
                  label: 'Calendar',
                ),
                SideNavigationBarItem(
                  icon: Icons.message,
                  label: 'Inbox',
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
