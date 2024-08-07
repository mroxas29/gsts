import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as exc;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/DeviatedStudents.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/en-19.dart';
import 'package:sysadmindb/app/models/faculty.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/app/models/timeline.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/ui/dashboard_utils/Notifications/notification_button.dart';
import 'package:sysadmindb/ui/info_page/deviatedInfoPage.dart';
import 'package:sysadmindb/ui/forms/form.dart';
import 'package:sysadmindb/ui/info_page/studentInfoPage.dart';
import 'package:sysadmindb/ui/dashboard_utils/ineligible_list.dart';
import 'package:sysadmindb/ui/dashboard_utils/profileBox.dart';
import 'package:sysadmindb/ui/dashboard_utils/studentList.dart';
import 'package:sysadmindb/ui/dashboard_utils/deviatedList.dart';

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

Future<List<Student>> graduateStudents = convertToStudentList(users);

List<Course> foundCourse = courses;
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

List<Faculty> _getFilteredFacultyList(Course course) {
  return facultyList.where((faculty) {
    return faculty.history.any((h) => h.coursecode == course.coursecode);
  }).toList();
}

// Get faculty details for tooltip
String _getFacultyDetails(Faculty faculty) {
  return 'History Courses: ${faculty.history.join('\n')}';
}
// Suggest relevant faculty members if no faculty is assigned

// Suggest relevant faculty members if no faculty is assigned
String _getSuggestedFaculty(String selectedFaculty, Course course) {
  if (selectedFaculty == 'None Assigned') {
    return 'Suggested Faculty: ${_getFilteredFacultyList(course).map((faculty) => getFullname(faculty)).join('\n')}';
  }
  return 'Faculty with relevant history:\n${_getFilteredFacultyList(course).map((faculty) => getFullname(faculty)).join('\n')}';
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
List<StudentPOS> getDeviatedStudents() {
  String reformattedSYTerm = reformatSYandTerm(getCurrentSYandTerm());
  List<String> sytermParts = reformattedSYTerm.split(" ");

  for (String s in sytermParts) print(s);
  // Clear the deviatedStudentList to ensure it's empty before processing
  deviatedStudentList.clear();
  List<StudentPOS> posss = [];

  // Iterate through each StudentPOS in the studentPOSList
  for (StudentPOS pos in studentPOSList) {
    // List to hold deviated courses for the current studentPOS
    List<Course> deviatedCoursesList = [];

    // Iterate through each school year in the student's POS
    for (SchoolYear sy in pos.schoolYears) {
      // Check if the current school year matches sytermParts[0]
      if (sy.name == sytermParts[0]) {
        // Iterate through each term in the current school year
        for (Term term in sy.terms) {
          // Check if the current term matches sytermParts[1] and sytermParts[2]
          if (term.name == '${sytermParts[1]} ${sytermParts[2]}') {
            // Iterate through each enrolled course for the current studentPOS
            for (Course enrolledCourse in pos.enrolledCourses) {
              // Check if the enrolled course is not part of the term's courses
              if (!term.termcourses.any(
                  (course) => course.coursecode == enrolledCourse.coursecode)) {
                // Print the deviated course details for debugging
                print(
                    "${pos.displayname.toString()} ${sy.name} ${term.name} ${enrolledCourse.coursecode}");
                // Add the deviated course to the deviatedCoursesList
                deviatedCoursesList.add(enrolledCourse);
              }
            }
          }
        }
      }
    }

    // If there are any deviated courses for the current studentPOS, add it to the deviatedStudentList
    if (deviatedCoursesList.isNotEmpty) {
      deviatedStudentList.add(DeviatedStudent(
          studentPOS: pos, deviatedCourses: deviatedCoursesList));
    }
  }
  print(deviatedStudentList.length);
  // Return the list of StudentPOS (if needed)
  return posss;
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  String filter = '';
  late List<String> notifications = [];
  List<StudentPOS> deviated = getDeviatedStudents();

  List<Student> filteredStudents = studentList; // Declare filteredStudents
  int toShow = 4;
  bool showClicked = false;

  Widget buildRanking(List<StudentPOS> studentpos) {
    // Calculate occurrences of each course for the next term of the current school year

    Map<Course, int> occurrences = {};

    Future<void> generateExcel(
        List<MapEntry<Course, int>> uniqueCourses, int numofCourses) async {
      var excel = exc.Excel.createExcel(); // Create a new Excel file
      exc.Sheet sheet = excel['Sheet1']; // Create a new sheet
      exc.CellStyle cellStyle = exc.CellStyle(
          backgroundColorHex: exc.ExcelColor.fromHexString('#27AB46'),
          bold: true,
          fontColorHex: exc.ExcelColor.fromHexString('#FFFFFF'));

      // Define headers
      List<exc.TextCellValue> headers = [
        exc.TextCellValue('Course Code'),
        exc.TextCellValue('Course Name'),
        exc.TextCellValue('Offered To (Program)'),
        exc.TextCellValue('Faculty'),
        exc.TextCellValue('Days'),
        exc.TextCellValue('Room Number'),
        exc.TextCellValue('Setup'),
      ];

      // Add headers to the sheet
      sheet.appendRow(headers);

      // Add rows
      for (var course in uniqueCourses.take(numofCourses)) {
        // Create a formatted string for days and times
        String daysTimes = course.key.dayTimes.map((entry) {
          String day =
              entry['day']!; // Assuming 'day' key exists for day of the week
          String start = entry['start'] ?? ''; // Ensure start is a String
          String end = entry['end'] ?? ''; // Ensure end is a String
          return '$day: $start - $end';
        }).join(', ');

        sheet.appendRow([
          exc.TextCellValue(course.key.coursecode),
          exc.TextCellValue(course.key.coursename),
          exc.TextCellValue(course.key.program),
          exc.TextCellValue(course.key.facultyassigned == 'None assigned'
              ? ''
              : course.key.facultyassigned),
          exc.TextCellValue(daysTimes),
          exc.TextCellValue(course.key.roomNum),
          exc.TextCellValue(course.key.setup),
        ]);
      }
      sheet.getColumnAutoFit(4);
      // Save the file (handle potential permission issues)
      try {
        var bytes = excel.encode()!;
        final blob = html.Blob([
          bytes
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "courses offerings.xlsx")
          ..click();
        html.Url.revokeObjectUrl(url);
        print('Excel file generated and download triggered');
      } catch (error) {
        // Handle storage permission errors or other exceptions
        print('Error generating Excel file: $error');
      }
    }

    void showCourseSelectionDialog(
        BuildContext context, List<MapEntry<Course, int>> uniqueCourses) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          int selectedOption = uniqueCourses.length;
          int? customCount;

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text('Select Number of Courses'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RadioListTile<int>(
                      title: Text('Top 3'),
                      value: 3,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value ?? uniqueCourses.length;
                          customCount = null; // Reset custom count
                        });
                      },
                    ),
                    RadioListTile<int>(
                      title: Text('Top 5'),
                      value: 5,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value ?? uniqueCourses.length;
                          customCount = null; // Reset custom count
                        });
                      },
                    ),
                    RadioListTile<int>(
                      title: Text('All ${uniqueCourses.length} courses'),
                      value: uniqueCourses.length,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value ?? uniqueCourses.length;
                          customCount = null; // Reset custom count
                        });
                      },
                    ),
                    RadioListTile<int>(
                      title: Text('Custom'),
                      value: -1,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value ?? uniqueCourses.length;
                        });
                      },
                    ),
                    if (selectedOption == -1)
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Enter number of courses',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            customCount = int.tryParse(value);
                          });
                        },
                      ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      generateExcel(
                          uniqueCourses, customCount ?? selectedOption);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }

    void editCourseData(BuildContext context, Course course,
        List<Student> fulfillingStudentPOS, GlobalKey<FormState> formKey) {
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

      // Initialize the courseData with pre-filled values
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

      String selectedStatus = course.isactive ? 'true' : 'false';
      String selectedProgram = course.program;
      String selectedType = course.type;
      String selectedFaculty = course.facultyassigned;

      List<String> daysOfWeek = ['M', 'T', 'W', 'Th', 'F', 'S'];
      List<String> setups = ['Full Online', 'Hybrid', 'Full Onsite'];
      String selectedSetup = course.setup;
      Map<String, String?> selectedDaysWithTimes = {};
      String selectedHybridDay = course.onlineDay;
      TextEditingController courseCodeController =
          TextEditingController(text: course.coursecode);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
                title: Text('Edit Course'),
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
                                initialValue: course.coursename,
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
                                value: selectedFaculty.isNotEmpty
                                    ? selectedFaculty
                                    : 'None assigned',
                                items: [
                                  DropdownMenuItem<String>(
                                    value: 'None assigned',
                                    child: Text('None assigned'),
                                  ),
                                  ..._getFilteredFacultyList(course)
                                      .map((faculty) {
                                    return DropdownMenuItem<String>(
                                      value: getFullname(faculty),
                                      child: Tooltip(
                                        message: _getFacultyDetails(faculty),
                                        child: Text(
                                            '${faculty.displayname['firstname']} ${faculty.displayname['lastname']}'),
                                      ),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedFaculty = value!;
                                  });
                                },
                                onSaved: (value) {
                                  course.facultyassigned =
                                      (value == 'None assigned') ? '' : value!;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Assign to',
                                  suffixIcon: Tooltip(
                                    message: _getSuggestedFaculty(
                                        selectedFaculty, course),
                                    child: Icon(Icons.info),
                                  ),
                                ),
                              ),
                              // Units
                              TextFormField(
                                initialValue: course.units.toString(),
                                decoration: InputDecoration(labelText: 'Units'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the number of units';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  courseData.units =
                                      int.tryParse(value ?? '') ?? 0;
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
                                  setState(() {
                                    selectedProgram = value!;
                                  });
                                },
                                onSaved: (value) {
                                  courseData.program = value ?? '';
                                },
                                decoration:
                                    InputDecoration(labelText: 'Program'),
                              ),
                              // Status
                              DropdownButtonFormField<String>(
                                value: selectedStatus,
                                items: status.map((status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedStatus = value!;
                                  });
                                },
                                onSaved: (value) {
                                  courseData.isactive = value == 'true';
                                },
                                decoration:
                                    InputDecoration(labelText: 'Is Active'),
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
                                onChanged: (value) {
                                  setState(() {
                                    selectedType = value!;
                                  });
                                },
                                onSaved: (value) {
                                  courseData.type = value ?? '';
                                },
                                decoration:
                                    InputDecoration(labelText: 'Course Type'),
                              ),
                              // Section
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Section'),
                                validator: ((value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the section';
                                  }
                                  if (courses.any((course) =>
                                      course.section.toString().toUpperCase() ==
                                      value.toUpperCase())) {
                                    return "Course with course code ${courseCodeController.text} with section $value already exists";
                                  }
                                }),
                                onSaved: (value) {
                                  courseData.section = value ?? '';
                                },
                              ),
                              // Room Number
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Room Number'),
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 16.0, // Adding spacing between rows
                                children: daysOfWeek.map((day) {
                                  return GestureDetector(
                                    onTap: () async {
                                      if (selectedDaysWithTimes
                                          .containsKey(day)) {
                                        setState(() {
                                          selectedDaysWithTimes.remove(day);
                                        });
                                      } else {
                                        TimeOfDay? startTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (startTime != null) {
                                          TimeOfDay? endTime =
                                              await showTimePicker(
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
                                                selectedDaysWithTimes[day] !=
                                                        null
                                                    ? Border.all(
                                                        color: Colors.blue,
                                                        width: 2.0)
                                                    : null,
                                          ),
                                          child: Text(day),
                                        ),
                                        if (selectedDaysWithTimes
                                            .containsKey(day))
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              selectedDaysWithTimes[day]! +
                                                  (selectedSetup == 'Hybrid' &&
                                                          selectedHybridDay ==
                                                              day
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
                              // Setup
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
                              // Hybrid Day Selection
                              if (selectedSetup == 'Hybrid')
                                DropdownButtonFormField<String>(
                                  value: selectedHybridDay,
                                  items: selectedDaysWithTimes.entries
                                      .map((entry) {
                                    return DropdownMenuItem<String>(
                                      value: entry.key,
                                      child:
                                          Text('${entry.key}: ${entry.value}'),
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
                                      return 'Please select an online day';
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

                        try {
                          await FirebaseFirestore.instance
                              .collection('courses')
                              .doc(
                                  generateUID()) // Use existing course UID for updating
                              .set({
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
                            'syAndTerm': courseData.syAndTerm
                          });
                          Navigator.pop(context);

                          getCoursesFromFirestore();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Course updated'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          print('Error updating course: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating course: $e'),
                            ),
                          );
                        }
                      }
                    },
                    child: Text('Update'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    // Get the next SY and term
    List<String> sytermParts = getNextSYandTerm().split(" ");

    List<Course> generalCourses = [];
// Iterate through each StudentPOS
    for (int i = 0; i < studentpos.length; i++) {
      StudentPOS pos = studentpos[i];

      // Iterate through each schoolYear
      for (int j = 0; j < pos.schoolYears.length; j++) {
        SchoolYear sy = pos.schoolYears[j];

        // Check if the schoolYear matches the specified term
        if (sytermParts[0] == sy.name) {
          // Find the corresponding term
          Term term = sy.terms.firstWhere(
            (term) => term.name == '${sytermParts[1]} ${sytermParts[2]}',
          );
          for (int m = 0; m < term.termcourses.length; m++) {
            Course course = term.termcourses[m];

            generalCourses.add(course);
          }
        }
      }
    }

    List<MapEntry<Course, int>> uniqueCourses = [];

    for (Course course in generalCourses) {
      if (!uniqueCourses
          .any((entry) => entry.key.coursecode == course.coursecode)) {
        int occurrence = 0;
        for (Course c in generalCourses) {
          if (c.coursecode == course.coursecode) {
            occurrence += 1;
          }
        }

        if (occurrence > 0) {
          uniqueCourses.add(MapEntry(course, occurrence));
        }
      }
    }

// Sort uniqueCourses based on occurrence count
    uniqueCourses.sort((a, b) => b.value.compareTo(a.value));
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Course demand for ${getNextSYandTerm()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              TextButton(
                  onPressed: () {
                    showCourseSelectionDialog(context, uniqueCourses);
                  },
                  child: Text('Download course demand')),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Material(
                elevation: 4, // Adjust elevation as needed
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Color.fromARGB(255, 82, 138, 84),
                    padding: EdgeInsets.fromLTRB(
                        16, 16, 16, 16), // Increase padding as needed
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < toShow; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0), // Set margin as needed
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 34, 80,
                                  52), // Set your desired background color here
                              borderRadius: BorderRadius.circular(
                                  10.0), // Set border radius as needed
                            ),
                            padding: const EdgeInsets.all(12.0),

                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${uniqueCourses[i].value}',
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'students',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      uniqueCourses[i].key.coursecode,
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    Text(uniqueCourses[i].key.type,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.white))
                                  ],
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // Handle information icon tap here
                                    Course selectedCourse =
                                        uniqueCourses[i].key;
                                    List<StudentPOS> fulfillingStudentPOS = [];
                                    for (int i = 0;
                                        i < studentpos.length;
                                        i++) {
                                      StudentPOS pos = studentpos[i];
                                      for (int j = 0;
                                          j < pos.schoolYears.length;
                                          j++) {
                                        SchoolYear sy = pos.schoolYears[j];
                                        if (sytermParts[0] == sy.name) {
                                          for (int k = 0;
                                              k < sy.terms.length;
                                              k++) {
                                            Term term = sy.terms[k];
                                            if (term.name ==
                                                '${sytermParts[1]} ${sytermParts[2]}') {
                                              for (Course course
                                                  in term.termcourses) {
                                                if (course.coursecode ==
                                                    selectedCourse.coursecode) {
                                                  fulfillingStudentPOS.add(pos);
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    editCourseData(
                                        context,
                                        uniqueCourses[i].key,
                                        fulfillingStudentPOS,
                                        _formKey);
                                  },
                                ),
                              ],
                            ),
                          ),
                        Center(
                          child: TextButton(
                            onPressed: !showClicked
                                ? () {
                                    setState(() {
                                      toShow = uniqueCourses
                                          .length; // Assuming you have a variable named 'toShow' to keep track of how many more to show
                                      showClicked = true;
                                    });
                                  }
                                : () {
                                    setState(() {
                                      toShow =
                                          5; // Assuming you have a variable named 'toShow' to keep track of how many more to show
                                      showClicked = false;
                                    });
                                  },
                            child: !showClicked
                                ? Text(
                                    'Show ${uniqueCourses.length - toShow} more',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : Text(
                                    'minimize',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool totalStudentsClicked = false;
  bool newStudentsClicked = false;
  bool deviatedStudentsClicked = true;
  bool graduatingStudentsClicked = false;
  bool noEnrolledStudentsClicked = false;

  bool isGraduatingWithinTimeFrame(String degree, String idNumber) {
    // Extract the year from the ID number
    int idYear =
        int.parse(idNumber.substring(0, 3)) + 1900; // Convert to full year

    // Get the current year
    int currentYear = DateTime.now().year;

    // Calculate the maximum graduation year based on degree
    int maxGraduationYear;
    if (degree.toLowerCase().contains('doctorate')) {
      maxGraduationYear = idYear + 12;
    } else if (degree.toLowerCase().contains('masters')) {
      maxGraduationYear = idYear + 8;
    } else {
      // For other degrees, return true (no specific time frame)
      maxGraduationYear = idYear + 4;
    }

    // Check if the current year is within the time frame
    return currentYear <= maxGraduationYear;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (applicantList.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('New Applicants'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(
                        'There are new applicants for the upcoming term ${getNextSYandTerm()}\n'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (Student newStud in applicantList)
                            Text(
                              '${newStud.displayname['firstname']} ${newStud.displayname['lastname']}',
                            )
                        ],
                      ),
                    ),
                    Text(
                      'Click the "New Applicants" tile on the dashboard to show more info about each student.',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      notifications.add('Create the DeRF for new students');
                    });
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }

      if (fromLOAStudents.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Returning Students'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(
                        'There are returning students for ${getCurrentSYandTerm()}\n'),
                    Text(
                      '● - Ineligible to enroll',
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '● - Still Eligible',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (StudentPOS loa in fromLOAStudents)
                            Text(
                                '${loa.idnumber} - ${loa.displayname['firstname']} ${loa.displayname['lastname']}',
                                style: TextStyle(
                                  color: !isGraduatingWithinTimeFrame(
                                          loa.degree, loa.idnumber.toString())
                                      ? Colors.red
                                      : Colors.black,
                                )),
                        ]),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Click "Ineligible Students" tile in the dashboard to see all',
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      notifications.add(
                          'There are ${fromLOAStudents.length} students that came back from being LOA');
                    });
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });

    super.initState();
  }

  EN19Form? _retrievedForm;

  Future<void> retrieveEN19Form(String uid) async {
    EN19Form? form = await EN19Form.getFormFromFirestore(uid);

    setState(() {
      _retrievedForm = form;
    });
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
        actions: [
          NotificationButton(
            notificationCount: notifications.length,
            notifications: notifications,
          )
        ],
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
                            "Updates",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
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
                                  childAspectRatio: 1,
                                ),
                                itemCount: 6,
                                itemBuilder: (context, index) {
                                  // Dummy data for counts (replace with actual data)
                                  int totalStudents = studentList
                                      .length; // Total number of students

                                  int deviatedStudents = deviatedStudentList
                                      .length; // Number of deviated students

                                  return GestureDetector(
                                    onTap: () {
                                      if (index == 0) {
                                        print('Total Students Clicked');
                                        setState(() {
                                          totalStudentsClicked = true;
                                          newStudentsClicked = false;
                                          deviatedStudentsClicked = false;
                                          graduatingStudentsClicked = false;

                                          noEnrolledStudentsClicked = false;
                                        });
                                      }
                                      if (index == 1) {
                                        print('New Students Clicked');
                                        setState(() {
                                          totalStudentsClicked = false;
                                          newStudentsClicked = true;
                                          deviatedStudentsClicked = false;
                                          graduatingStudentsClicked = false;
                                          noEnrolledStudentsClicked = false;
                                        });
                                      }
                                      if (index == 2) {
                                        print('Deviated Students Clicked');
                                        setState(() {
                                          totalStudentsClicked = false;
                                          newStudentsClicked = false;
                                          deviatedStudentsClicked = true;
                                          graduatingStudentsClicked = false;
                                          noEnrolledStudentsClicked = false;
                                          getDeviatedStudents();
                                        });
                                      }
                                      if (index == 3) {
                                        print('Ineligible Students Clicked');
                                        setState(() {
                                          totalStudentsClicked = false;
                                          newStudentsClicked = false;
                                          deviatedStudentsClicked = false;
                                          graduatingStudentsClicked = false;
                                          noEnrolledStudentsClicked = false;
                                        });
                                      }
                                      if (index == 4) {
                                        print('Graduating Students Clicked');
                                        setState(() {
                                          totalStudentsClicked = false;
                                          newStudentsClicked = false;
                                          deviatedStudentsClicked = false;
                                          graduatingStudentsClicked = true;
                                          noEnrolledStudentsClicked = false;
                                        });
                                      }
                                      if (index == 5) {
                                        print('No Enrolled Students Clicked');
                                        setState(() {
                                          totalStudentsClicked = false;
                                          newStudentsClicked = false;
                                          deviatedStudentsClicked = false;
                                          graduatingStudentsClicked = false;
                                          noEnrolledStudentsClicked = true;
                                        });
                                      }
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: ProfileBox(
                                        totalStudents: totalStudents,
                                        newStudents: applicantList.length,
                                        deviatedStudents: deviatedStudents,
                                        ineligibleStudents:
                                            ineligibleStudentList.length,
                                        cardCount: index,
                                        graduatingStudents:
                                            graduatingStudentsList.length,
                                        noEnrolledStudents:
                                            noEnrolledStudents.length,
                                      ),
                                    ),
                                  );
                                },
                              )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    totalStudentsClicked
                        ? "Total Students (${getCurrentSYandTerm()})"
                        : newStudentsClicked
                            ? "New Applicants for (${getNextSYandTerm()})"
                            : deviatedStudentsClicked
                                ? "Deviated Students (${getCurrentSYandTerm()})"
                                : graduatingStudentsClicked
                                    ? ' Graduating Students'
                                    : noEnrolledStudentsClicked
                                        ? 'Students with no enrolled courses (${getCurrentSYandTerm()})'
                                        : "Ineligible Students (${getCurrentSYandTerm()})", // Empty string if none of the buttons are clicked
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  if (totalStudentsClicked)
                    Expanded(
                        child: ListView.builder(
                            itemCount: studentList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  await retrieveStudentPOS(
                                      studentList[index]);
                                
                                    await fetchStudentTimelines(studentList[index].uid);
                             
                                  late DeviatedStudent devStudent;
                                  await retrieveEN19Form(
                                      studentList[index].uid);
                                  bool isDeviated = false;
                                  for (DeviatedStudent student
                                      in deviatedStudentList) {
                                    if (student.studentPOS.idnumber ==
                                        studentList[index].idnumber) {
                                      devStudent = student;
                                      isDeviated = true;
                                    }
                                  }
                                  if (isDeviated) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DeviatedInfoPage(
                                          student: devStudent,
                                          studentpos: studentPOS,
                                          en19: _retrievedForm!!,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StudentInfoPage(
                                          student: studentList[index],
                                          studentpos: studentPOS,
                                          en19: _retrievedForm!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: StudentList(
                                    student: studentList[index],
                                  ),
                                ),
                              );
                            })),
                  if (newStudentsClicked)
                    Expanded(
                        child: applicantList.isNotEmpty
                            ? ListView.builder(
                                itemCount: applicantList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                        await fetchStudentTimelines(
                                          applicantList[index].uid);
                                      await retrieveStudentPOS(
                                          applicantList[index]);
                                      EN19Form? en19details =
                                          await EN19Form.getFormFromFirestore(
                                              applicantList[index].uid);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StudentInfoPage(
                                            student: applicantList[index],
                                            studentpos: studentPOS,
                                            en19: en19details!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: StudentList(
                                        student: applicantList[index],
                                      ),
                                    ),
                                  );
                                })
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'No new applicants',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                  if (noEnrolledStudentsClicked)
                    Expanded(
                        child: noEnrolledStudents.isNotEmpty
                            ? ListView.builder(
                                itemCount: noEnrolledStudents.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      await fetchStudentTimelines( noEnrolledStudents[index].uid);
                                      StudentPOS? clickedStudentPOS =
                                          await retrieveStudentPOS(
                                              noEnrolledStudents[index]);
                                      EN19Form? en19details =
                                          await EN19Form.getFormFromFirestore(
                                              noEnrolledStudents[index].uid);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StudentInfoPage(
                                            student: noEnrolledStudents[index],
                                            studentpos: clickedStudentPOS,
                                            en19: en19details!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: StudentList(
                                        student: noEnrolledStudents[index],
                                      ),
                                    ),
                                  );
                                })
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'No students with no enrolled courses',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                  if (deviatedStudentsClicked)
                    Expanded(
                        child: deviatedStudentList.isNotEmpty
                            ? ListView.builder(
                                itemCount: deviatedStudentList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      fetchStudentTimelines(    deviatedStudentList[index]
                                              .studentPOS
                                              .uid);
                                      await retrieveStudentPOS(
                                          deviatedStudentList[index]
                                              .studentPOS
                                              );
                                      EN19Form? en19details =
                                          await EN19Form.getFormFromFirestore(
                                              deviatedStudentList[index]
                                                  .studentPOS
                                                  .uid);
                                      for (Course c
                                          in deviatedStudentList[index]
                                              .deviatedCourses) {
                                        print('before:${c.coursecode}');
                                      }
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DeviatedInfoPage(
                                            student: deviatedStudentList[index],
                                            studentpos: studentPOS,
                                            en19: en19details!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: StudentTile(
                                        student: deviatedStudentList[index],
                                      ),
                                    ),
                                  );
                                })
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'No deviated Students',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                  if (!deviatedStudentsClicked &&
                      !newStudentsClicked &&
                      !totalStudentsClicked &&
                      !graduatingStudentsClicked &&
                      !noEnrolledStudentsClicked)
                    Expanded(
                        child: ineligibleStudentList.isNotEmpty
                            ? ListView.builder(
                                itemCount: ineligibleStudentList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                        await fetchStudentTimelines(
                                       ineligibleStudentList[index].uid);
                                      await retrieveStudentPOS(
                                          ineligibleStudentList[index]);
                                      EN19Form? en19details =
                                          await EN19Form.getFormFromFirestore(
                                              ineligibleStudentList[index].uid);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StudentInfoPage(
                                            student:
                                                ineligibleStudentList[index],
                                            studentpos: studentPOS,
                                            en19: en19details!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: IneligibleList(
                                        student: ineligibleStudentList[index],
                                      ),
                                    ),
                                  );
                                })
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'No ineligible Students',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                  if (graduatingStudentsClicked)
                    Expanded(
                        child: graduatingStudentsList.isNotEmpty
                            ? ListView.builder(
                                itemCount: graduatingStudentsList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      await fetchStudentTimelines(
                                             graduatingStudentsList[index].uid);
                                      await retrieveStudentPOS(
                                          graduatingStudentsList[index]);
                                      EN19Form? en19details =
                                          await EN19Form.getFormFromFirestore(
                                              graduatingStudentsList[index]
                                                  .uid);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StudentInfoPage(
                                            student:
                                                graduatingStudentsList[index],
                                            studentpos: studentPOS,
                                            en19: en19details!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: StudentList(
                                        student: graduatingStudentsList[index],
                                      ),
                                    ),
                                  );
                                })
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'No graduating Students',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
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
