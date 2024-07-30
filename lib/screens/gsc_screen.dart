import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as exc;
import 'package:side_navigation/side_navigation.dart';
import 'package:sysadmindb/api/email/invoice_service.dart';
import 'package:sysadmindb/api/calendar/test_calendar.dart';
import 'package:sysadmindb/api/email/test_gmail.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/DeviatedStudents.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/en-19.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/faculty.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/ui/dashboard_utils/studentList.dart';
import 'package:sysadmindb/ui/deRF_dialog.dart';
import 'package:sysadmindb/ui/defense_card.dart';
import 'package:sysadmindb/ui/defense_sched.dart';
import 'package:sysadmindb/ui/forms/addcourse.dart';
import 'package:sysadmindb/ui/forms/form.dart';
import 'package:sysadmindb/ui/dashboard/gsc_dash.dart';
import 'package:sysadmindb/ui/info_page/deviatedInfoPage.dart';
import 'package:sysadmindb/ui/info_page/studentInfoPage.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(
    MaterialApp(home: Gscscreen()),
  );
}

class Gscscreen extends StatefulWidget {
  const Gscscreen({Key? key}) : super(key: key);

  /*launchInbox(String gmail) async{
    const gmail = 'https://mail.google.com/a/dlsu.edu.ph';

    if (await launchInbox(gmail)) {
      await launchInbox(gmail);
    } else {
      throw 'Could not open $gmail';
    }
  }*/

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<Gscscreen> {
  final controller = TextEditingController();
  var collection = FirebaseFirestore.instance.collection('faculty');
  List<StudentPOS> foundPOS = [];
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
  StudentPOS? selectedPOS = studentPOSList[0];
  int? selectedPOSIndex = 0;
  int? selectedYearIndex = 0;
  int? selectedTermIndex = 0;
// Define a list to keep track of selected term indices
  List<int> selectedTermIndices = [];
  bool posEdited = false;
  final PdfInvoiceService service = PdfInvoiceService();

  /// The currently selected index of the bar
  int selectedIndex = 0;
  String selectedProgramFilter = 'All';
  String selectedVerdict = 'All';
  List<EN19Form> filteredDefenses = [];

  @override
  initState() {
    setState(() {
      foundCourse = courses;
      foundFaculty = facultyList;
      foundStudents = studentList;
      foundPOS = studentPOSList;
    });

    print("set state for found users");
    super.initState();
    filterDefenses();
    //getCourseDemandsFromFirestore();
  }

  void filterDefenses() {
    if (selectedProgramFilter == 'All') {
      filteredDefenses = allDefenseForms;
    } else {
      filteredDefenses = allDefenseForms
          .where((defense) => defense.program == selectedProgramFilter)
          .toList();
    }
  }

  void _editFacultyData(BuildContext context, Faculty faculty) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController firstNameController =
        TextEditingController(text: faculty.displayname['firstname']);
    TextEditingController lastNameController =
        TextEditingController(text: faculty.displayname['lastname']);
    TextEditingController emailController =
        TextEditingController(text: faculty.email);

    List<Course> selectedCourses = faculty.history;
    print(faculty.history);

    List<Course> suggestedCourses = courses;
    final controllerSugg = TextEditingController();
    bool alreadyAdded = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: AlertDialog(
              title: Text('Edit Faculty'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildEditableField(
                        'First Name', firstNameController, false),
                    _buildEditableField('Last Name', lastNameController, false),
                    _buildEditableField('Email', emailController, false),
                    Text('Applicable Courses'),
                    if (selectedCourses.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: selectedCourses.map((course) {
                            return Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18.0),
                                color: Color.fromARGB(255, 196, 194,
                                    194), // Gray background color
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(course.coursecode),
                                  SizedBox(width: 4.0),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedCourses.remove(course);
                                        });
                                      },
                                      child: Icon(Icons.clear),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    if (selectedCourses.isEmpty)
                      Text(
                        'No courses added',
                        style: TextStyle(color: Colors.grey),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Add an applicable course'),
                    SizedBox(
                        height: 75,
                        width: 500,
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: TextField(
                            controller: controllerSugg,
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: 'Enter course code/name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                )),
                            onChanged: (value) {
                              setState(() {
                                suggestedCourses =
                                    runApplicableCourseFilter(value);
                              });
                            },
                          ),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    if (alreadyAdded == true)
                      Text(
                        "The selected course has already been added",
                        style: TextStyle(color: Colors.red),
                      ),
                    SingleChildScrollView(
                      child: SizedBox(
                        height: 300,
                        width: 500,
                        child: ListView.builder(
                          itemCount: suggestedCourses.length,
                          itemBuilder: ((context, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (selectedCourses.any((course) =>
                                      course.coursecode ==
                                      suggestedCourses[index].coursecode)) {
                                    alreadyAdded = true;
                                  } else {
                                    alreadyAdded = false;
                                    selectedCourses
                                        .add(suggestedCourses[index]);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    "${suggestedCourses[index].coursecode}: ${suggestedCourses[index].coursename}"), // Display course name
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
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
                                Navigator.pop(
                                    context, false); // No, do not delete
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
                                isEqualTo:
                                    '${faculty.displayname['firstname']} ${faculty.displayname['lastname']}')
                            .get();

                        for (QueryDocumentSnapshot courseDoc
                            in courseSnapshot.docs) {
                          String courseId = courseDoc.id;

                          await FirebaseFirestore.instance
                              .collection('courses')
                              .doc(courseId)
                              .update({
                            'facultyassigned': 'None assigned'
                          }).then((_) {
                            print(
                                'Faculty assigned updated successfully for course: $courseId');
                          }).catchError((error) {
                            print(
                                'Error updating faculty assigned for course: $courseId, $error');
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
                      faculty.displayname['firstname'] =
                          firstNameController.text;
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
                        'history': selectedCourses
                            .map((course) => course.toMap())
                            .toList(),
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
            ),
          );
        });
      },
    );
  }

  void showAddFacultyForm(BuildContext context, GlobalKey<FormState> formKey) {
    print(facultyList.length);
    final FacultyData _facultyData = FacultyData();
    List<Course> selectedCourses = [];
    List<Course> suggestedCourses = courses;
    final controllerSugg = TextEditingController();
    bool alreadyAdded = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: Text('Add New Faculty'),
                content: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'First name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the first name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _facultyData.displayName['firstname'] = value ?? '';
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Last name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the last name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _facultyData.displayName['lastname'] = value ?? '';
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the email address';
                          }
                          if (facultyList
                              .any((faculty) => faculty.email == value)) {
                            return "Faculty with email $value already exists";
                          }
                          // Add email validation if needed
                          return null;
                        },
                        onSaved: (value) {
                          _facultyData.email = value ?? '';
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Applicable Courses'),
                      if (selectedCourses.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: selectedCourses.map((course) {
                              return Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18.0),
                                  color: Color.fromARGB(255, 196, 194,
                                      194), // Gray background color
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(course.coursecode),
                                    SizedBox(width: 4.0),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedCourses.remove(course);
                                          });
                                        },
                                        child: Icon(Icons.clear),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      if (selectedCourses.isEmpty)
                        Text(
                          'No courses added',
                          style: TextStyle(color: Colors.grey),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Add an applicable courses'),
                      SizedBox(
                          height: 75,
                          width: 500,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: TextField(
                              controller: controllerSugg,
                              decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search),
                                  hintText: 'Enter course code/name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                  )),
                              onChanged: (value) {
                                setState(() {
                                  suggestedCourses =
                                      runApplicableCourseFilter(value);
                                });
                              },
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      if (alreadyAdded == true)
                        Text(
                          "The selected course has already been added",
                          style: TextStyle(color: Colors.red),
                        ),
                      SingleChildScrollView(
                        child: SizedBox(
                          height: 300,
                          width: 500,
                          child: ListView.builder(
                            itemCount: suggestedCourses.length,
                            itemBuilder: ((context, index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (selectedCourses.any((course) =>
                                        course.coursecode ==
                                        suggestedCourses[index].coursecode)) {
                                      alreadyAdded = true;
                                    } else {
                                      alreadyAdded = false;
                                      selectedCourses
                                          .add(suggestedCourses[index]);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "${suggestedCourses[index].coursecode}: ${suggestedCourses[index].coursename}"), // Display course name
                                ),
                              );
                            }),
                          ),
                        ),
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
                              .collection('faculty')
                              .doc(uid)
                              .set({
                            'displayname': {
                              'firstname':
                                  _facultyData.displayName['firstname']!,
                              'lastname': _facultyData.displayName['lastname']!,
                            },
                            'email': _facultyData.email,
                            'uid': uid,
                            'history': selectedCourses
                                .map((course) => course.toMap())
                                .toList(),
                          }).then((value) {
                            // Get the newly generated document ID (UID)

                            // Use the UID as needed (if necessary)
                            print('New faculty member UID: $uid');
                          });

                          Navigator.pop(context);

                          // If you want to refresh the faculty list after adding a new member

                          getFacultyList();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Faculty member added'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          print('Error adding faculty member: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error adding faculty member: $e'),
                            ),
                          );
                        }
                      }
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String buildCourseHistoryMessage(
      Faculty faculty, List<Faculty> suggestedFaculty) {
    if (suggestedFaculty.isEmpty) {
      return 'No suggested faculty.';
    } else if (faculty.displayname['firstname']!.contains('None') &&
        faculty.displayname['lastname']!.contains('assigned')) {
      final messageBuffer = StringBuffer('Suggested faculty:\n');
      for (int i = 1; i < suggestedFaculty.length; i++) {
        Faculty faculty = suggestedFaculty[i];
        messageBuffer.write(
            ' - ${faculty.displayname['firstname']} ${faculty.displayname['lastname']}\n');
      }
      return messageBuffer.toString();
    } else {
      final messageBuffer = StringBuffer('Course history:\n');
      for (final course in faculty.history) {
        messageBuffer.write(' - ${course.coursecode}: ${course.coursename}\n');
      }
      return messageBuffer.toString();
    }
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

  Widget studentEnrolledList(Course course) {
    List<Student> enrolledStudents = [];
    for (Student s in studentList) {
      if (s.enrolledCourses.any((c) =>
              c.coursecode == course.coursecode &&
              c.section == course.section) ||
          s.pastCourses.any((c) =>
              c.coursecode == course.coursecode &&
              c.section == course.section)) {
        enrolledStudents.add(s);
      }
    }

    return SizedBox(
      height: 400,
      width: 300,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (Student student in enrolledStudents)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                          "${capitalizeFirstLetter(student.displayname['firstname']!)} ${capitalizeFirstLetter(student.displayname['lastname']!)}"),
                    ),
                    SizedBox(width: 8), // Add spacing between text and button
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          bool isStudentDeviated = false;
                          DeviatedStudent? devStudent;

                          // Fetch EN19Form details
                          EN19Form? en19details =
                              await EN19Form.getFormFromFirestore(student.uid);
                          if (en19details == null) {
                            print(
                                'EN19Form details not found for student UID: ${student.uid}');
                          }

                          // Find deviated student
                          for (DeviatedStudent devstudent
                              in deviatedStudentList) {
                            if (devstudent.studentPOS.idnumber ==
                                student.idnumber) {
                              devStudent = devstudent;
                              isStudentDeviated = true;
                              break; // Stop searching once found
                            }
                          }

                          // Fetch student POS details
                          await retrieveStudentPOS(student.uid);

                          // Use setState to update the widget state
                          setState(() {});

                          // Navigate to the appropriate page
                          if (isStudentDeviated && devStudent != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeviatedInfoPage(
                                  student: devStudent!,
                                  studentpos: studentPOS,
                                  en19: en19details,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentInfoPage(
                                  student: student,
                                  studentpos: studentPOS,
                                  en19: en19details,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          // Handle exceptions
                          print('Error navigating to student profile: $e');
                        }
                      },
                      child: Text("View profile"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredVerdictTable() {
    List<EN19Form> filteredForms = selectedVerdict == 'All'
        ? allDefenseForms
        : allDefenseForms.where((form) {
            if (selectedVerdict == 'No Verdict') {
              return form.verdict == 'No verdict'; // Match the Firestore value
            }
            return form.verdict == selectedVerdict;
          }).toList();

    filteredForms.sort((a, b) => _sortComparison(a, b));

    return filteredForms.isEmpty
        ? SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedVerdict,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Text(
                          'Verdict',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Defense Schedule',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'College',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'ID Number',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Student',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Enrollment Stage',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Title',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Lead Panelist',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Actions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: filteredForms.map((form) {
                      bool isConcluded = _isDefenseConcluded(
                          form.defenseDate, form.defenseTime);
                      String verdictText = form.verdict == 'No verdict'
                          ? (isConcluded
                              ? "${form.verdict} (Defense Concluded)"
                              : "${form.verdict} (Not Concluded)")
                          : form.verdict;

                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: _getVerdictBackgroundColor(
                                    form.verdict,
                                    form.verdict == 'No verdict'
                                        ? isConcluded
                                        : false),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                verdictText,
                                style: TextStyle(
                                  color: _getVerdictTextColor(
                                      form.verdict,
                                      form.verdict == 'No verdict'
                                          ? isConcluded
                                          : false),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(
                              "${form.defenseDate} (${form.defenseTime})")),
                          DataCell(Text(form.program)),
                          DataCell(Text(form.idNumber)),
                          DataCell(Text("${form.firstName} ${form.lastName}")),
                          DataCell(Text(form.enrollmentStage)),
                          DataCell(Text(form.mainTitle)),
                          DataCell(Text(form.leadPanel)),
                          DataCell(
                            TextButton(
                              onPressed: () {
                                showDefenseDetailsDialog(context, form);
                              },
                              child: Text(
                                'View Details',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
  }

  int _verdictOrder(String verdict, bool concluded) {
    switch (verdict) {
      case 'Redefense':
        return 1;
      case 'Failed':
        return 2;
      case 'Passed':
        return 3;
      case 'No verdict':
        return concluded ? 5 : 4;
      default:
        return 6;
    }
  }

  bool _isDefenseConcluded(String defenseDate, String defenseTime) {
    try {
      DateTime now = DateTime.now();

      List<String> dateParts = defenseDate.split(' ');
      String monthString = dateParts[0];
      int day = int.parse(dateParts[1].replaceAll(',', ''));
      int year = int.parse(dateParts[2]);

      Map<String, int> months = {
        'January': 1,
        'February': 2,
        'March': 3,
        'April': 4,
        'May': 5,
        'June': 6,
        'July': 7,
        'August': 8,
        'September': 9,
        'October': 10,
        'November': 11,
        'December': 12,
      };

      int month = months[monthString] ?? 1;

      List<String> timeParts = defenseTime.split(' ');
      List<String> hourMinParts = timeParts[0].split(':');
      int hour = int.parse(hourMinParts[0]);
      int minute = int.parse(hourMinParts[1]);

      if (timeParts[1] == 'PM' && hour != 12) {
        hour += 12;
      } else if (timeParts[1] == 'AM' && hour == 12) {
        hour = 0;
      }

      DateTime defenseDateTime = DateTime(year, month, day, hour, minute);

      return defenseDateTime.isBefore(now);
    } catch (e) {
      print("Error parsing date or time: $e");
      return false;
    }
  }

  Color _getVerdictTextColor(String verdict, bool isConcluded) {
    if (verdict == 'No verdict') {
      return isConcluded ? Colors.blueGrey : Colors.black;
    }

    switch (verdict) {
      case 'Passed':
        return Colors.green;
      case 'Failed':
        return Colors.red;
      case 'Redefense':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getVerdictBackgroundColor(String verdict, bool isConcluded) {
    if (verdict == 'No verdict') {
      return isConcluded
          ? Colors.grey.withOpacity(0.3)
          : Colors.black.withOpacity(0.1);
    }

    switch (verdict) {
      case 'Passed':
        return Colors.green.withOpacity(0.1);
      case 'Failed':
        return Colors.red.withOpacity(0.1);
      case 'Redefense':
        return Colors.orange.withOpacity(0.3);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  int _sortComparison(EN19Form a, EN19Form b) {
    bool aConcluded = _isDefenseConcluded(a.defenseDate, a.defenseTime);
    bool bConcluded = _isDefenseConcluded(b.defenseDate, b.defenseTime);

    int verdictOrderA = _verdictOrder(a.verdict, aConcluded);
    int verdictOrderB = _verdictOrder(b.verdict, bConcluded);

    if (verdictOrderA != verdictOrderB) {
      return verdictOrderA.compareTo(verdictOrderB);
    }

    return 0; // Additional sorting logic if needed
  }

  void showCourseDetails(
      BuildContext context, Course course, GlobalKey<FormState> formKey) {
    List<String> status = ['true', 'false'];
    List<String> programs = ['MIT/MSIT', 'MIT', 'MSIT'];
    List<String> types = [
      'Bridging/Remedial Courses',
      'Foundation Courses',
      'Elective Courses',
      'Capstone',
      'Exam Course',
      'Specialized Courses',
      'Thesis Course'
    ];
    List<String> setups = ['Full Online', 'Hybrid', 'Full Onsite'];
    List<String> daysOfWeek = ['M', 'T', 'W', 'Th', 'F', 'S'];

    String selectedStatus = course.isactive.toString();
    String selectedProgram = course.program;
    String selectedType = course.type;
    String selectedSetup = course.setup;
    String selectedHybridDay = course.onlineDay;

    String selectedFaculty = course.facultyassigned.isNotEmpty
        ? course.facultyassigned
        : (facultyList.isNotEmpty
            ? "${facultyList[0].displayname['firstname']!} ${facultyList[0].displayname['lastname']!}"
            : '');

    // Initialize selectedDaysWithTimes from course.dayTimes
    Map<String, String> selectedDaysWithTimes = {
      for (var dayTime in course.dayTimes)
        dayTime['day']!: "${dayTime['start']} - ${dayTime['end']}"
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
              title: Text('Course Details'),
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
                              initialValue: course.coursecode,
                              decoration:
                                  InputDecoration(labelText: 'Course code'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the course code';
                                }
                                if (courses.any((c) =>
                                    c.coursecode.toUpperCase() ==
                                        value.toUpperCase() &&
                                    c.uid != course.uid)) {
                                  return "Course with course code: $value already exists";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                course.coursecode = value ?? '';
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
                                course.coursename = value ?? '';
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

                            // Course Units
                            TextFormField(
                              initialValue: course.units.toString(),
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
                                course.units = int.parse(value ?? '');
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
                                course.program = value ?? '';
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
                                setState(() {
                                  selectedStatus = value!;
                                });
                              },
                              onSaved: (value) {
                                course.isactive = value == 'true';
                              },
                              decoration:
                                  InputDecoration(labelText: 'Is active?'),
                            ),
                            // Course Type
                            DropdownButtonFormField<String>(
                              value: selectedType,
                              items: types.map((type) {
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
                              onSaved: (type) {
                                course.type = type!;
                              },
                              decoration:
                                  InputDecoration(labelText: 'Course Type'),
                            ),
                            // Section
                            TextFormField(
                              initialValue: course.section,
                              decoration: InputDecoration(labelText: 'Section'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the section';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                course.section = value ?? '';
                              },
                            ),
                            // Room Number
                            TextFormField(
                              initialValue: course.roomNum,
                              decoration:
                                  InputDecoration(labelText: 'Room Number'),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty &&
                                        selectedSetup != 'Full Online') {
                                  return 'Please enter the room number';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                course.roomNum = value ?? '';
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
                                              selectedDaysWithTimes[day] != null
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
                                course.setup = value ?? '';
                              },
                              decoration: InputDecoration(labelText: 'Setup'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a setup';
                                }
                                return null;
                              },
                            ),
                            if (selectedSetup == 'Hybrid')
                              DropdownButtonFormField<String>(
                                value: selectedHybridDay,
                                items:
                                    selectedDaysWithTimes.entries.map((entry) {
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
                                    return 'Please select a hybrid day';
                                  }
                                  return null;
                                },
                              ),
                            SizedBox(height: 16.0),
                            Row(
                              children: [
                                Text('Students:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Spacer(),
                                ElevatedButton(
                                  onPressed: () async {
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['xlsx', 'xls'],
                                    );

                                    if (result != null) {
                                      PlatformFile file = result.files.first;

                                      var bytes = file.bytes;
                                      if (bytes != null) {
                                        var excel =
                                            exc.Excel.decodeBytes(bytes);

                                        List<Map<String, dynamic>> parsedData =
                                            [];
                                        for (var table in excel.tables.keys) {
                                          var sheet = excel.tables[table];
                                          if (sheet != null) {
                                            bool isFirstRow = true;
                                            for (var row in sheet.rows) {
                                              if (isFirstRow) {
                                                isFirstRow = false;
                                                continue;
                                              }

                                              var number = row[0]?.value;
                                              var idNumber = row[1]?.value;
                                              var name = row[2]?.value;
                                              var grade = row[3]?.value;

                                              double? gradeToDouble;
                                              if (grade != null) {
                                                try {
                                                  gradeToDouble = double.parse(
                                                      grade.toString());
                                                } catch (e) {
                                                  print(
                                                      'Error parsing grade: $e');
                                                  gradeToDouble = null;
                                                }
                                              }

                                              parsedData.add({
                                                'number': number,
                                                'idNumber': idNumber,
                                                'name': name,
                                                'grade': gradeToDouble,
                                              });
                                            }
                                          }
                                        }

                                        // Show confirmation dialog
                                        if (parsedData.isNotEmpty) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Verify Grades'),
                                                content: Container(
                                                  width:
                                                      400, // Set a fixed width for the dialog
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize
                                                        .min, // Make sure the column size is minimal
                                                    children: [
                                                      Expanded(
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              parsedData.length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            var data =
                                                                parsedData[
                                                                    index];
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4.0),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                      '${data['name']} (${data['idNumber']})',
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis, // Handle long text gracefully
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          16), // Add spacing between text and input field
                                                                  SizedBox(
                                                                    width:
                                                                        80, // Set a fixed width for the TextField
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          TextEditingController(
                                                                        text: data['grade']?.toString() ??
                                                                            '',
                                                                      ),
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      onChanged:
                                                                          (value) {
                                                                        data['grade'] =
                                                                            double.tryParse(value);
                                                                      },
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Grade',
                                                                        isDense:
                                                                            true, // Reduce the padding inside the TextField
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Confirm'),
                                                    onPressed: () {
                                                      setState(() {
                                                        for (var data
                                                            in parsedData) {
                                                          var idNumber =
                                                              data['idNumber'];
                                                          var grade =
                                                              data['grade'];

                                                          if (grade != null) {
                                                            PastCourse past =
                                                                PastCourse(
                                                              coursecode: course
                                                                  .coursecode,
                                                              coursename: course
                                                                  .coursename,
                                                              facultyassigned:
                                                                  course
                                                                      .facultyassigned,
                                                              uid: course.uid,
                                                              units:
                                                                  course.units,
                                                              dayTimes: course
                                                                  .dayTimes,
                                                              syAndTerm: course
                                                                  .syAndTerm,
                                                              section: course
                                                                  .section,
                                                              setup:
                                                                  course.setup,
                                                              program: course
                                                                  .program,
                                                              grade: grade,
                                                              roomNum: course
                                                                  .roomNum,
                                                              onlineDay: course
                                                                  .onlineDay,
                                                              type: course.type,
                                                              isactive: course
                                                                  .isactive,
                                                              numstudents: course
                                                                  .numstudents,
                                                            );

                                                            studentList
                                                                .firstWhere((student) =>
                                                                    student
                                                                        .idnumber
                                                                        .toString() ==
                                                                    idNumber
                                                                        .toString())
                                                                .pastCourses
                                                                .add(past);

                                                            studentList
                                                                .firstWhere((student) =>
                                                                    student
                                                                        .idnumber
                                                                        .toString() ==
                                                                    idNumber
                                                                        .toString())
                                                                .enrolledCourses
                                                                .removeWhere((enrolledCourse) =>
                                                                    enrolledCourse
                                                                            .coursecode ==
                                                                        past
                                                                            .coursecode &&
                                                                    enrolledCourse
                                                                            .section ==
                                                                        past.section);

                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(studentList
                                                                    .firstWhere((student) =>
                                                                        student
                                                                            .idnumber
                                                                            .toString() ==
                                                                        idNumber
                                                                            .toString())
                                                                    .uid)
                                                                .update(studentList
                                                                    .firstWhere((student) =>
                                                                        student
                                                                            .idnumber
                                                                            .toString() ==
                                                                        idNumber
                                                                            .toString())
                                                                    .toJson());
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'studentpos')
                                                                .doc(studentPOSList
                                                                    .firstWhere((student) =>
                                                                        student
                                                                            .idnumber
                                                                            .toString() ==
                                                                        idNumber
                                                                            .toString())
                                                                    .uid)
                                                                .update(studentList
                                                                    .firstWhere((student) =>
                                                                        student
                                                                            .idnumber
                                                                            .toString() ==
                                                                        idNumber
                                                                            .toString())
                                                                    .toJson());
                                                          }
                                                        }
                                                      });
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Grades updated'),
                                                          duration: Duration(
                                                              seconds: 2),
                                                        ),
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      }
                                    }
                                  },
                                  child: Text("Upload grades"),
                                ),
                              ],
                            ),
                            studentEnrolledList(course)
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
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      try {
                        await FirebaseFirestore.instance
                            .collection('courses')
                            .doc(course.uid)
                            .update({
                          'coursecode': course.coursecode.toUpperCase(),
                          'coursename': course.coursename,
                          'facultyassigned': selectedFaculty,
                          'units': course.units,
                          'isactive': course.isactive,
                          'type': selectedType,
                          'program': selectedProgram,
                          'dayTimes': selectedDaysWithTimes.map((day, time) =>
                              MapEntry(day, {
                                'start': time!.split(' - ')[0],
                                'end': time.split(' - ')[1]
                              })),
                          'section': course.section,
                          'setup': course.setup,
                          'onlineDay': selectedSetup == 'Full Online'
                              ? 'Full Online'
                              : selectedSetup == 'Full Onsite'
                                  ? 'Full Onsite'
                                  : selectedHybridDay,
                          'roomNum': course.roomNum,
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
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, bool hasStudents) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      enabled: !hasStudents,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  String getFullname(Faculty faculty) {
    return '${faculty.displayname['firstname']} ${faculty.displayname['lastname']}';
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

  List<Course> runApplicableCourseFilter(String query) {
    List<Course> suggestedCourses;
    if (query.isEmpty) {
      return courses;
    } else {
      query = query
          .toLowerCase(); // Convert query to lowercase for case-insensitive comparison

      suggestedCourses = courses
          .where((course) =>
              course.coursecode.toLowerCase().contains(query) ||
              course.coursename.toLowerCase().contains(query) ||
              course.numstudents.toString().contains(query) ||
              course.facultyassigned.toString().contains(query) ||
              (query == "active" && course.isactive) ||
              (query == "inactive" && !course.isactive))
          .toList();
      return suggestedCourses;
    }
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

  void runPOSFilter(
    String query,
    StudentPOS? selectedPOS,
  ) {
    List<StudentPOS> results = [];
    if (query.isEmpty) {
      results = studentPOSList;
    } else {
      results = studentPOSList.where((studentPOS) {
        final queryParts = query.toLowerCase().split(' ');
        final firstname =
            studentPOS.displayname['firstname'].toString().toLowerCase();
        final lastname =
            studentPOS.displayname['lastname'].toString().toLowerCase();

        return (queryParts.every((part) =>
                firstname.contains(part) || lastname.contains(part)) ||
            studentPOS.idnumber
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            studentPOS.email
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            studentPOS.degree
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            studentPOS.status
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            studentPOS.acceptanceTerm
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()));
      }).toList();
    }
    setState(() {
      foundPOS = results; // Update the POS with search results

      selectedPOS = foundPOS[0];
      selectedPOSIndex = 0;
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
              student.status.toLowerCase().contains(query.toLowerCase()) ||
              student.degree.toLowerCase().contains(query.toLowerCase()) ||
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

  void changeScreen(int index) async {
    if (index == 3) {
      String url = 'https://calendar.google.com/a/dlsu.edu.ph';
      if (await canLaunch(url)) {
        launch(url, forceSafariVC: false, forceWebView: false);
      } else {
        throw 'Could not launch $url';
      }
    }

    if (index == 4) {
      String url = 'https://mail.google.com/a/dlsu.edu.ph';
      if (await canLaunch(url)) {
        launch(url, forceSafariVC: false, forceWebView: false);
      } else {
        throw 'Could not launch $url';
      }
    }

    setState(() {
      selectedIndex = index;
    });
  }

  Future<List<int>> _readDocumentData() async {
    // Open a file picker dialog to allow the user to choose a file
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      // Read the selected file
      Uint8List bytes = file.bytes!;
      return bytes;
    } else {
      // User canceled the file picker dialog
      return []; // Return an empty list
    }
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

  Future<void> launchPDF(String path) async {
    final url = Uri.parse('assets/$path');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void showAddStudentsDialog(BuildContext context) {
    Course? selectedCourse;
    String pastedData = '';
    TextEditingController searchController = TextEditingController();
    List<Course> filteredCourses = courses;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Class List for Course'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Course',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredCourses = courses
                              .where((course) =>
                                  course.coursecode
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  course.coursename
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  course.section
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    DropdownButtonFormField<Course>(
                      value: selectedCourse,
                      items: filteredCourses.map((course) {
                        return DropdownMenuItem<Course>(
                          value: course,
                          child: Text(
                              '${course.coursecode}: ${course.coursename} | ${course.section}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCourse = value;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Select Course'),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      maxLines: 10,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Paste Table Data Here',
                        alignLabelWithHint: true,
                      ),
                      onChanged: (value) {
                        pastedData = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedCourse == null || pastedData.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Please select a course and paste the table data.'),
                        ),
                      );
                      return;
                    }

                    List<String> studentIds =
                        extractStudentIdsFromTable(pastedData);
                    await addEnrolledStudents(selectedCourse!, studentIds);
                    Navigator.pop(context);
                  },
                  child: Text('Add Students'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> extractStudentIdsFromTable(String tableData) {
    List<String> studentIds = [];
    RegExp regExp = RegExp(r'<TR><TD>(\d+)<\/TD>');
    Iterable<Match> matches = regExp.allMatches(tableData);

    for (var match in matches) {
      studentIds.add(match.group(1)!);
    }

    return studentIds;
  }

  Future<void> addEnrolledStudents(
      Course selectedCourse, List<String> students) async {
    late EnrolledCourseData enrolledCourse;
    enrolledCourse = EnrolledCourseData(
      roomNum: selectedCourse.roomNum,
      setup: selectedCourse.setup,
      uid: selectedCourse.uid,
      syAndTerm: selectedCourse.syAndTerm,
      dayTimes: selectedCourse.dayTimes,
      section: selectedCourse.section,
      coursecode: selectedCourse.coursecode,
      coursename: selectedCourse.coursename,
      isactive: selectedCourse.isactive,
      facultyassigned: selectedCourse.facultyassigned,
      numstudents: students.length,
      units: selectedCourse.units,
      type: selectedCourse.type,
      program: selectedCourse.program,
      onlineDay: selectedCourse.onlineDay,
    );
    StudentPOS pos;
    for (Student s in studentList) {
      pos = studentPOSList.firstWhere((pos) => pos.idnumber == s.idnumber);
      for (String studentId in students) {
        if (studentId
            .toLowerCase()
            .contains(s.idnumber.toString().toLowerCase())) {
          print(s.idnumber);
          if (!s.enrolledCourses.any(
              (course) => course.coursecode == selectedCourse.coursecode)) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(s.uid)
                .update({
              'enrolledCourses':
                  FieldValue.arrayUnion([enrolledCourse.toJson()]),
            });
            await FirebaseFirestore.instance
                .collection('studentpos')
                .doc(s.uid)
                .update({
              'enrolledCourses':
                  FieldValue.arrayUnion([enrolledCourse.toJson()]),
            });
            await FirebaseFirestore.instance
                .collection('courses')
                .doc(selectedCourse.uid)
                .update({
              'numstudents': FieldValue.increment(1),
            });

            setState(() {
              s.enrolledCourses.add(enrolledCourse);
              pos.enrolledCourses.add(enrolledCourse);
            });
          }
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Enrolled students for ${selectedCourse.coursecode}: ${selectedCourse.coursename} updated!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<Course> recommendedRemedialCourses = [];
  List<Course> recommendedPriorityCourses = [];

  // FOR CALENDAR

  TimeOfDay? tryParseTime(String timeString) {
    if (timeString == "No time set") {
      return null;
    }

    try {
      // Split the timeString into hours and minutes
      List<String> parts = timeString.split(':');
      int hours = int.parse(parts[0]);
      int minutes =
          int.parse(parts[1].split(' ')[0]); // Extract minutes without AM/PM

      // Convert 12-hour format to 24-hour format
      if (timeString.contains('PM') && hours < 12) {
        hours += 12;
      } else if (timeString.contains('AM') && hours == 12) {
        hours = 0;
      }

      // Create and return the TimeOfDay object
      return TimeOfDay(hour: hours, minute: minutes);
    } catch (e) {
      print("Error parsing time: $e");
      return null;
    }
  }

  DateTime? tryParseDate(String dateString) {
    if (dateString == "No date set") {
      return null;
    }
    try {
      // Try parsing with your expected date format (adjust if needed)
      return DateFormat('yyyy-MM-dd')
          .parse(dateString); // Assuming YYYY-MM-DD format
    } catch (e) {
      print("Error parsing date: $e");
      return null;
    }
  }

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  // Function to capitalize the first letter of a string
  String capitalizeFirstLetter(String text) {
    return text.replaceFirst(RegExp(r'^[a-z]'), text[0].toUpperCase());
  }

  DateTime currentDate = DateTime.now();
  void showDefenseDetailsDialog(BuildContext context, EN19Form defense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController dateController = TextEditingController(
          text: defense.defenseDate != "No date set"
              ? defense.defenseDate
              : "No date set",
        );
        TimeOfDay selectedTime = defense.defenseTime != "No time set"
            ? tryParseTime(defense.defenseTime) ?? TimeOfDay.now()
            : TimeOfDay.now();

        // Controllers for the lead panel and panel members
        final TextEditingController leadPanelController =
            TextEditingController(text: defense.leadPanel);
        final List<TextEditingController> panelMemberControllers =
            List.generate(4, (index) {
          return TextEditingController(
            text: defense.panelMembers[index],
          );
        });

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: getRandomColor(),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Defense details for ${capitalizeFirstLetter(defense.firstName)} ${capitalizeFirstLetter(defense.lastName)}',
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      child: Text('See student profile'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Student? student = studentList.firstWhere((student) =>
                            student.idnumber.toString() == defense.idNumber);
                        late DeviatedStudent devStudent;
                        bool isStudentDeviated = false;
                        for (DeviatedStudent devstudent
                            in deviatedStudentList) {
                          if (devstudent.studentPOS.idnumber ==
                              student.idnumber) {
                            devStudent = devstudent;
                            isStudentDeviated = true;
                          }
                        }

                        if (isStudentDeviated) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviatedInfoPage(
                                student: devStudent,
                                studentpos: studentPOS,
                                en19: defense,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentInfoPage(
                                student: student,
                                studentpos: studentPOS,
                                en19: defense,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: defense.defenseDate != "No date set"
                                  ? tryParseDate(defense.defenseDate) ??
                                      DateTime.now()
                                  : DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dateController.text = DateFormat('MMMM d, yyyy')
                                    .format(pickedDate);
                                defense.defenseDate = DateFormat('MMMM d, yyyy')
                                    .format(pickedDate);
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                defense.defenseDate != "No date set"
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: Text(
                            defense.defenseDate != "No date set"
                                ? dateController.text
                                : 'No date set',
                            style: TextStyle(
                              color: defense.defenseDate != "No date set"
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedTime = pickedTime;
                                defense.defenseTime =
                                    pickedTime.format(context);
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                defense.defenseTime != "No time set"
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: Text(
                            defense.defenseTime == 'No time set'
                                ? 'No time set'
                                : selectedTime.format(context),
                            style: TextStyle(
                              color: defense.defenseTime != "No time set"
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Verdict:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(width: 5),
                        DropdownButton<String>(
                          value: defense.verdict,
                          onChanged: (String? newValue) {
                            setState(() {
                              defense.verdict = newValue!;
                            });
                          },
                          items: ['No verdict', 'Passed', 'Failed', 'Redefense']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'ID Number:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Text(defense.idNumber),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Enrollment Stage:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Text(defense.enrollmentStage),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Title:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Text(defense.mainTitle),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Adviser:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Text(defense.adviserName),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Defense Files:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      String fileName =
                                          '${defense.idNumber}/Defense Forms/EN-18DefenseForm_${defense.idNumber}.pdf';
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
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('File does not exist'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.file_download),
                                      SizedBox(
                                          width:
                                              8), // Add some space between the icon and the text
                                      Text('Download EN-18 Defense Form'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () async {
                                String fileName =
                                    '${defense.idNumber}/Defense Forms/Official_Receipt_${defense.lastName}_${defense.firstName}.pdf';
                                try {
                                  final imageUrl = await FirebaseStorage
                                      .instance
                                      .ref()
                                      .child(fileName)
                                      .getDownloadURL();
                                  if (await canLaunch(imageUrl.toString())) {
                                    await launch(imageUrl.toString());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to download file'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('File does not exist'),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Download official receipt',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: leadPanelController,
                            decoration: InputDecoration(
                              labelText: 'Lead Panel',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Panel Members:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        for (int i = 0; i < 4; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: TextField(
                              controller: panelMemberControllers[i],
                              decoration: InputDecoration(
                                  labelText: 'Panel Member ${i + 1}'),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Panel Report:'),
                        SizedBox(width: 5),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () async {
                                try {
                                  String fileName =
                                      '${defense.idNumber}/Defense Forms/Form-R_23_${defense.idNumber}.pdf';
                                  final imageUrl = await FirebaseStorage
                                      .instance
                                      .ref()
                                      .child(fileName)
                                      .getDownloadURL();
                                  if (await canLaunch(imageUrl.toString())) {
                                    await launch(imageUrl.toString());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to download file'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('File does not exist'),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.file_download),
                                  SizedBox(
                                      width:
                                          8), // Add some space between the icon and the text
                                  Text('Download Panel Report'),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Evaluation Form:'),
                        SizedBox(width: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  try {
                                    String fileName =
                                        '${defense.idNumber}/Defense Forms/Eval_Form_${defense.lastName}_${defense.firstName}.docx';
                                    final imageUrl = await FirebaseStorage
                                        .instance
                                        .ref()
                                        .child(fileName)
                                        .getDownloadURL();
                                    if (await canLaunch(imageUrl.toString())) {
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
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('File does not exist'),
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.file_download),
                                    Text(
                                      'Download Evaluation Form',
                                    ),
                                  ],
                                )),
                            SizedBox(
                                width:
                                    8), // Add some space between the icons and the text
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () async {
                    setState(() {
                      defense.leadPanel = leadPanelController.text;
                      defense.panelMembers = panelMemberControllers
                          .map((controller) =>
                              controller.text.isEmpty ? " " : controller.text)
                          .toList();
                      if (defense.verdict == 'Redefense') ;
                      {
                        defense.defenseDate = "No date set";

                        defense.defenseTime = "No time set";
                      }
                    });
                    String uid = studentList
                        .firstWhere((student) =>
                            student.idnumber.toString() == defense.idNumber)
                        .uid;
                    try {
                      await FirebaseFirestore.instance
                          .collection('defenseInformation')
                          .doc(uid)
                          .set(defense
                              .toMap()); // Assuming `defense.toMap()` correctly converts the object to a map for Firestore
                      print('Form saved successfully');
                    } catch (e) {
                      print('Error saving form: $e');
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<EN19Form> getPastDefenseSchedules(List<EN19Form> allDefenseForms) {
    // Define the date and time format used in defenseDate and defenseTime
    final DateFormat dateFormat = DateFormat('MMMM d, yyyy');
    final DateFormat timeFormat = DateFormat('hh:mm a');

    DateTime parseDefenseDateTime(String date, String time) {
      final DateTime parsedDate = dateFormat.parse(date);
      final DateTime parsedTime = timeFormat.parse(time);

      return DateTime(parsedDate.year, parsedDate.month, parsedDate.day,
          parsedTime.hour, parsedTime.minute);
    }

    final DateTime now = DateTime.now();

    List<EN19Form> pastSchedules = allDefenseForms.where((defense) {
      if (defense.defenseDate == 'No date set' ||
          defense.defenseTime == 'No time set') {
        return false;
      }

      final DateTime defenseDateTime =
          parseDefenseDateTime(defense.defenseDate, defense.defenseTime);
      return defenseDateTime.isBefore(now);
    }).toList();

    return pastSchedules;
  }

  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    bool is12chars = is12charslong(newPasswordController.text);
    bool isAtMost64chars = isatmost64chars(newPasswordController.text);
    bool hasSpecial = hasSpecialChar(newPasswordController.text);
    bool hasNum = hasNumber(newPasswordController.text);
    bool isMatching =
        confirmNewPasswordController.text == newPasswordController.text;
    bool curpassinc = false;

    int toDoCount = allDefenseForms
        .where((defense) =>
            defense.panelMembers.isNotEmpty ||
            defense.defenseDate != 'No date set')
        .length;

    List<String> scheduledDates = allDefenseForms
        .map((defense) => defense.defenseDate)
        .where((date) => date != "No date set")
        .toSet()
        .toList();

    List<EN19Form> noScheduleDates = allDefenseForms
        .where((defense) =>
            defense.defenseDate == 'No date set' ||
            defense.defenseTime == 'No time set')
        .toList();

    List<EN19Form> hasSchedDates = allDefenseForms
        .where((defense) =>
            defense.defenseDate != 'No date set' &&
            defense.defenseTime != 'No time set')
        .toList();

    List<EN19Form> pastDefenses = getPastDefenseSchedules(hasSchedDates);
// Remove pastDefenses from hasSchedDates
    hasSchedDates.removeWhere((defense) => pastDefenses.contains(defense));

    /// Views to display
    List<Widget> views = [
      DesktopScaffold(),

      //COURSES SCREEN
      MaterialApp(
        home: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Program Management',
                    style: TextStyle(color: Colors.white)),
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
              ),
              body: TabBarView(
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 25),
                                  child: Text("Courses",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Filter by: ",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      value: selectedFilter,
                                      items: <String>[
                                        'All',
                                        'Offered',
                                        'Not offered'
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedFilter = newValue!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            Tooltip(
                              message: 'Upload class list',
                              child: TextButton(
                                  onPressed: () async {
                                    showAddStudentsDialog(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.all(20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25))),
                                  child: Icon(Icons.upload)),
                            ),
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
                                  itemCount: foundCourse.length,
                                  itemBuilder: (context, index) {
                                    bool showCourse = false;
                                    if (selectedFilter == 'All') {
                                      showCourse = true;
                                    } else if (selectedFilter == 'Offered' &&
                                        foundCourse[index].isactive) {
                                      showCourse = true;
                                    } else if (selectedFilter ==
                                            'Not offered' &&
                                        !foundCourse[index].isactive) {
                                      showCourse = true;
                                    }

                                    return showCourse
                                        ? InkWell(
                                            onTap: () {
                                              enrolledStudent.clear();

                                              showCourseDetails(context,
                                                  foundCourse[index], _formKey);
                                            },
                                            child: Card(
                                              key: ValueKey(foundCourse[index]),
                                              color: Colors.white,
                                              elevation: 4,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 5),
                                              child: ListTile(
                                                title: Text(
                                                  "${foundCourse[index].coursecode}: ${foundCourse[index].section}",
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
                                                      "${foundCourse[index].facultyassigned}\n${foundCourse[index].coursename}",
                                                    ),
                                                    Text(
                                                      foundCourse[index]
                                                              .isactive
                                                          ? 'Offered'
                                                          : 'Not-Offered',
                                                      style: TextStyle(
                                                        color:
                                                            foundCourse[index]
                                                                    .isactive
                                                                ? Colors.green
                                                                : Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                trailing: Text(
                                                  "Students: ${foundCourse[index].numstudents.toString()}",
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(); // Return an empty container if the course shouldn't be shown
                                  },
                                )))
                      ]),

                  //FACULTY TAB
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

                  //STUDENT POS TAB
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 25),
                                  child: Text("Student's Program of Study",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      )),
                                )
                              ],
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              onPressed: posEdited
                                  ? () async {
                                      setState(() {
                                        posEdited = false;
                                        getDeviatedStudents();
                                      });

                                      final FirebaseFirestore firestore =
                                          FirebaseFirestore.instance;
                                      Map<String, dynamic> studentPosData =
                                          selectedPOS!.toJson();

                                      try {
                                        await firestore
                                            .collection('studentpos')
                                            .doc(selectedPOS!.uid)
                                            .set(studentPosData);

                                        // Update local data after saving changes
                                        await retrieveAllPOS();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Program of Study updated'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );

                                        // Update the widget state synchronously if needed
                                        setState(() {
                                          foundPOS = studentPOSList;
                                        });
                                      } catch (error) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Failed to update Program of Study'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                  : null, // Disable the button when no course is added
                              child: Text("Save changes"),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            TextButton(
                              onPressed: () async {
                                String? hostname =
                                    html.window.location.hostname;
                                int port = html.window.location.port.isEmpty
                                    ? 80
                                    : int.parse(html.window.location.port);

                                // html.window.open( 'http://localhost:$port/assets/pdfs/RoxasResume.pdf','_blank');
                                final data =
                                    await service.createInvoice(selectedPOS!);
                                service.savePdfFile(
                                    "POS_${selectedPOS!.idnumber}.pdf", data);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.download_rounded,
                                      color: Colors.blue), // Download icon
                                  SizedBox(
                                      width:
                                          8), // Add spacing between icon and text
                                  Text(
                                    'Download POS in PDF',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
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
                                          prefixIcon: const Icon(Icons.search),
                                          hintText: ' ',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Colors.blue),
                                          )),
                                      onChanged: (value) =>
                                          runPOSFilter(value, selectedPOS!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () async {
                            final String selectedStudentUid = selectedPOS!
                                .uid; // Assuming selectedPOS has a studentUid property
                            Student? selectedStudent;
                            // Iterate through the list of students to find the one with the matching UID
                            for (Student student in studentList) {
                              if (student.uid == selectedStudentUid) {
                                selectedStudent = student;

                                break; // Exit the loop once a matching student is found
                              }
                            }

                            await retrieveStudentPOS(selectedStudent!.uid);
                            EN19Form? en19details =
                                await EN19Form.getFormFromFirestore(
                                    selectedStudent.uid);
                            late DeviatedStudent devStudent;
                            bool isDeviated = false;
                            for (DeviatedStudent student
                                in deviatedStudentList) {
                              if (student.studentPOS.idnumber ==
                                  selectedStudent.idnumber) {
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
                                    en19: en19details!,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentInfoPage(
                                    student: selectedStudent!,
                                    studentpos: studentPOS,
                                    en19: en19details!,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'See student profile',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        SingleChildScrollView(
                          physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Students",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    physics: BouncingScrollPhysics(
                                        parent:
                                            AlwaysScrollableScrollPhysics()),
                                    child: SizedBox(
                                      width:
                                          MediaQuery.sizeOf(context).height / 3,
                                      height:
                                          MediaQuery.sizeOf(context).height /
                                              1.5,
                                      child: ListView.builder(
                                        itemCount: foundPOS.length,
                                        itemBuilder: (context, index) =>
                                            InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (posEdited == true) {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          'Unsaved changes'),
                                                      content: Text(
                                                          'You have unsaved changes from this POS'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context, true);
                                                          },
                                                          child:
                                                              Text('Go back'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                selectedPOS = foundPOS[index];

                                                selectedPOSIndex =
                                                    index; // Select the tapped item

                                                recommendedRemedialCourses
                                                    .clear();
                                                recommendedPriorityCourses
                                                    .clear();
                                              }
                                            });
                                          },
                                          child: Card(
                                            key: ValueKey(foundPOS[index]),
                                            surfaceTintColor:
                                                Colors.transparent,
                                            color: selectedPOSIndex == index
                                                ? Color.fromARGB(255, 225, 233,
                                                    231) // Selected color
                                                : Color.fromARGB(255, 255, 251,
                                                    254), // Unselected color
                                            // Adjust elevation
                                            elevation: 0,
                                            margin: EdgeInsets.only(
                                                bottom: 10, left: 5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                              ),
                                            ),

                                            child: ListTile(
                                              title: Text(
                                                "${foundPOS[index].displayname['firstname']} ${foundPOS[index].displayname['lastname']} (${foundPOS[index].idnumber})",
                                                style: TextStyle(
                                                  color:
                                                      selectedPOSIndex == index
                                                          ? Colors.black
                                                          : Colors.grey,
                                                  fontSize: 18.0,
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
                                                    "Degree: ${foundPOS[index].degree}",
                                                    style: TextStyle(
                                                      color: selectedPOSIndex ==
                                                              index
                                                          ? Colors.black
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    foundPOS[index].status,
                                                    style: TextStyle(
                                                      color: selectedPOSIndex ==
                                                              index
                                                          ? Colors.black
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "School Years",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  SingleChildScrollView(
                                    physics: BouncingScrollPhysics(
                                        parent:
                                            AlwaysScrollableScrollPhysics()),
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 6,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              1.5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: selectedPOSIndex == 0
                                                  ? Radius.circular(0)
                                                  : Radius.circular(10),
                                              bottomLeft: Radius.circular(10)),
                                          color: Color.fromARGB(255, 225, 233,
                                              231), // Background color for the column
                                        ),
                                        child: ListView.builder(
                                          itemCount:
                                              selectedPOS!.schoolYears.length,
                                          itemBuilder: (context, index) =>
                                              InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedYearIndex = index;
                                              });
                                            },
                                            child: Card(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                ),
                                              ),
                                              color: selectedYearIndex == index
                                                  ? Color.fromARGB(
                                                      255,
                                                      213,
                                                      220,
                                                      218) // Selected color
                                                  : Color.fromARGB(
                                                      255,
                                                      225,
                                                      233,
                                                      231), // Unselected color (transparent)
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              margin: EdgeInsets.only(
                                                  bottom: 10, left: 5, top: 10),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                                child: ListTile(
                                                  title: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          selectedPOS!
                                                              .schoolYears[
                                                                  index]
                                                              .name,
                                                          style: TextStyle(
                                                            fontSize: 20.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: selectedYearIndex ==
                                                                    index
                                                                ? Colors.black
                                                                : Colors
                                                                    .grey, // Text color
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Terms",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    physics: BouncingScrollPhysics(
                                        parent:
                                            AlwaysScrollableScrollPhysics()),
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 6,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              1.5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            color: Color.fromARGB(255, 213, 220,
                                                218) // Background color for the column
                                            ),
                                        child: ListView.builder(
                                          itemCount: selectedPOS!
                                              .schoolYears[selectedYearIndex!]
                                              .terms
                                              .length,
                                          itemBuilder: (context, index) =>
                                              InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (selectedTermIndices
                                                    .contains(index)) {
                                                  // If the term is already selected, remove it from the list
                                                  selectedTermIndices
                                                      .remove(index);
                                                  selectedTermIndices.sort();
                                                } else {
                                                  // If the term is not selected, add it to the list
                                                  selectedTermIndices
                                                      .add(index);
                                                  selectedTermIndices.sort();
                                                }
                                              });
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                              ),
                                              color: selectedTermIndices
                                                      .contains(index)
                                                  ? Color.fromARGB(
                                                      158,
                                                      129,
                                                      221,
                                                      169) // Selected color
                                                  : Colors.transparent,
                                              elevation: 0,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: ListTile(
                                                  title: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          selectedPOS!
                                                              .schoolYears[
                                                                  selectedYearIndex!]
                                                              .terms[index]
                                                              .name,
                                                          style: TextStyle(
                                                            fontSize: 20.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: selectedTermIndices
                                                                    .contains(
                                                                        index)
                                                                ? Colors.black
                                                                : Colors
                                                                    .grey, // Text color
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "No. of Courses: ${selectedPOS!.schoolYears[selectedYearIndex!].terms[index].termcourses.length.toString()}",
                                                        style: TextStyle(
                                                          color: selectedTermIndices
                                                                  .contains(
                                                                      index)
                                                              ? Colors.black
                                                              : Colors
                                                                  .grey, // Text color
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Program of Study",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  SingleChildScrollView(
                                    physics: BouncingScrollPhysics(
                                        parent:
                                            AlwaysScrollableScrollPhysics()),
                                    // Allow horizontal scrolling
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ...selectedTermIndices
                                              .toList()
                                              .map<Widget>((termIndex) {
                                            final term = selectedPOS!
                                                .schoolYears[selectedYearIndex!]
                                                .terms[termIndex];
                                            return Card(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              elevation: 4.0,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                  child: Theme(
                                                    data: ThemeData(
                                                      dividerColor: Colors
                                                          .transparent, // Remove border
                                                    ),
                                                    child: ExpansionTile(
                                                      title: Text(
                                                        term.name,
                                                        style: TextStyle(
                                                            fontSize: 14.0),
                                                      ),
                                                      children: [
                                                        ...term.termcourses
                                                            .map((course) {
                                                          return ListTile(
                                                            title: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    course
                                                                        .coursecode,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12.0),
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    // Implement logic to delete the course
                                                                    // For example:
                                                                    setState(
                                                                        () {
                                                                      term.termcourses
                                                                          .remove(
                                                                              course);
                                                                      // Remove courses from recommendedCourses based on selectedCourse
                                                                      recommendedRemedialCourses.removeWhere((toremove) =>
                                                                          toremove
                                                                              .coursecode ==
                                                                          course
                                                                              .coursecode);

                                                                      recommendedPriorityCourses.removeWhere((toremove) =>
                                                                          toremove
                                                                              .coursecode ==
                                                                          course
                                                                              .coursecode);
                                                                      posEdited =
                                                                          true;
                                                                    });
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            subtitle: Text(
                                                              course.coursename,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        SizedBox(
                                                            height:
                                                                8.0), // Add space between course tiles
                                                        AddCourseButton(
                                                          onCourseAdded:
                                                              (course) {
                                                            setState(() {
                                                              term.termcourses
                                                                  .add(course);
                                                              posEdited = true;
                                                              countCourseOccurrences(
                                                                  studentPOSList,
                                                                  course
                                                                      .coursecode,
                                                                  term.name);
                                                              if (course.type ==
                                                                  'Bridging/Remedial Courses') {
                                                                recommendedRemedialCourses
                                                                    .add(
                                                                        course);
                                                              } else {
                                                                recommendedPriorityCourses
                                                                    .add(
                                                                        course);
                                                              }
                                                            });
                                                          },
                                                          allCourses: courses,
                                                          selectedStudentPOS:
                                                              selectedPOS!,
                                                          syAndTerm:
                                                              "${selectedPOS!.schoolYears[selectedYearIndex!].name} ${term.name}",
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ]),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )),
      ),

      //DEFENSES SCREEN
      DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  text: 'Defense Monitoring',
                ),
                Tab(
                  text: 'Defense Scheduling',
                ),
              ],
            ),
          ),
          body: TabBarView(children: [
            Scaffold(
              appBar: AppBar(
                title: Text('Defense Monitoring Table Sheet'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Filter',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 8),
                        DropdownButton<String>(
                          value: selectedVerdict,
                          onChanged: (newValue) {
                            setState(() {
                              selectedVerdict = newValue!;
                            });
                          },
                          items: [
                            'All',
                            'No Verdict',
                            'Redefense',
                            'Passed',
                            'Failed'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0), // Add padding from the top
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                        ),
                        child:
                            _buildFilteredVerdictTable(), // Use filtered table
                      ),
                    ),
                  ),
                  // You can add more widgets here if needed, such as additional filters or information.
                ],
              ),
            ),
            Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: Row(
                  children: [
                    Expanded(
                      child: DefenseSchedulesAppBar(
                        currentStudentIndex: hasSchedDates.length,
                        totalStudents: allDefenseForms.length,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        value: selectedProgramFilter,
                        onChanged: (newValue) {
                          setState(() {
                            selectedProgramFilter = newValue!;
                            filterDefenses();
                          });
                        },
                        items: ['All', 'MIT', 'MSIT']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              body: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'To-Schedule',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (EN19Form defense in noScheduleDates.where(
                                    (sched) =>
                                        selectedProgramFilter == 'All' ||
                                        sched.program == selectedProgramFilter))
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        showDefenseDetailsDialog(
                                            context, defense);
                                      },
                                      child: DefenseCard(
                                        defense: defense,
                                        cardColor:
                                            Color.fromARGB(255, 53, 98, 134),
                                      ),
                                    ),
                                  ),
                                if (noScheduleDates
                                    .where((sched) => (selectedProgramFilter ==
                                            'All' ||
                                        sched.program == selectedProgramFilter))
                                    .isEmpty)
                                  Text('No new defenses to set dates'),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Defenses Scheduled',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (EN19Form defense
                                    in hasSchedDates.where((sched) {
                                  if (selectedProgramFilter == 'All' ||
                                      sched.program == selectedProgramFilter) {
                                    return true;
                                  }
                                  return false;
                                }))
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        showDefenseDetailsDialog(
                                            context, defense);
                                      },
                                      child: DefenseCard(
                                        defense: defense,
                                        cardColor:
                                            Color.fromARGB(255, 7, 104, 28),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Finished Defenses',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: pastDefenses.where((defense) {
                                  if (selectedProgramFilter == 'All') {
                                    return true;
                                  } else if (selectedProgramFilter ==
                                      defense.program) {
                                    return true;
                                  }
                                  return false;
                                }).map((defense) {
                                  return MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        showDefenseDetailsDialog(
                                            context, defense);
                                      },
                                      child: DefenseCard(
                                        defense: defense,
                                        cardColor:

                                            // Handle parse error if needed
                                            Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ),
                                  );
                                }).toList()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1, // Takes 1/3 of the screen
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Color.fromARGB(52, 88, 88, 88),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                itemCount: scheduledDates.length,
                                itemBuilder: (context, index) {
                                  String dateString = scheduledDates[index];
                                  DateTime date = dateString == "No date set"
                                      ? DateTime.now()
                                      : DateFormat("MMMM d, yyyy")
                                          .parse(dateString);

                                  String formattedDate =
                                      dateString == "No date set"
                                          ? dateString
                                          : DateFormat('d MMMM').format(date);

                                  // Filter defense forms for the current date
                                  List<EN19Form> defensesForDate =
                                      filteredDefenses
                                          .where((defense) =>
                                              defense.defenseDate == dateString)
                                          .toList();

                                  defensesForDate.sort((a, b) {
                                    // Handle cases where time is not specified
                                    if (a.defenseTime ==
                                        "No defense time set") {
                                      return 1;
                                    }
                                    if (b.defenseTime ==
                                        "No defense time set") {
                                      return -1;
                                    }

                                    // Parse and compare time strings
                                    try {
                                      // Parse time strings to DateTime objects
                                      DateTime timeA = DateFormat('hh:mm a')
                                          .parse(a.defenseTime);
                                      DateTime timeB = DateFormat('hh:mm a')
                                          .parse(b.defenseTime);

                                      // Compare the parsed DateTime objects
                                      return timeA.compareTo(
                                          timeB); // Compare in ascending order
                                    } catch (e) {
                                      print("Error parsing time: $e");
                                      return 0; // Default to no change in sorting order
                                    }
                                  });
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors
                                                  .grey, // Grey color for the date
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        // Sorted defenses for the current date by time
                                        ...defensesForDate.map((defense) =>
                                            InkWell(
                                              onTap: () {
                                                // Handle click event
                                                showDefenseDetailsDialog(
                                                    context, defense);
                                                print(
                                                    'Clicked ${defense.program}');
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            defense.defenseTime ??
                                                                'No time specified',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Container(
                                                            width:
                                                                3, // Increased width for the separator line
                                                            height: 20,
                                                            color: Color((Random().nextDouble() *
                                                                            0xFFFFFF)
                                                                        .toInt() <<
                                                                    0)
                                                                .withOpacity(
                                                                    1.0),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                defense.program,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey, // Grey color for the degree
                                                                  fontSize:
                                                                      12, // Adjusted font size
                                                                ),
                                                              ),
                                                              Text(
                                                                '${defense.firstName} ${defense.lastName}',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                  ],
                                                ),
                                              ),
                                            )),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),

      //DEADLINES SCREEN

      // CALENDAR PAGE || Following guide: https://www.youtube.com/watch?v=6Gxa-v7Zh7I&ab_channel=AIwithFlutter
      CalendarSF(),

      // INBOX PAGE (Redirect to User's Currently Logged in DLSU Email via link of https://mail.google.com/a/dlsu.edu.ph)
      /*Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Text("Inbox")]),*/
      Text("Opening Gmail in new tab"),
      SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 560,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
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
                      physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
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
                SideNavigationBarItem(icon: Icons.schedule, label: 'Defenses'),
                SideNavigationBarItem(
                    icon: Icons.timer_sharp, label: 'Deadlines'),
                SideNavigationBarItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'Calendar',
                ),
                SideNavigationBarItem(
                  icon: Icons.email,
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
