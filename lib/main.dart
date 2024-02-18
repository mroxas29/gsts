import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/coursedemand.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/faculty.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
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
import 'dart:html';

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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

TextEditingController passwordTextController = TextEditingController();
TextEditingController emailTextController = TextEditingController();
late user currentUser;
late Student? currentStudent;
// Display students enrolled in the specific course
List<Student> enrolledStudent = [];
bool wrongCreds = false;
bool correctCreds = false;
String curpass = passwordTextController.text;

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color.fromARGB(255, 25, 87, 27) // Set the color of the arrow
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0; // Adjust the thickness of the arrow
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..cubicTo(size.width * 0.9, size.height * 0.7, size.width * 0.8,
          size.height * 0.8, size.width * 0.7, size.height * 0.9)
      ..cubicTo(size.width * 0.6, size.height, size.width * 0.5,
          size.height * 0.9, size.width * 0.4, size.height * 0.8)
      ..cubicTo(size.width * 0.3, size.height * 0.7, size.width * 0.2,
          size.height * 0.8, size.width * 0.1, size.height * 0.9)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

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
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid email'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else if (!isValidEmail(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid email'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  await resetPassword(email);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password email reset sent!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                // Optionally, show a success message or navigate to another screen
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool isValidEmail(String email) {
    // Use a regular expression to check if the email address has a valid format
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  bool isPressed = false;

  final db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    //  final GlobalKey<State> _LoaderDialog = GlobalKey<State>();

    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: Stack(
        children: [
          CustomPaint(
            painter: ArrowPainter(),
            child: Container(
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          contain.Container(
            color: Color.fromARGB(0, 231, 231, 231),
            height: screenHeight,
            child: Padding(
                padding: EdgeInsets.only(top: screenHeight / 5),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                      width: 450,
                      child: SingleChildScrollView(
                        child: contain.Container(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 58, 57, 57),
                                    offset: Offset(15, 9),
                                    blurRadius: 30.0,
                                    spreadRadius: 2.0,
                                  )
                                ]),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Align text to the left

                                      children: [
                                        Image.asset("assets/images/De_La_Salle_University_Seal.png"),
                                        Text(
                                          'Log Into GSTS',
                                          style: TextStyle(
                                              fontSize: 26,
                                              fontFamily: 'inter',
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'Email',
                                          style: TextStyle(
                                            color: Color.fromARGB(136, 0, 0, 0),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        resusableTextField(
                                            "Enter email",
                                            Icons.person_outline,
                                            false,
                                            emailTextController)
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Align text to the left

                                      children: [
                                        Text(
                                          'Password',
                                          style: TextStyle(
                                            color: Color.fromARGB(136, 0, 0, 0),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        resusableTextField(
                                            "Enter Password",
                                            Icons.lock,
                                            true,
                                            passwordTextController)
                                      ],
                                    )),
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

                                              curpass =
                                                  passwordTextController.text;
                                            });
                                            signIn(
                                                emailTextController.text
                                                    .toLowerCase(),
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
                                        // Handle the click action, e.g., navigate to the password reset screen.
                                      },
                                    )
                                  ],
                                ),
                                Center(
                                  child: Column(
                                    children: [
                                      wrongCreds
                                          ? Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                          112, 240, 65, 53)
                                                      .withOpacity(
                                                          0.9), // Border color
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                "Incorrect email or password",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w100,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                      correctCreds
                                          ? Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                          255, 17, 109, 17)
                                                      .withOpacity(
                                                          0.9), // Border color
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                "Login Success",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 4, 87, 11),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                )
                              ],
                            )),
                      )),
                )),
          )
        ],
      )),
    );
  }

  void route() async {
    User? authuser = FirebaseAuth.instance.currentUser;
    await retrieveAllPOS();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(authuser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        String targetemail = emailTextController.text.toLowerCase();
        currentUser = users.firstWhere((users) => users.email == targetemail);

        if (passwordTextController.text.length < 12 ||
            curpass.length > 64 ||
            !passwordTextController.text.contains(RegExp(r'[0-9]')) ||
            !passwordTextController.text
                .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please change your password, it is not secured'),
              duration: Duration(seconds: 5),
            ),
          );
        }
        if (documentSnapshot.get('role') == "Coordinator") {
          currentStudent = studentList[0];

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
        } else if (documentSnapshot.get('role') == "Graduate Student") {
          List<EnrolledCourseData> enrolledCourses =
              await getEnrolledCoursesForStudent(currentUser.uid);
          List<PastCourse> pastCourses =
              await getPastCoursesForStudent(currentUser.uid);
          String degree = await getDegreeForStudent(currentUser.uid);
          Student convertToStudent(user currentUser) {
            return Student(
                uid: currentUser.uid,
                displayname: currentUser.displayname,
                role: currentUser.role,
                email: currentUser.email,
                idnumber: currentUser.idnumber,
                enrolledCourses: enrolledCourses,
                pastCourses: pastCourses,
                degree: degree,
                status: currentUser.status);
          }

          currentStudent = convertToStudent(currentUser);
          print(
              "Current student uid: ${currentStudent!.uid}\nCurrent User uid: ${currentUser.uid}");

          setState(() {
            retrieveStudentPOS(currentStudent!.uid);
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GradStudentscreen(),
            ),
          );
        } else {
          wrongCreds = true;
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
