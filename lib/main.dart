import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/coursedemand.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/faculty.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/gradstudent_screen.dart';
import 'package:sysadmindb/gsc_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sysadmindb/sysad.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sysadmindb/ui/reusable_widgets.dart';
// ignore: implementation_imports
import 'package:flutter/src/widgets/container.dart' as contain;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    title: 'Login Page',
    home: LoginPage(),
  ));
}

//hello marion
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

TextEditingController passwordTextController = TextEditingController();
TextEditingController emailTextController = TextEditingController();
late user currentUser;
late Student currentStudent;
// Display students enrolled in the specific course
List<String> enrolledStudentNames = [];
List<String> enrolledStudentEmails = [];
bool wrongCreds = false;
bool correctCreds = false;

class _LoginPageState extends State<LoginPage> {
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error sending password reset email: $e");
      // Handle any errors, e.g., show an error message to the user
    }
  }

  void showPasswordResetDialog(BuildContext context) {
    String email = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  email = value;
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
              child: Text('Send password recovery'),
              onPressed: () async {
                await resetPassword(email);
                // Optionally, show a success message or navigate to another screen
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool isPressed = false;

  final db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    //  final GlobalKey<State> _LoaderDialog = GlobalKey<State>();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: contain.Container(
              color: const Color.fromARGB(255, 231, 231, 231),
              child: Center(
                child: SizedBox(
                  width: 400,
                  height: 350,
                  child: contain.Container(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.71),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 134, 134, 134),
                              offset: Offset(15, 9),
                              blurRadius: 20.0,
                              spreadRadius: 10.0,
                            )
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 7, 68,
                                      1), // Set your desired background color
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Graduate Student Tracking System',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'inter',
                                        color:
                                            Color.fromARGB(255, 206, 206, 206),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              )),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: resusableTextField(
                                  "Enter email",
                                  Icons.person_outline,
                                  false,
                                  emailTextController)),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 20),
                              child: resusableTextField("Enter Password",
                                  Icons.lock, true, passwordTextController)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 10),
                                  child: signInSignUpButton(
                                    context,
                                    true,
                                    () {
                                      setState(() {
                                        isPressed = true;
                                      });

                                      signIn(emailTextController.text,
                                          passwordTextController.text);
                                    },
                                    isPressed,
                                  )),
                              SizedBox(
                                width: 20,
                              ),
                              GestureDetector(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    "Forgot your password?\nClick here",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 9, 63,
                                          2), // You can choose the color you prefer
                                      decoration: TextDecoration
                                          .underline, // Add an underline style
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  showPasswordResetDialog(context);
                                  print("Forgor Password");
                                  // Handle the click action, e.g., navigate to the password reset screen.
                                },
                              )
                            ],
                          ),
                          Center(
                              child: Column(
                            children: [
                              wrongCreds
                                  ? Text(
                                      "Incorrect email or password",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : SizedBox(),
                              correctCreds
                                  ? Text(
                                      "Login Success",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 4, 87, 11)),
                                    )
                                  : SizedBox()
                            ],
                          ))
                        ],
                      )),
                ),
              ))),
    );
  }

  void route() async {
    User? authuser = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(authuser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        String targetemail = emailTextController.text;
        currentUser = users.firstWhere((users) => users.email == targetemail);
        print('Found user: ${currentUser.displayname['firstname']}');
        if (documentSnapshot.get('role') == "Coordinator") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Gscscreen(),
            ),
          );
        } else if (documentSnapshot.get('role') == "Admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Sysad(),
            ),
          );
        } else {
          List<EnrolledCourseData> enrolledCourses =
              await getEnrolledCoursesForStudent(currentUser.uid);
          List<PastCourse> pastCourses =
              await getPastCoursesForStudent(currentUser.uid);
          // Assuming enrolledCourses is a list of EnrolledCourseData
          Student convertToStudent(user currentUser) {
            return Student(
              uid: currentUser.uid,
              displayname: currentUser.displayname,
              role: currentUser.role,
              email: currentUser.email,
              idnumber: currentUser.idnumber,
              enrolledCourses: enrolledCourses,
              pastCourses: pastCourses,
            );
          }

          currentStudent = convertToStudent(currentUser);
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GradStudentscreen(),
            ),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  void signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Reset the wrongCreds variable to false upon successful login
      setState(() {
        wrongCreds = false;
        correctCreds = true;
      });

      await addUserFromFirestore();
      await getCoursesFromFirestore();
      await getFacultyList();
      await getCourseDemandsFromFirestore();
      await convertToStudentList(users);
      route();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Incorrect email or password');
      }
      setState(() {
        wrongCreds = true;
      });
    } finally {
      setState(() {
        isPressed = false;
      });
    }
  }

  void signUp(String email, String password, String rool) async {
    CircularProgressIndicator();

    await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) => {postDetailsToFirestore(email, rool)})
        .catchError((e) {});
  }

  postDetailsToFirestore(String email, String password) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    ref.doc(user!.uid).set({
      'email': emailTextController.text,
      'password': passwordTextController.text
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
