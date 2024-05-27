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
import 'package:sysadmindb/ui/forms/form.dart';
import 'package:sysadmindb/ui/reusable_widgets.dart';
import 'package:sysadmindb/ui/forms/user_form_dialog.dart';

void main() {
  runApp(
    MaterialApp(home: Dit()),
  );
}

class Dit extends StatefulWidget {
  const Dit({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<Dit> {
  final controller = TextEditingController();
  var collection = FirebaseFirestore.instance.collection('users');
  late List<Map<String, dynamic>> items;
  bool isLoaded = true;
  late String texttest;
  List<user> foundUser = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<List<Student>> graduateStudents = convertToStudentList(users);
  List<Course> foundCourse = [];
  bool isEditing = false;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  bool isValidPass = false;

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

  void _showStudentInfo(BuildContext context, Student student) {}

  void changeScreen(int index) {
    setState(() {
      selectedIndex = index;
    });
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
                /*
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
              */
                Column(children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextButton(
                      onPressed: () {
                        showStudentTypeDialog(context, _formKey);
                      },
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25))),
                      child: Column(
                        children: [Icon(Icons.person_add), Text("Add Users")],
                      ),
                    ),
                  )
                ])
              ],
            ),

/*
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
            )),
        
*/        
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
                /*
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
                ),*/
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
                      child: Column(
                          // PREVIOUS CODE: child: Icon(Icons.post_add)),
                          children: [Icon(Icons.post_add), Text("Add Course")]),
                    ),
                  ),
                ])
              ],
            ),

/*
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
         
         */
          ]),

      SingleChildScrollView(
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
                  label: 'User Management', // OLD CODE: label: 'Students',
                ),
                SideNavigationBarItem(
                  icon: Icons.book,
                  label: 'Courses',
                ),
                SideNavigationBarItem(
                    icon: Icons.settings, label: 'Profile Settings')
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
