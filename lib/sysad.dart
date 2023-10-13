import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/ui/form.dart';
import 'package:sysadmindb/ui/reusable_widgets.dart';

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

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: controller),
        ],
      ),
    );
  }

  void _editUserData(BuildContext context, user user) {
    List<String> roles = ['Coordinator', 'Graduate Student', 'Admin'];
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
                _buildEditableField('First Name', firstNameController),
                _buildEditableField('Last Name', lastNameController),
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
                _buildEditableField('ID Number', idNumberController),
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

  void _editCourseData(BuildContext context, Course course) {
    List<String> status = ['true', 'false'];
    String selectedstatus = course.isactive.toString();
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController coursecodeController =
        TextEditingController(text: course.coursecode);
    TextEditingController coursenameController =
        TextEditingController(text: course.coursename);
    TextEditingController facultyassignedController =
        TextEditingController(text: course.facultyassigned);
    TextEditingController unitsController =
        TextEditingController(text: course.units.toString());
    TextEditingController numstudentsController =
        TextEditingController(text: course.numstudents.toString());
 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Course'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildEditableField('Course code', coursecodeController),
                _buildEditableField('Course Name', coursenameController),
                _buildEditableField(
                    'Faculty Assigned', facultyassignedController),
                Row(children: [
                  Text(
                    "Students Enrolled: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    numstudentsController.text,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 78, 78, 78)),
                  ),
                ]),
                _buildEditableField('Units', unitsController),
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
                  decoration: InputDecoration(labelText: 'is active?'),
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
                  course.coursecode = coursecodeController.text;
                  course.coursename = coursenameController.text;
                  course.numstudents = int.parse(numstudentsController.text);
                  course.isactive = bool.parse(selectedstatus);
                  course.numstudents = int.parse(numstudentsController.text);
                  course.units = int.parse(unitsController.text);
                });

                // Update the data in Firestore
                try {
                  await FirebaseFirestore.instance
                      .collection('courses')
                      .doc(course
                          .uid) // Assuming you have a 'uid' field in your User class
                      .update({
                    'coursecode': coursecodeController.text,
                    'coursename': coursenameController.text,
                    'facultyassigned': facultyassignedController.text,
                    'isactive': bool.parse(selectedstatus),
                    'numstudents': int.parse(numstudentsController.text),
                    'units': int.parse(unitsController.text)
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
                  .contains(query.toLowerCase()))
          .toList();
    }
    setState(() {
      foundCourse = results;
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
                          _editUserData(context, users[index]);
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
                          _editCourseData(context, courses[index]);
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
                    "${currentUser!.displayname['firstname']!} ${currentUser!.displayname['lastname']!}",
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
