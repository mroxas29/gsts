import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/faculty.dart';

final controller = TextEditingController();

class UserData {
  Map<String, String> displayname = {};
  String email = '';
  int idnumber = 0;
  String role = '';
  String password = '';
  String type = '';
  String degree = '';
}

class FacultyData {
  String uid = generateUID();
  String email = '';
  Map<String, String> displayName = {};
}

Future<bool> doesCourseCodeExist(String courseCode) async {
  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('courses')
      .where('coursecode', isEqualTo: courseCode)
      .get();
  final document = snapshot.docs.first;
  print(document.data());

  return snapshot.docs.isNotEmpty;
}

String getFullname(Faculty faculty) {
  return '${faculty.displayname['firstname']} ${faculty.displayname['lastname']}';
}

void showAddCourseForm(BuildContext context, GlobalKey<FormState> formKey) {
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

  final Course courseData = Course(
      dayTimes: [], // Initialize with empty map
      uid: 'blank',
      setup: '',
      coursecode: 'Select a course',
      coursename: '',
      facultyassigned: '',
      units: 0,
      numstudents: 0,
      isactive: false,
      type: '',
      program: '',
      syAndTerm: '',
      section: '', // Initialize section
      roomNum: '',
      onlineDay: '');

  String selectedStatus = status[0];
  String selectedProgram = programs[0];
  String selectedType = type[0];
  String selectedFaculty = facultyList.isNotEmpty
      ? "${facultyList[0].displayname['firstname']!} ${facultyList[0].displayname['lastname']!}"
      : '';

  List<String> daysOfWeek = ['M', 'T', 'W', 'Th', 'F', 'S'];
  List<String> setups = ['Full Online', 'Hybrid', 'Full Onsite'];
  String selectedSetup = setups[0];
  Map<String, String?> selectedDaysWithTimes = {};
  String selectedHybridDay = 'No online day';
  TextEditingController courseCodeController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
            title: Text('Add New Course'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Course Code
                          TextFormField(
                            controller: courseCodeController,
                            decoration:
                                InputDecoration(labelText: 'Course code'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the course code';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              courseData.coursecode = value ?? '';
                            },
                          ),
                          // Course Name
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Course name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the course name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              courseData.coursename = value ?? '';
                            },
                          ),
                          // Faculty Assignment
                          DropdownButtonFormField<String>(
                            value: selectedFaculty,
                            items: facultyList.map((faculty) {
                              return DropdownMenuItem<String>(
                                value: getFullname(faculty),
                                child: Text(
                                    '${faculty.displayname['firstname']} ${faculty.displayname['lastname']}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              selectedFaculty = value!;
                            },
                            onSaved: (value) {
                              courseData.facultyassigned = value ?? '';
                            },
                            decoration: InputDecoration(labelText: 'Assign to'),
                          ),
                          // Course Units
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Course units'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the course units';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              courseData.units = int.parse(value ?? '');
                            },
                          ),
                          // Program
                          DropdownButtonFormField<String>(
                            value: selectedProgram,
                            items: programs.map((program) {
                              return DropdownMenuItem<String>(
                                value: program,
                                child: Text(program),
                              );
                            }).toList(),
                            onChanged: (value) {
                              selectedProgram = value!;
                            },
                            onSaved: (value) {
                              courseData.program = value ?? '';
                            },
                            decoration: InputDecoration(labelText: 'Program'),
                          ),
                          // Status
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            items: status.map((role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (value) {
                              selectedStatus = value!;
                            },
                            onSaved: (value) {
                              courseData.isactive = bool.parse(value ?? '');
                            },
                            decoration:
                                InputDecoration(labelText: 'Is active?'),
                          ),
                          // Course Type
                          DropdownButtonFormField<String>(
                            value: selectedType,
                            items: type.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (type) {
                              selectedType = type!;
                            },
                            onSaved: (type) {
                              courseData.type = type!;
                            },
                            decoration:
                                InputDecoration(labelText: 'Course Type'),
                          ),
                          // Section
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Section'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the section';
                              }
                              if (courses.any((course) =>
                                  course.section.toString().toUpperCase() ==
                                  value.toUpperCase())) {
                                return "Course with course code ${courseCodeController.text} with section $value already exists";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              courseData.section = value ?? '';
                            },
                          ),
                          // Room Number
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Room Number'),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty &&
                                      selectedSetup != 'Full-Online') {
                                return 'Please enter the room number';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              courseData.roomNum = value ?? '';
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Days of the Week
                          SizedBox(height: 16.0),
                          Text('Select Days:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 16.0, // Adding spacing between rows
                            children: daysOfWeek.map((day) {
                              return GestureDetector(
                                onTap: () async {
                                  if (selectedDaysWithTimes.containsKey(day)) {
                                    setState(() {
                                      selectedDaysWithTimes.remove(day);
                                    });
                                  } else {
                                    TimeOfDay? startTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (startTime != null) {
                                      TimeOfDay? endTime = await showTimePicker(
                                        context: context,
                                        initialTime: startTime.replacing(
                                          hour: (startTime.hour + 1) %
                                              24, // Handle hour overflow
                                          minute: (startTime.minute + 90) %
                                              60, // Add 90 minutes
                                        ),
                                      );
                                      if (endTime != null) {
                                        setState(() {
                                          selectedDaysWithTimes[day] =
                                              '${startTime.format(context)} - ${endTime.format(context)}';
                                        });
                                      }
                                    }
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 12.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border:
                                            selectedDaysWithTimes[day] != null
                                                ? Border.all(
                                                    color: Colors.blue,
                                                    width: 2.0)
                                                : null,
                                      ),
                                      child: Text(day),
                                    ),
                                    if (selectedDaysWithTimes.containsKey(day))
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          selectedDaysWithTimes[day]! +
                                              (selectedHybridDay == day
                                                  ? ' (Online day)'
                                                  : ''),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedSetup,
                            items: setups.map((setup) {
                              return DropdownMenuItem<String>(
                                value: setup,
                                child: Text(setup),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSetup = value!;
                              });
                            },
                            onSaved: (value) {
                              courseData.setup = value ?? '';
                            },
                            decoration: InputDecoration(labelText: 'Setup'),
                          ),
                          if (selectedSetup == 'Hybrid')
                            DropdownButtonFormField<String>(
                              value: selectedHybridDay,
                              items: selectedDaysWithTimes.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text('${entry.key}: ${entry.value}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedHybridDay = value!;
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: 'Select online day'),
                              validator: (value) {
                                if (selectedSetup == 'Hybrid' &&
                                    value == null) {
                                  return 'Please select online day';
                                }
                                return null;
                              },
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
                        'uid': uid,
                        'coursecode': courseData.coursecode.toUpperCase(),
                        'coursename': courseData.coursename,
                        'facultyassigned': selectedFaculty,
                        'units': courseData.units,
                        'isactive': courseData.isactive,
                        'numstudents': 0,
                        'type': selectedType,
                        'program': selectedProgram,
                        'dayTimes': selectedDaysWithTimes.map((day, time) =>
                            MapEntry(day, {
                              'start': time!.split(' - ')[0],
                              'end': time.split(' - ')[1]
                            })),
                        'section': courseData.section,
                        'setup': courseData.setup,
                        'onlineDay': selectedSetup == 'Full Online'
                            ? 'Full Online'
                            : selectedSetup == 'Full Onsite'
                                ? 'Full Onsite'
                                : selectedHybridDay,
                        'roomNum': courseData.roomNum,
                        'syAndTerm': getNextSYandTerm()
                      });
                      Navigator.pop(context);

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
                child: Text('Add'),
              ),
            ],
          );
        },
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
