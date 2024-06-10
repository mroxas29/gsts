import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/ui/deRF_dialog.dart';
import 'package:sysadmindb/ui/forms/addcourse.dart';
import 'package:sysadmindb/ui/forms/form.dart';
import 'package:sysadmindb/ui/dashboard/gsc_dash.dart';
import 'package:sysadmindb/ui/info_page/deviatedInfoPage.dart';
import 'package:sysadmindb/ui/info_page/studentInfoPage.dart';
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
    //getCourseDemandsFromFirestore();
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

  void _editCourseData(BuildContext context, Course course) {
    bool hasStudents = false;
    List<String> status = ['true', 'false'];
    enrolledStudent.clear();
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

    String selectedProgram = course.program;
    String selectedStatus = course.isactive.toString();
    String selectedType = course.type.toString();
    String selectedFaculty = course.facultyassigned.toString();

    List<Faculty> facultySuggestions = [facultyList[0]];
    for (Faculty facultySuggest in facultyList) {
      // Check if the faculty's history contains the specified course code
      bool hasCourseInHistory = false;
      for (Course historyCourse in facultySuggest.history) {
        if (historyCourse.coursecode == course.coursecode) {
          hasCourseInHistory = true;
          break;
        }
      }
      // If the faculty has the specified course in their history, add them to the suggestions
      if (hasCourseInHistory) {
        facultySuggestions.add(facultySuggest);
      }
    }

    List<Map<String, String>> history = [];
    for (Faculty faculty in facultyList) {
      if (faculty.displayname['firstname']!.contains(course.facultyassigned) &&
          faculty.displayname['lastname']!.contains(course.facultyassigned)) {
        // Extract coursecode and coursename from faculty history and add to history list
        for (Course historyCourse in faculty.history) {
          history.add({
            'coursecode': historyCourse.coursecode,
            'coursename': historyCourse.coursename,
          });
        }
      }
    }

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
            enrolledStudent.add(student);
          }
        });
      });
    });

    if (course.numstudents > 0) {
      print('!EMPTY');
      hasStudents = true;
    } else {
      print('EMPTY');
      hasStudents = false;
    }

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
                            'Course code', coursecodeController, hasStudents),
                        _buildEditableField(
                            'Course Name', coursenameController, hasStudents),
                        DropdownButtonFormField<String>(
                          value: selectedFaculty,
                          items: facultySuggestions.map((faculty) {
                            return DropdownMenuItem<String>(
                              value:
                                  "${faculty.displayname['firstname']} ${faculty.displayname['lastname']}",
                              child: SizedBox(
                                width: 250,
                                child: Row(
                                  children: [
                                    Text(getFullname(faculty)),
                                    Spacer(),
                                    Tooltip(
                                      message: buildCourseHistoryMessage(
                                          faculty, facultySuggestions),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Icon(Icons.info_outline_rounded),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFaculty = value!;
                            });
                          },
                          decoration:
                              InputDecoration(labelText: 'Faculty Assigned'),
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedProgram,
                          items: programs.map((program) {
                            return DropdownMenuItem<String>(
                              value: program,
                              child: Text(program),
                            );
                          }).toList(),
                          onChanged: !hasStudents
                              ? (value) {
                                  setState(() {
                                    selectedProgram = value!;
                                  });
                                }
                              : null,
                          decoration: InputDecoration(labelText: 'Program'),
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          items: type.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: !hasStudents
                              ? (type) {
                                  setState(() {
                                    selectedType = type!;
                                  });
                                }
                              : null,
                          decoration: InputDecoration(labelText: 'Course Type'),
                        ),
                        _buildEditableField(
                            'Units', unitsController, hasStudents),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          items: status.map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: !hasStudents
                              ? (value) {
                                  setState(() {
                                    selectedStatus = value!;
                                  });
                                }
                              : null,
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
                        for (int i = 0; i < enrolledStudent.length; i++)
                          GestureDetector(
                            onTap: () async {
                              // Handle the click event for the ListTile
                              currentStudent = enrolledStudent[i];
                              studentPOS = StudentPOS(
                                acceptanceTerm: getCurrentSYandTerm(),
                                  schoolYears: defaultschoolyears,
                                  uid: enrolledStudent[i].uid,
                                  displayname: enrolledStudent[i].displayname,
                                  role: enrolledStudent[i].role,
                                  email: enrolledStudent[i].email,
                                  idnumber: enrolledStudent[i].idnumber,
                                  enrolledCourses:
                                      enrolledStudent[i].enrolledCourses,
                                  pastCourses: enrolledStudent[i].pastCourses,
                                  degree: enrolledStudent[i].degree,
                                  status: enrolledStudent[i].status);
                              await retrieveStudentPOS(currentStudent!.uid);
                              EN19Form? en19details;
                              await EN19Form.getFormFromFirestore(
                                  currentStudent!.uid);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StudentInfoPage(
                                            student: enrolledStudent[i],
                                            studentpos: studentPOS,
                                            en19: en19details!,
                                          )));
                            },
                            child: ListTile(
                              mouseCursor: SystemMouseCursors.click,
                              title: Text(
                                '${enrolledStudent[i].displayname['firstname']!} ${enrolledStudent[i].displayname['lastname']!}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(enrolledStudent[i].email),
                            ),
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
                    course.program = selectedProgram;
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
                      'program': course.program,
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

  void changeScreen(int index) {
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

  

  Future<void> addEnrolledStudents(
      List<String> students, String courseCode) async {
    print(courseCode);
    Course course = Course(
        uid: 'blank',
        coursecode: 'Select a course',
        coursename: '',
        facultyassigned: '',
        units: 0,
        numstudents: 0,
        isactive: false,
        type: '',
        program: '');

    late EnrolledCourseData enrolledCourse;
    for (Course c in courses) {
      if (c.coursecode == courseCode) {
        course = c;
      }
    }

    enrolledCourse = EnrolledCourseData(
      uid: course.uid,
      coursecode: course.coursecode,
      coursename: course.coursename,
      isactive: course.isactive,
      facultyassigned: course.facultyassigned,
      numstudents: students.length - 1,
      units: course.units,
      type: course.type,
      program: course.program,
    );

    for (Student s in studentList) {
      for (String studentId in students) {
        if (studentId
            .toLowerCase()
            .contains(s.idnumber.toString().toLowerCase())) {
          print('$studentId: ${s.idnumber}');
          // Iterate over each course in the student's enrolledCourses
          if (!(s.enrolledCourses
              .any((course) => course.coursecode == courseCode))) {
            print("Adding this course to: ${s.displayname['firstname']}");

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
                .doc(enrolledCourse.uid)
                .update({'numstudents': FieldValue.increment(1)});
            print('incremented');
          }
        }
      }

/*
      if (students.any((student) => student.contains(s.idnumber.toString()))) {
        print('${s.idnumber}: ${s.displayname['firstname']}');
        if (!s.enrolledCourses.any(
            (eCourse) => eCourse.coursecode == enrolledCourse.coursecode)) {
          // Add the enrolled course to the student's enrolledCourses array if it's not already enrolled
          await FirebaseFirestore.instance
              .collection('users')
              .doc(s.uid)
              .update({
            'enrolledCourses': FieldValue.arrayUnion([enrolledCourse.toJson()]),
          });
          await FirebaseFirestore.instance
              .collection('studentpos')
              .doc(s.uid)
              .update({
            'enrolledCourses': FieldValue.arrayUnion([enrolledCourse.toJson()]),
          });
          await FirebaseFirestore.instance
              .collection('courses')
              .doc(enrolledCourse.uid)
              .update({'numstudents': FieldValue.increment(1)});
          print('incremented');
        }
      }*/
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Enrolled students for $courseCode: ${enrolledCourse.coursename} updated!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<Course> recommendedRemedialCourses = [];
  List<Course> recommendedPriorityCourses = [];

  // FOR CALENDAR
  DateTime currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    bool is12chars = is12charslong(newPasswordController.text);
    bool isAtMost64chars = isatmost64chars(newPasswordController.text);
    bool hasSpecial = hasSpecialChar(newPasswordController.text);
    bool hasNum = hasNumber(newPasswordController.text);
    bool isMatching =
        confirmNewPasswordController.text == newPasswordController.text;
    bool curpassinc = false;

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
                            TextButton(
                                onPressed: () async {
                                  PdfDocument document = PdfDocument(
                                      inputBytes: await _readDocumentData());
                                  //Create a new instance of the PdfTextExtractor.
                                  PdfTextExtractor extractor =
                                      PdfTextExtractor(document);

                                  //Extract all the text from the document.
                                  String text =
                                      extractor.extractText(layoutText: true);

                                  // Split the text into lines
                                  List<String> lines = text.split('\n');

                                  // Process each line
                                  String termLine = '';
                                  String courseLine = '';
                                  List<String> studentLines = [];
                                  int lineNum = 0;

                                  for (String line in lines) {
                                    // Do something with each line

                                    if (line.toLowerCase().contains('term') &&
                                        line.toLowerCase().contains('sy.')) {
                                      termLine = line;
                                    } else {
                                      for (Course course in courses) {
                                        if (line.contains(course.coursecode)) {
                                          courseLine = line.substring(
                                              0, line.indexOf(' '));
                                          break; // Exit loop once a course code is found
                                        }
                                      }
                                    }

                                    if (lineNum > 4) {
                                      studentLines.add(line);
                                    }
                                    lineNum++;
                                  }
                                  await addEnrolledStudents(
                                      studentLines, courseLine);

                                  setState(() {
                                    getCoursesFromFirestore();
                                    addUserFromFirestore();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(20),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25))),
                                child: Icon(Icons.upload)),
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
                                      enrolledStudent.clear();
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
                            EN19Form? en19details;
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

      // CALENDAR PAGE || Following guide: https://www.youtube.com/watch?v=6Gxa-v7Zh7I&ab_channel=AIwithFlutter
      CalendarSF(),

      // INBOX PAGE (Redirect to User's Currently Logged in DLSU Email via link of https://mail.google.com/a/dlsu.edu.ph)
      /*Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Text("Inbox")]),*/
      LaunchGMail(),

          
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
                      users.clear();
                      courses.clear();
                      activecourses.clear();
                      studentList.clear();

                      correctCreds = false;
                      foundCourse.clear();
                      wrongCreds = false;
                      enrolledStudent.clear();
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
