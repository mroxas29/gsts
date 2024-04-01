import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sysadmindb/api/email/sendemail.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/main.dart';

class UserData {
  Map<String, String> displayname = {};
  late String email;
  late int idnumber;
  late String role;
  late String password;
  String degree = '';
  String status = '';
}

String generateRandomPassword() {
  const characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#%^&*()_+-=[]{}|;:,.<>?';
  final random = Random();
  final passwordLength = 12; // Minimum length required

  return List.generate(
          passwordLength, (_) => characters[random.nextInt(characters.length)])
      .join();
}

Future<String?> showStudentTypeDialog(
    BuildContext context, GlobalKey<FormState> formKey) async {
  String studentType = '';
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Student Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                studentType = 'New';
                showAddNewUserForm(context, formKey, studentType);
              },
              child: Text('New Student'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                studentType = 'Employee';
                showAddNewUserForm(context, formKey, studentType);
              },
              child: Text('Employee'),
            ),
          ],
        ),
      );
    },
  );
}

void showAddNewUserForm(
    BuildContext context, GlobalKey<FormState> formKey, String studentType) {
  List<String> roles = ['Coordinator', 'Graduate Student', 'Admin'];
  List<String> degrees = [
    'No degree',
    'MIT',
    'MSIT',
    'MIT-Masters',
    'MIT-Doctorate',
    'MSIT-Masters',
    'MSIT-Doctorate'
  ];
  List<String> status = ['Full Time', 'Part Time', 'LOA'];

  final UserData _userData = UserData();

  String selectedStatus = status[0];
  String selectedDegree = degrees[0];
  String selectedRole = roles[0];
  bool isStudent = false;
  String uid = '';
  final scaffoldContext = ScaffoldMessenger.of(context);

  print("Add user form executed");

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add New User'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userData.displayname['firstname'] = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userData.displayname['lastname'] = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
/*
                    if (!value.contains('@dlsu.edu.ph')) {
                      return 'Enter a valid @dlsu.edu.ph email';
                    }
*/
                    // Add email validation if needed
                    return null;
                  },
                  onSaved: (value) {
                    _userData.email = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'ID Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter ID number';
                    }
                    if (!users
                        .every((user) => user.idnumber != int.parse(value))) {
                      return 'ID number already exists';
                    }

                    // Add ID number validation if needed
                    return null;
                  },
                  onSaved: (value) {
                    _userData.idnumber = int.parse(value ?? '0');
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Add the necessary setState method if needed

                    selectedRole = value!;
                    selectedDegree = '';
                    if (selectedRole.contains('Student')) {
                      isStudent = true;
                    } else {
                      isStudent = false;
                      selectedDegree = '';
                    }
                    print(isStudent.toString());
                  },
                  onSaved: (value) {
                    _userData.role = value ?? '';
                  },
                  decoration: InputDecoration(labelText: 'Role'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedDegree,
                  items: degrees.map((degree) {
                    return DropdownMenuItem<String>(
                      value: degree,
                      child: Text(degree),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Add the necessary setState method if needed
                    selectedDegree = value!;
                  },
                  onSaved: (value) {
                    if (isStudent) {
                      _userData.degree = value ?? '';
                    }
                  },
                  decoration: InputDecoration(labelText: 'Degree'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: status.map((stat) {
                    return DropdownMenuItem<String>(
                      value: stat,
                      child: Text(stat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Add the necessary setState method if needed
                    selectedStatus = value!;
                  },
                  onSaved: (value) {
                    if (isStudent) {
                      _userData.status = value ?? '';
                    }
                  },
                  decoration: (selectedRole == 'Graduate Student')
                      ? InputDecoration(labelText: 'Status')
                      : InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
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
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                String otp = generateRandomPassword();

                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: _userData.email,
                    password: '123123',
                  );

                  User? user = userCredential.user;

                  await user?.sendEmailVerification();
                  sendEmail(
                      firstname: _userData.displayname['firstname'],
                      email: _userData.email,
                      toemail: _userData.email,
                      subject:
                          'New account at the Graduate Student Tracking System',
                      password: otp);

                  String userID = user!.uid;
                  uid = userID;
                  if (isStudent) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userID)
                        .set({
                      'displayname': {
                        'firstname': _userData.displayname['firstname']!,
                        'lastname': _userData.displayname['lastname']!,
                      },
                      'role': _userData.role,
                      'email': _userData.email.toLowerCase(),
                      'enrolledCourses': [],
                      'pastCourses': [],
                      'idnumber': _userData.idnumber,
                      'degree': _userData.degree,
                      'status': _userData.status
                    });

                    Student newStudent = Student(
                      uid: userID,
                      displayname: {
                        'firstname': _userData.displayname['firstname']!,
                        'lastname': _userData.displayname['lastname']!,
                      },
                      role: _userData.role,
                      email: _userData.email.toLowerCase(),
                      enrolledCourses: [],
                      pastCourses: [],
                      idnumber: _userData.idnumber,
                      degree: _userData.degree,
                      status: _userData.status,
                    );
                    final FirebaseFirestore firestore =
                        FirebaseFirestore.instance;

                    if (studentType == 'New') {
                      Map<String, dynamic>? studentPosData;
                      if (_userData.degree.contains('MIT')) {
                        print('student is MIT');

                        studentPosData = generatePOSforMIT(
                                newStudent, studentPOSList, courses)
                            .toJson();
                      }

                      if (_userData.degree.contains('MSIT')) {
                        print('Student is MSIT');
                        studentPosData = generatePOSforMSIT(
                                newStudent, studentPOSList, courses)
                            .toJson();
                      }

                      try {
                        firestore
                            .collection('studentpos')
                            .doc(newStudent.uid)
                            .set(studentPosData!);
                        print('Student POS MADE');
                        // Update local data after saving changes
                        retrieveAllPOS();
                      } catch (error) {
                        print('Failed to update Program of Study');
                      }
                    }
                  } else {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userID)
                        .set({
                      'displayname': {
                        'firstname': _userData.displayname['firstname']!,
                        'lastname': _userData.displayname['lastname']!,
                      },
                      'status': _userData.status,
                      'role': _userData.role,
                      'email': _userData.email.toLowerCase(),
                      'idnumber': _userData.idnumber,
                      'degree': _userData.degree,
                    });
                  }

                  Navigator.pop(context);
                  users.clear();

                  addUserFromFirestore();

                  scaffoldContext.showSnackBar(
                    SnackBar(
                      content: Text('User added'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  print('Error creating user: ${e.toString()}');
                  scaffoldContext.showSnackBar(
                    SnackBar(
                      content: Text('Error creating user: $e'),
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
}
