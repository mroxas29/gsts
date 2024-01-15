import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/faculty.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/ui/form.dart';
import 'package:sysadmindb/ui/reusable_widgets.dart';
import 'package:sysadmindb/ui/studentinfopopup.dart';

void main() {
  runApp(
    MaterialApp(home: Sysad()),
  );
}

class Sysad extends StatefulWidget {
  const Sysad({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<Sysad> {
  final controller = TextEditingController();
  var collection = FirebaseFirestore.instance.collection('users');
  late List<Map<String, dynamic>> items;
  bool isLoaded = true;
  late String texttest;
  List<user> foundUser = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<List<Student>> graduateStudents = convertToStudentList(users);
  List<Course> foundCourse = [];

  /// The currently selected index of the bar
  int selectedIndex = 0;

  @override
  initState() {
    foundUser = users;
    foundCourse = courses;
    print("set state for found users");
    super.initState();
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

  void showAddUserForm(BuildContext context, GlobalKey<FormState> formKey) {
    List<String> roles = ['Coordinator', 'Graduate Student', 'Admin'];
    List<String> degrees = ['No degree', 'MIT', 'MSIT'];

    final UserData _userData = UserData();

    String selectedDegree = degrees[0];
    String selectedRole = roles[0];
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    bool isStudent = false;

    print("Add user form executed");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New User'),
          content: Form(
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

                    if (!value.contains('@dlsu.edu.ph')) {
                      return 'Enter a valid @dlsu.edu.ph email';
                    }

                    if (users.any((users) =>
                        users.email.toLowerCase() == value.toLowerCase())) {
                      return "User with email $value already exists";
                    }
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

                    if (users
                        .any((users) => users.idnumber.toString() == value)) {
                      return "User with id number: $value already exists";
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
                    setState(() {
                      selectedRole = value!;
                      selectedDegree = '';
                      if (selectedRole.contains('Student')) {
                        isStudent = true;
                      } else {
                        isStudent = false;
                        selectedDegree = '';
                      }
                      print(isStudent.toString());
                    });
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
                    setState(() {
                      selectedDegree = value!;
                    });
                  },
                  onSaved: (value) {
                    if (isStudent) {
                      _userData.degree = value ?? '';
                    }
                  },
                  decoration: InputDecoration(labelText: 'Degree'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userData.password = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  controller: confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm the password';
                    } else if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
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
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  try {
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: _userData.email,
                      password: _userData.password,
                    );
                    String userID = userCredential.user!.uid;

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
                        'idnumber': _userData.idnumber,
                        'degree': _userData.degree
                      });
                    } else {
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
                        'idnumber': _userData.idnumber,
                      });
                    }
                    Navigator.pop(context);
                    users.clear();
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
                      'idnumber': _userData.idnumber,
                    });
                    Navigator.pop(context);
                    users.clear();

                    addUserFromFirestore();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('User created'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    print('Error creating user: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error creating user: $e'),
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

  void _editUserData(BuildContext context, user user) {
    List<String> roles = ['Coordinator', 'Graduate Student', 'Admin'];
    List<String> degree = ['MIT', 'MSIT', 'No degree'];
    String selectedRole = user.role;


    TextEditingController firstNameController =
        TextEditingController(text: user.displayname['firstname']);
    TextEditingController lastNameController =
        TextEditingController(text: user.displayname['lastname']);
    TextEditingController emailController =
        TextEditingController(text: user.email);
    TextEditingController idNumberController =
        TextEditingController(text: user.idnumber.toString());
    

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildEditableField('First Name', firstNameController, false),
                _buildEditableField('Last Name', lastNameController, false),
                Row(children: [
                  Text(
                    "Email: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    emailController.text,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 78, 78, 78)),
                  ),
                ]),
                Row(children: [
                  Text(
                    "ID Number: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    idNumberController.text,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 78, 78, 78)),
                  ),
                ]),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedRole = value!;
                  },
                  decoration: InputDecoration(labelText: 'Role'),
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
                      content:
                          Text('Are you sure you want to delete this user?'),
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
                        .collection('users')
                        .doc(user.uid)
                        .delete();

                    users.clear();

                    addUserFromFirestore().then((value) => {foundUser = users});

                    // Delete the user from Firebase Authentication
                    await FirebaseAuth.instance.currentUser!.uid;

                    // Show a SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('User deleted'),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Close the dialog
                    Navigator.pop(context);
                  } catch (e) {
                    print('Error deleting user: $e');
                    // Handle the error
                  }
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
                  user.displayname['firstname'] = firstNameController.text;
                  user.displayname['lastname'] = lastNameController.text;
                  user.email = emailController.text;
                  user.role = selectedRole;
                
                  user.idnumber = int.parse(idNumberController.text);
                });

                // Update the data in Firestore
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user
                          .uid) // Assuming you have a 'uid' field in your User class
                      .update({
                    'displayname': {
                      'firstname': firstNameController.text,
                      'lastname': lastNameController.text,
                    },
                    'email': emailController.text,
                    'role': selectedRole,
                    'idnumber': int.parse(idNumberController.text),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User updated'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Trigger a rebuild
                  Navigator.pop(context);
                } catch (e) {
                  print('Error updating user data: $e');
                  // Handle the error
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFacultyDropdown(
    String labelText,
    List<Faculty> facultyList,
    String selectedFaculty,
    void Function(String?)? onChangedCallback,
  ) {
    // Check if the selectedValue is in the facultyList
    bool isCurrentFacultyInList =
        facultyList.any((faculty) => faculty.email == selectedFaculty);

    // If it's not in the list, add it to the list
    if (!isCurrentFacultyInList) {
      facultyList.add(Faculty(displayname: {
        "firstname": selectedFaculty,
        "lastname": selectedFaculty,
      }, email: selectedFaculty, uid: generateUID()));
    }

    return DropdownButtonFormField<String>(
      value: selectedFaculty,
      items: facultyList.map((faculty) {
        return DropdownMenuItem<String>(
          value: faculty.email,
          child: Text(getFullname(faculty)),
        );
      }).toList(),
      onChanged: onChangedCallback,
      decoration: InputDecoration(labelText: labelText),
    );
  }

  void _showStudentInfo(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StudentInfoPopup(student);
      },
    );
  }

  void _editCourseData(BuildContext context, Course course) {
    bool hasStudents = false;
    List<String> status = ['true', 'false'];

    List<String> degrees = ['No degree', 'MIT', 'MSIT'];
    List<String> programs = ['MIT/MSIT', 'MIT', 'MSIT'];
    List<String> type = [
      'Bridging/Remedial Courses',
      'Foundation Courses',
      'Elective Courses',
      'Capstone',
      'Exam Course'
    ];

    String selectedProgram = course.program;
    String selectedStatus = course.isactive.toString();
    String selectedType = course.type.toString();
    String selectedFaculty = course.facultyassigned.toString();

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
                          items: facultyList.map((faculty) {
                            return DropdownMenuItem<String>(
                              value:
                                  "${faculty.displayname['firstname']} ${faculty.displayname['lastname']}",
                              child: Text(getFullname(faculty)),
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
                            onTap: () {
                              // Handle the click event for the ListTile
                              currentStudent = enrolledStudent[i];
                              studentPOS = StudentPOS(
                                  studentIdNumber: enrolledStudent[i].idnumber,
                                  schoolYears: defaultschoolyears,
                                  uid: enrolledStudent[i].uid,
                                  displayname: enrolledStudent[i].displayname,
                                  role: enrolledStudent[i].role,
                                  email: enrolledStudent[i].email,
                                  idnumber: enrolledStudent[i].idnumber,
                                  enrolledCourses:
                                      enrolledStudent[i].enrolledCourses,
                                  pastCourses: enrolledStudent[i].pastCourses,
                                  degree: enrolledStudent[i].degree);

                              retrieveStudentPOS(enrolledStudent[i].uid);
                              _showStudentInfo(context, enrolledStudent[i]);
                            },
                            child: ListTile(
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

  void runFilter(String query) {
    List<user> results = [];
    if (query.isEmpty) {
      results = users;
    } else {
      results = users
          .where((user) =>
              user.displayname
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()) ||
              user.idnumber
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              user.role.toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {
      foundUser = results;
      foundUser.sort((a, b) => a.email.compareTo(b.email));
    });
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

  void changeScreen(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Views to display
    List<Widget> views = [
      //USERS SCREEN
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
                      child: Text("Users",
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
                                prefixIcon: const Icon(Icons.search),
                                hintText: ' ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                )),
                            onChanged: (value) => runFilter(value),
                          ),
                        )),
                  ],
                ),
                Column(children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextButton(
                        onPressed: () {
                          showAddUserForm(context, _formKey);
                        },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25))),
                        child: Icon(Icons.person_add)),
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

                  itemCount: foundUser.length,
                  itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          _editUserData(context, foundUser[index]);
                        },
                        child: Card(
                          key: ValueKey(foundUser[index]),
                          color: Colors.white,
                          elevation: 4,
                          margin:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: ListTile(
                            title: Text(
                              formatMapToString(foundUser[index].displayname),
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                "${foundUser[index].role} ${foundUser[index].email}"),
                            trailing:
                                Text(foundUser[index].idnumber.toString()),
                          ),
                        ),
                      )),
            ))
          ]),
      //COURSES SCREEN
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
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                )),
                            onChanged: (value) => runCourseFilter(value),
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
                                borderRadius: BorderRadius.circular(25))),
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
                          _editCourseData(context, foundCourse[index]);
                        },
                        child: Card(
                          key: ValueKey(foundCourse[index]),
                          color: Colors.white,
                          elevation: 4,
                          margin:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: ListTile(
                            title: Text(
                              foundCourse[index].coursecode,
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "${foundCourse[index].facultyassigned}\n${foundCourse[index].coursename}"),
                                Text(
                                  foundCourse[index].isactive
                                      ? 'Active'
                                      : 'Inactive',
                                  style: TextStyle(
                                    color: foundCourse[index].isactive
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                )
                              ],
                            ),
                            trailing:
                                Text(foundCourse[index].numstudents.toString()),
                          ),
                        ),
                      )),
            ))
          ]),
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
                      users.clear();
                      courses.clear();
                      activecourses.clear();
                      studentList.clear();
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
                  label: 'Students',
                ),
                SideNavigationBarItem(
                  icon: Icons.book,
                  label: 'Courses',
                ),
              ],
              onTap: changeScreen,
              toggler: SideBarToggler(
                  expandIcon: Icons.keyboard_arrow_right,
                  shrinkIcon: Icons.keyboard_arrow_left,
                  onToggle: () {}),
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
