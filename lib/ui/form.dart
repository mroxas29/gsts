import 'dart:html';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/sysad.dart';

class UserData {
  Map<String, String> displayname = {};
  String email = '';
  int idnumber = 0;
  String role = '';
  String password = '';
}


class CourseData {
  String coursecode = '';
  String coursename = '';
  bool isactive = false;
  String facultyassigned = '';
  int numstudents = 0;
  int units = 0;
}

void showAddCourseForm(BuildContext context, GlobalKey<FormState> formKey) {
  List<String> status = ['true', 'false'];
  final CourseData _courseData = CourseData();

  String selectedstatus = status[0];
  print("Add user form executed");
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add New Course'),
        content: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Course code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the course code';
                  }
                  return null;
                },
                onSaved: (value) {
                  _courseData.coursecode = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Course name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the course name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _courseData.coursename = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Assign to'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the faculty name';
                  }
                  // Add email validation if needed
                  return null;
                },
                onSaved: (value) {
                  _courseData.facultyassigned = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Course units'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the course units';
                  }
                  return null;
                },
                onSaved: (value) {
                  _courseData.units = int.parse(value ?? '');
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedstatus,
                items: status.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedstatus = value!;
                },
                onSaved: (value) {
                  _courseData.isactive = bool.parse(value ?? '');
                },
                decoration: InputDecoration(labelText: 'Is active?'),
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
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                var uid = generateUID();

                try {
                  await FirebaseFirestore.instance
                      .collection('courses')
                      .doc(uid)
                      .set({
                    'coursecode': _courseData.coursecode,
                    'coursename': _courseData.coursename,
                    'facultyassigned': _courseData.facultyassigned,
                    'units': _courseData.units,
                    'isactive': _courseData.isactive,
                    'numstudents': 0,
                  });
                  Navigator.pop(context);
                  courses.clear();
                  getCoursesFromFirestore();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Course created'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  print('Error creating course: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error creating course: $e'),
                    ),
                  );
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

String generateUID() {
  var random = Random();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

  String uid = '';
  for (int i = 0; i < 20; i++) {
    uid += chars[random.nextInt(chars.length)];
  }

  return uid;
}
