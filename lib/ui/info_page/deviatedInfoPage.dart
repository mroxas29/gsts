import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/api/email/invoice_service.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/DeviatedStudents.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/en-19.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/ui/forms/addcourse.dart';
import 'package:sysadmindb/ui/dashboard/gsc_dash.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviatedInfoPage extends StatefulWidget {
  final DeviatedStudent student;
  StudentPOS studentpos;
  EN19Form? en19;
  DeviatedInfoPage(
      {required this.student, required this.studentpos, required this.en19});

  @override
  _DeviatedInfoPage createState() => _DeviatedInfoPage();
}

late Future<ListResult> documentations;
late Future<ListResult> defenseForms;

class _DeviatedInfoPage extends State<DeviatedInfoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  DeviatedStudent fetchStudentInfo(DeviatedStudent student) {
    return DeviatedStudent(
        studentPOS: widget.studentpos,
        deviatedCourses: widget.student.deviatedCourses);
  }

  bool isStillDeviated(String currentTerm, String foundTerm, Course course) {
    if (currentTerm != foundTerm) {
      return true;
    } else {
      return false;
    }
  }
    Future<void> uploadGeneratedPdf(Uint8List data, String form) async {
    String fileName =
        '${widget.studentpos.idnumber}/Defense Forms/${form}_${widget.studentpos.idnumber}.pdf';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.putData(data);
    print('Generated PDF uploaded successfully');
  }

   Future<void> modifyDefenseForm() async {
    // First dialog to confirm review
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Review Document'),
          content: Text('Have you reviewed the document?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Proceed'),
              onPressed: () {
                Navigator.of(context).pop();
                // Show second dialog for checkboxes
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final TextEditingController leadPanelController =
                        TextEditingController();
                    final TextEditingController panelMember1Controller =
                        TextEditingController();
                    final TextEditingController panelMember2Controller =
                        TextEditingController();
                    final TextEditingController panelMember3Controller =
                        TextEditingController();
                    final TextEditingController panelMember4Controller =
                        TextEditingController();

                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return AlertDialog(
                          title: Text('Assign panelists'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  'Lead Panel: ',
                                  style: TextStyle(fontSize: 15),
                                ),
                                TextField(
                                  controller: leadPanelController,
                                  decoration: InputDecoration(
                                      hintText: 'Enter lead panel name'),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Panel Members',
                                  style: TextStyle(fontSize: 15),
                                ),
                                TextField(
                                  controller: panelMember1Controller,
                                  decoration: InputDecoration(
                                      hintText: 'Enter panel member 1 name'),
                                ),
                                TextField(
                                  controller: panelMember2Controller,
                                  decoration: InputDecoration(
                                      hintText: 'Enter panel member 2 name'),
                                ),
                                TextField(
                                  controller: panelMember3Controller,
                                  decoration: InputDecoration(
                                      hintText: 'Enter panel member 3 name'),
                                ),
                                TextField(
                                  controller: panelMember4Controller,
                                  decoration: InputDecoration(
                                      hintText: 'Enter panel member 4 name'),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Submit'),
                              onPressed: () async {
                                // Handle the submission of the evaluation here
                                EN19Form form = EN19Form(
                                  proposedTitle: widget.en19!.proposedTitle,
                                  lastName: _capitalize(
                                  widget.studentpos
                                      .displayname['lastname']!),
                                  firstName: _capitalize(
                                       widget
                                      .studentpos.displayname['firstname']!),
                                  middleName: '',
                                  idNumber: widget.studentpos.idnumber.toString(),
                                  college: 'Computer Studies',
                                  program: widget.studentpos.degree,
                                  passedComprehensiveExams:
                                      widget.en19!.passedComprehensiveExams,
                                  submittedCertificate:
                                      widget.en19!.submittedCertificate,
                                  adviserName: widget.en19!.adviserName,
                                  enrollmentStage: widget.en19!.enrollmentStage,
                                  date: DateTime.now(),
                                  leadPanel: leadPanelController.text.isEmpty
                                      ? 'No lead panel assigned'
                                      : leadPanelController.text,
                                  panelMembers: [
                                    panelMember1Controller.text.isEmpty
                                        ? ' '
                                        : panelMember1Controller.text,
                                    panelMember2Controller.text.isEmpty
                                        ? ' '
                                        : panelMember2Controller.text,
                                    panelMember3Controller.text.isEmpty
                                        ? ' '
                                        : panelMember3Controller.text,
                                    panelMember4Controller.text.isEmpty
                                        ? ' '
                                        : panelMember4Controller.text,
                                  ],
                                  defenseDate: 'No date set',
                                  signedByGSC: widget.en19!.signedByGSC,
                                  signedByAdviser: widget.en19!.signedByAdviser,
                                  defenseTime: 'No time set',
                                  mainTitle: widget.en19!.mainTitle,
                                  defenseType: widget.en19!.defenseType,
                                  verdict: widget.en19!.verdict,
                                );

                                form.saveFormToFirestore(
                                    form, widget.studentpos.uid);

                                Uint8List pdfData =
                                    await service.createDefenseForm(form,
                                        form.defenseType, currentStudent!);
                                await uploadGeneratedPdf(
                                    pdfData, 'EN-18DefenseForm');
                                service.savePdfFile(
                                    'EN18Defense Form_${currentUser.idnumber}.pdf',
                                    pdfData);

                                Navigator.of(context).pop();
                                // You can add further actions after submission here
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }


  String _capitalize(String input) {
    if (input.isEmpty) {
      return '';
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  bool isStudentDeviated() {
    if (deviatedStudentList.any((devStudent) =>
        devStudent.studentPOS.idnumber == widget.studentpos.idnumber)) {
      return true;
    }

    return false;
  }

  String findSYTerm(Course course) {
    for (int i = 0; i < widget.studentpos.schoolYears.length; i++) {
      SchoolYear sy = widget.studentpos.schoolYears[i];
      for (int j = 0; j < sy.terms.length; j++) {
        Term term = sy.terms[j];

        if (term.termcourses.any((c) => c.coursecode == course.coursecode)) {
          return '${sy.name} ${term.name}';
        }
      }
    }
    return '(not found on POS)';
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

  void updateProgramOfStudy() async {
    // Set the flag to false before starting asynchronous operations
    setState(() {
      posEdited = false;
    });

    // Update deviated students
    getDeviatedStudents();

    // Set Firestore data
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> studentPosData = widget.studentpos.toJson();
    await firestore
        .collection('studentpos')
        .doc(widget.student.studentPOS.uid)
        .set(studentPosData);

    // Retrieve all POS data
    await retrieveAllPOS();

    // Show a snackbar after the asynchronous operations complete
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Program of Study updated'),
        duration: Duration(seconds: 2),
      ),
    );

    // Update the state after all asynchronous operations complete
    setState(() {});
  }

  void restructurePOS(StudentPOS posToChange) {
    setState(() {
      posEdited = true;
    });

    String currentSYandTerm = reformatSYandTerm(getCurrentSYandTerm());
    String nextSYandTerm = getNextSYandTerm();
    List<Course> coursesToMove = [];
    List<Course> enrolledCourses = posToChange.enrolledCourses.toList();

    // Separate courses that are not past courses
    for (SchoolYear sy in posToChange.schoolYears) {
      for (Term term in sy.terms) {
        for (int i = 0; i < term.termcourses.length; i++) {
          Course course = term.termcourses[i];
          bool isPastCourse = posToChange.pastCourses.any(
            (pastcourse) =>
                pastcourse.coursecode == course.coursecode &&
                pastcourse.grade >= 2.0,
          );
          if (!isPastCourse &&
              !enrolledCourses
                  .any((eCourse) => eCourse.coursecode == course.coursecode)) {
            coursesToMove.add(course);
            term.termcourses.removeAt(i);
            i--; // Adjust index due to removal
          }
        }
      }
    }

    // Find the current school year and term, or create a new one if not found
    int currentSYIndex = posToChange.schoolYears
        .indexWhere((sy) => currentSYandTerm.startsWith(sy.name));
    if (currentSYIndex == -1) {
      // Create a new school year with the currentSYandTerm
      String newSYName = currentSYandTerm.split(' ')[0];
      SchoolYear newSY = SchoolYear(
        newSYName,
        [
          Term('Term 1', []),
          Term('Term 2', []),
          Term('Term 3', []),
        ],
      );
      posToChange.schoolYears.add(newSY);
      currentSYIndex = posToChange.schoolYears.length - 1;
    }

    int currentTermIndex = posToChange.schoolYears[currentSYIndex].terms
        .indexWhere((term) => currentSYandTerm.endsWith(term.name));
    if (currentTermIndex == -1) {
      currentTermIndex = 0; // Default to the first term if not found
    }

    // Add enrolled courses to the current school year and term
    for (Course course in enrolledCourses) {
      Term currentTerm =
          posToChange.schoolYears[currentSYIndex].terms[currentTermIndex];
      if (course.coursecode == 'OEX') {
        if (currentTerm.termcourses.isEmpty) {
          currentTerm.termcourses
              .add(course); // OEX course should be alone in a term
        }
      } else {
        if (currentTerm.termcourses.length < 2) {
          currentTerm.termcourses.add(course);
        } else {
          // Find the next available term in the current school year
          for (int termIndex = 0;
              termIndex < posToChange.schoolYears[currentSYIndex].terms.length;
              termIndex++) {
            Term term =
                posToChange.schoolYears[currentSYIndex].terms[termIndex];
            if (term.termcourses.length < 2) {
              term.termcourses.add(course);
              break;
            }
          }
        }
      }
    }

    // Function to add courses to the next available term, handling OEX and term limits
    void addCoursesToNextTerms(
        List<Course> coursesToMove, int startSYIndex, int startTermIndex) {
      int courseIndex = 0;
      while (courseIndex < coursesToMove.length) {
        for (int syIndex = startSYIndex;
            syIndex < posToChange.schoolYears.length;
            syIndex++) {
          for (int termIndex = (syIndex == startSYIndex ? startTermIndex : 0);
              termIndex < posToChange.schoolYears[syIndex].terms.length;
              termIndex++) {
            Term term = posToChange.schoolYears[syIndex].terms[termIndex];

            while (courseIndex < coursesToMove.length) {
              Course course = coursesToMove[courseIndex];

              // If the course is "OEX", it should be alone in a term
              if (course.coursecode == 'OEX') {
                if (term.termcourses.isEmpty) {
                  term.termcourses.add(course);
                  coursesToMove.removeAt(courseIndex);
                }
                break;
              }

              // Otherwise, add the course if there are fewer than 2 courses in the term
              if (term.termcourses.length < 2) {
                term.termcourses.add(course);
                coursesToMove.removeAt(courseIndex);
              } else {
                break;
              }
            }

            // If all courses have been added, exit the loops
            if (coursesToMove.isEmpty) {
              break;
            }
          }

          // If all courses have been added, exit the loop
          if (coursesToMove.isEmpty) {
            break;
          }
        }

        // If there are still courses to move, create a new school year and add them
        if (coursesToMove.isNotEmpty) {
          SchoolYear lastSY = posToChange.schoolYears.last;
          int nextStartYear = int.parse(lastSY.name.split('-')[1]);
          SchoolYear newSY = SchoolYear(
            '$nextStartYear-${nextStartYear + 1}',
            [
              Term('Term 1', []),
              Term('Term 2', []),
              Term('Term 3', []),
            ],
          );
          posToChange.schoolYears.add(newSY);
          startSYIndex = posToChange.schoolYears.length - 1;
          startTermIndex = 0;

          // Add remaining courses to the new school year
          for (int termIndex = 0; termIndex < newSY.terms.length; termIndex++) {
            Term term = newSY.terms[termIndex];

            while (courseIndex < coursesToMove.length) {
              Course course = coursesToMove[courseIndex];

              if (course.coursecode == 'OEX') {
                if (term.termcourses.isEmpty) {
                  term.termcourses.add(course);
                  coursesToMove.removeAt(courseIndex);
                }
                break;
              }

              // Otherwise, add the course if there are fewer than 2 courses in the term
              if (term.termcourses.length < 2) {
                term.termcourses.add(course);
                coursesToMove.removeAt(courseIndex);
              } else {
                break;
              }
            }

            // If all courses have been added, exit the loop
            if (coursesToMove.isEmpty) {
              break;
            }
          }
        }
      }
    }

    // Find the next school year and term, or create a new one if not found
    int nextSYIndex = posToChange.schoolYears
        .indexWhere((sy) => nextSYandTerm.startsWith(sy.name));
    if (nextSYIndex == -1) {
      // Create a new school year with the nextSYandTerm
      String newSYName = nextSYandTerm.split(' ')[0];
      SchoolYear newSY = SchoolYear(
        newSYName,
        [
          Term('Term 1', []),
          Term('Term 2', []),
          Term('Term 3', []),
        ],
      );
      posToChange.schoolYears.add(newSY);
      nextSYIndex = posToChange.schoolYears.length - 1;
    }

    int nextTermIndex = posToChange.schoolYears[nextSYIndex].terms
        .indexWhere((term) => nextSYandTerm.endsWith(term.name));
    if (nextTermIndex == -1) {
      nextTermIndex = 0; // Default to the first term if not found
    }

    // Add remaining courses to the next school year and term
    addCoursesToNextTerms(coursesToMove, nextSYIndex, nextTermIndex);

    // Further processing such as handling unmovable courses or updating UI
    getDeviatedStudents();
  }

  bool posEdited = false;
  PlatformFile? pickedFile;
  @override
  void initState() {
    super.initState();
    documentations = FirebaseStorage.instance
        .ref('/${widget.studentpos.idnumber}/Documentations')
        .listAll();
    defenseForms = FirebaseStorage.instance
        .ref('/${widget.studentpos.idnumber}/Defense Forms')
        .listAll();
    _tabController = TabController(length: 3, vsync: this);
    if (_tabController.index == 2 &&
        applicantList.any((newStudent) =>
            newStudent.idnumber == widget.studentpos.idnumber &&
            shownRecoGuide == false)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add recommended courses for student'),
            content: Text(
                "Add specific remedial courses that the student needs.\n Click 'Download Recommendation Form' when finished adding."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false); // No, do not delete
                },
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }

  bool hasEn19Form = true;
  List<DataRow> rows = [];
  final PdfInvoiceService service = PdfInvoiceService();

  List<Course> recommendedRemedialCourses = [];
  List<Course> recommendedPriorityCourses = [];
  Future<void> downloadEN19File() async {
    String fileName =
        '${widget.studentpos.idnumber}/Defense Forms/EN-19Form_${widget.studentpos.idnumber}.pdf';

    try {
      final imageUrl =
          await FirebaseStorage.instance.ref().child(fileName).getDownloadURL();
      if (await canLaunch(imageUrl.toString())) {
        await launch(imageUrl.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download file'),
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

    // Implement file download logic using the URL
  }

  Future<void> checkIfFormExists() async {
    bool exists = await EN19Form.hasEn19Form(widget.studentpos.uid);
    setState(() {
      hasEn19Form = exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.studentpos.degree.contains('MIT')) {
      rows = capstonecourses.map((capstoneCourse) {
        return isCoursePassed(capstoneCourse, context);
      }).toList();
    } else if (widget.studentpos.degree.contains('MSIT')) {
      rows = thesiscourses.map((thesisCourse) {
        return isCoursePassed(thesisCourse, context);
      }).toList();
    }
    DeviatedStudent studentInfo = fetchStudentInfo(widget.student);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${_capitalize(studentInfo.studentPOS.displayname['firstname']!)}\'s profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Student Information'),
            Tab(text: 'Program of Study'),
            Tab(
              text: (studentInfo.studentPOS.degree == 'MIT')
                  ? 'Capstone Progress'
                  : 'Thesis Progress',
            )
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [
        SingleChildScrollView(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: MediaQuery.sizeOf(context).width / 3,
                            child: SingleChildScrollView(
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                elevation: 4.0,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10, 10, 200, 70),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Align text to the left
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Student profile",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        "${_capitalize(studentInfo.studentPOS.displayname['firstname']!)} ${_capitalize(studentInfo.studentPOS.displayname['lastname']!)} ",
                                        style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 23, 71, 25)),
                                      ),
                                      Text(studentInfo.studentPOS.degree
                                              .contains('MSIT')
                                          ? 'Master of Science in Information Technology - ${studentInfo.studentPOS.idnumber.toString()}'
                                          : 'Master in Information Technology - ${studentInfo.studentPOS.idnumber.toString()}'),
                                      Text(studentInfo.studentPOS.email),
                                      Text(
                                          'Enrollment Status: ${studentInfo.studentPOS.status}'),
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
                          width: MediaQuery.sizeOf(context).width /
                              3, // Set your desired width
                          child: SingleChildScrollView(
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              elevation: 4.0,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Academic Progress",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Enrolled courses",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 150, // Set your desired height

                                      child: ListView.builder(
                                        itemCount: studentInfo
                                            .studentPOS.enrolledCourses.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final enrolledCourse = studentInfo
                                              .studentPOS
                                              .enrolledCourses[index];
                                          return ListTile(
                                            title: Text(
                                              "${enrolledCourse.coursecode}: ${enrolledCourse.coursename}",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            // Add any other details you want to display
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      "Past courses",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 150, // Set your desired height

                                      child: ListView.builder(
                                        itemCount: studentInfo
                                            .studentPOS.pastCourses.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final pastCourse = studentInfo
                                              .studentPOS.pastCourses[index];
                                          return ListTile(
                                            title: Text(
                                              "${pastCourse.coursecode}: ${pastCourse.coursename} (Grade:  ${pastCourse.grade.toDouble()})",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            // Add any other details you want to display
                                          );
                                        },
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
                ),
              ],
            )),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Program of Study",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: posEdited
                              ? () {
                                  // Implement logic to save studentPOS
                                  updateProgramOfStudy();
                                }
                              : null, // Disable the button when no course is added
                          child: Text("Save changes"),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Implement logic to save studentPOS
                            restructurePOS(widget.studentpos);
                          }, // Disable the button when no course is added
                          child: Text("Restructure POS"),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Student enrolled in:",
                          style: TextStyle(fontSize: 14),
                        ),
                        for (Course course in widget.studentpos.enrolledCourses)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Course ${course.coursecode}: ${course.coursename}  is supposed to be taken on ${findSYTerm(course)}",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: widget.student.deviatedCourses.any(
                                            (element) =>
                                                element.coursecode ==
                                                course.coursecode)
                                        ? Colors.red
                                        : Colors.black),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          )
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            widget.studentpos.schoolYears.map<Widget>((year) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 4.0,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Theme(
                                  data: ThemeData(
                                    dividerColor:
                                        Colors.transparent, // Remove border
                                  ),
                                  child: ExpansionTile(
                                    title: Row(
                                      children: [
                                        Text(
                                          "S.Y ${year.name}",
                                          style: isStudentDeviated()
                                              ? getCurrentSYandTerm()
                                                      .contains(year.name)
                                                  ? TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors.red)
                                                  : TextStyle(
                                                      fontSize: 16.0,
                                                    )
                                              : TextStyle(fontSize: 16.0),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      ...year.terms.expand<Widget>((term) {
                                        return [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: ExpansionTile(
                                              title: Text(
                                                term.name,
                                                style: term.termcourses.any(
                                                        (termcourse) => widget
                                                            .student
                                                            .deviatedCourses
                                                            .any((devcourse) =>
                                                                devcourse
                                                                    .coursecode ==
                                                                termcourse
                                                                    .coursecode))
                                                    ? TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.red)
                                                    : TextStyle(fontSize: 14.0),
                                              ),
                                              children: [
                                                ...term.termcourses
                                                    .map((course) {
                                                  return ListTile(
                                                    title: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            course.coursecode,
                                                            style: TextStyle(
                                                                fontSize: 12.0),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              setState(() {
                                                                recommendedRemedialCourses.removeWhere(
                                                                    (toremove) =>
                                                                        toremove
                                                                            .coursecode ==
                                                                        course
                                                                            .coursecode);

                                                                recommendedPriorityCourses.removeWhere(
                                                                    (toremove) =>
                                                                        toremove
                                                                            .coursecode ==
                                                                        course
                                                                            .coursecode);
                                                                getDeviatedStudents();
                                                                term.termcourses
                                                                    .remove(
                                                                        course);
                                                                posEdited =
                                                                    true;
                                                              });

                                                              getDeviatedStudents();
                                                              term.termcourses
                                                                  .remove(
                                                                      course);
                                                              posEdited = true;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: Text(
                                                      course.coursename,
                                                      style: TextStyle(
                                                          fontSize: 12.0),
                                                    ),
                                                  );
                                                }),
                                                SizedBox(
                                                    height:
                                                        8.0), // Add space between course tiles
                                                AddCourseButton(
                                                  onCourseAdded: (course) {
                                                    setState(() {
                                                      int syIndex = widget
                                                          .studentpos
                                                          .schoolYears
                                                          .indexOf(year);
                                                      int termIndex = widget
                                                          .studentpos
                                                          .schoolYears[syIndex]
                                                          .terms
                                                          .indexOf(term);
                                                      widget
                                                          .studentpos
                                                          .schoolYears[syIndex]
                                                          .terms[termIndex]
                                                          .termcourses
                                                          .add(course);
                                                      posEdited = true;

                                                      if (!isStillDeviated(
                                                          widget
                                                              .studentpos
                                                              .schoolYears[
                                                                  syIndex]
                                                              .terms[termIndex]
                                                              .name,
                                                          findSYTerm(course),
                                                          course)) {
                                                        for (int i = 0;
                                                            i <
                                                                widget
                                                                    .student
                                                                    .deviatedCourses
                                                                    .length;
                                                            i++) {
                                                          if (widget
                                                                  .student
                                                                  .deviatedCourses[
                                                                      i]
                                                                  .coursecode ==
                                                              course
                                                                  .coursecode) {
                                                            widget.student
                                                                .deviatedCourses
                                                                .removeAt(i);
                                                          }
                                                        }
                                                      }

                                                      getDeviatedStudents();
                                                    });
                                                  },
                                                  allCourses: courses,
                                                  selectedStudentPOS:
                                                      widget.studentpos,
                                                  syAndTerm:
                                                      "${widget.studentpos.schoolYears[widget.studentpos.schoolYears.indexOf(year)].name} ${widget.studentpos.schoolYears[widget.studentpos.schoolYears.indexOf(year)].terms[widget.studentpos.schoolYears[widget.studentpos.schoolYears.indexOf(year)].terms.indexOf(term)].name}",
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  8.0), // Add space between sub-expansion tiles
                                        ];
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return SizedBox(
                          height: MediaQuery.sizeOf(context).height / 0.5,
                          width: MediaQuery.sizeOf(context).width / 3,
                          child: SingleChildScrollView(
                            child: Card(
                              elevation: 4.0,
                              margin: EdgeInsets.all(8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: widget.studentpos.schoolYears
                                      .expand<Widget>((year) {
                                    return [
                                      Container(
                                        color: Colors.blue.withOpacity(0.3),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _buildSchoolYearRow(year),
                                          ],
                                        ),
                                      ),
                                      ...year.terms.expand<Widget>((term) {
                                        return [
                                          Container(
                                            color:
                                                Colors.green.withOpacity(0.3),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                _buildTermRow(term),
                                              ],
                                            ),
                                          ),
                                          if (getCurrentSYandTerm()
                                                  .contains(term.name) &&
                                              getCurrentSYandTerm()
                                                  .contains(year.name))
                                            Row(
                                              children: widget
                                                  .student.deviatedCourses
                                                  .map<Widget>((devCourse) =>
                                                      _buildSuggestedCourseRow(
                                                          devCourse,
                                                          year,
                                                          term))
                                                  .toList(),
                                            ),
                                          Row(
                                            children: term.termcourses
                                                .map<Widget>((course) {
                                              return Expanded(
                                                child: _buildCourseRow(course,
                                                    year.name, term.name),
                                              );
                                            }).toList(),
                                          ),
                                        ];
                                      }).toList(),
                                    ];
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Thesis Courses List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height:
                            8), // Optional: Adjust the space from top if needed
                    Center(
                      child: DataTable(
                        columns: columns,
                        rows: rows,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DataTable(
                      columns: [
                        DataColumn(
                            label: Text(
                          'Form Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Enrollment Stage',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Adviser Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Lead Panel',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Passed Comprehensive Examinations',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Certificate of Academic Completion',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Actions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text('EN-19 Form')),
                          DataCell(Text(widget.en19!.enrollmentStage)),
                          DataCell(Text(widget.en19!.adviserName)),
                          DataCell(Text(widget.en19!.leadPanel)),
                          DataCell(Icon(
                            widget.en19!.passedComprehensiveExams
                                ? Icons.check_circle_outline
                                : Icons.cancel,
                            color: widget.en19!.passedComprehensiveExams
                                ? Colors.green
                                : Colors.red,
                          )),
                          DataCell(Icon(
                            widget.en19!.submittedCertificate
                                ? Icons.check_circle_outline
                                : Icons.cancel,
                            color: widget.en19!.submittedCertificate
                                ? Colors.green
                                : Colors.red,
                          )),
                          DataCell(Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.file_download),
                                    onPressed: downloadEN19File,
                                    tooltip: 'Download EN-19 Form',
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.attach_file),
                                    onPressed: uploadEN19File,
                                    tooltip:
                                        'Upload EN-19 Form, make sure that the uploaded EN-19 form is signed',
                                  ),
                                ],
                              ),
                            ],
                          )),
                        ]),
                        DataRow(
                          cells: [
                            //Title Cell
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Defense Form',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Verdict: ${widget.en19!.verdict}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: () {
                                        switch (widget.en19!.verdict
                                            .toLowerCase()) {
                                          case 'passed':
                                            return Colors.green;
                                          case 'failed':
                                            return Colors.red;
                                          case 'redefense':
                                            return Colors.orange;
                                          default:
                                            return const Color.fromARGB(
                                                77, 0, 0, 0);
                                        }
                                      }(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              TextButton(
                                onPressed: () async {
                                  String fileName =
                                      '${widget.studentpos.idnumber}/Defense Forms/Official_Receipt_${widget.studentpos.displayname['lastname']}_${widget.studentpos.displayname['firstname']}.pdf';
                                  try {
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
                                child: Text(
                                  'Download official receipt',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                            //Receipt Cell
                            DataCell(
                              Text(''),
                            ),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.file_download),
                                  onPressed: () async {
                                    String fileName =
                                        '${widget.studentpos!.idnumber}/Defense Forms/EN-18DefenseForm_${widget.studentpos!.idnumber}.pdf';
                                    try {
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
                                  tooltip: 'Download EN-18 Defense Form',
                                ),
                                        Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.attach_file),
                                      onPressed: modifyDefenseForm,
                                      tooltip:
                                          'Upload EN-18 Form',
                                    ),
                                  ],
                                ),
                              ],
                            )),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }

  DataCell buildDocDataCell(
    Course course,
    BuildContext context,
    String reference,
  ) {
    // Get the download URL of the file from Firebase Storage
    Reference emptyReference =
        FirebaseStorage.instance.ref(); // Or any other path

    return DataCell(
      SizedBox(
        width: MediaQuery.of(context).size.width / 7,
        child: FutureBuilder<ListResult>(
          future: documentations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              var files = snapshot.data!.items;

              // Find the file with the specified course code
              var file = files.firstWhere(
                  (file) => file.name.contains(course.coursecode),
                  orElse: (() => emptyReference));

              if (file != emptyReference) {
                return ListTile(
                  title: Text(
                    file.name,
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () async {
                          final imageUrl = await FirebaseStorage.instance
                              .ref()
                              .child(reference)
                              .getDownloadURL();
                          if (await canLaunch(imageUrl.toString())) {
                            await launch(imageUrl.toString());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to download file'),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                );
              } else {
                // No file found for the course code
                return ListTile(
                  title: Text(
                    'No file attached',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              }
            } else {
              return Center(
                child: Text('No data'),
              );
            }
          },
        ),
      ),
    );
  }

  DataRow isCoursePassed(Course course, BuildContext context) {
    final bool isPassed = widget.studentpos.pastCourses.any((pastCourse) =>
        pastCourse.coursecode == course.coursecode && pastCourse.grade >= 2.0);
    final bool isNotPassed = widget.studentpos.pastCourses.any((pastCourse) =>
        pastCourse.coursecode == course.coursecode && pastCourse.grade < 2.0);
    final bool isInProgress = widget.studentpos.enrolledCourses.any(
        (enrolledCourse) => enrolledCourse.coursecode == course.coursecode);
    final bool isNotEnrolled = !isPassed && !isNotPassed && !isInProgress;

    Color color;
    IconData icon;
    String status;

    if (isPassed) {
      color = Colors.green;
      icon = Icons.check;
      status = 'Passed';
    } else if (isNotPassed) {
      color = Colors.red;
      icon = Icons.running_with_errors_outlined;
      status = 'Not Passed';
    } else if (isInProgress) {
      color = Colors.orange;
      icon = Icons.incomplete_circle;
      status = 'In Progress';
    } else {
      color = Colors.grey;
      icon = Icons.error;
      status = 'Not Enrolled';
    }

    return DataRow(cells: [
      DataCell(Text(
        course.coursecode,
        style: TextStyle(color: color),
      )),
      DataCell(Text(course.coursename, style: TextStyle(color: color))),
      DataCell(Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          SizedBox(width: 5),
          Text(status, style: TextStyle(color: color)),
        ],
      )),
      buildDocDataCell(course, context,
          "${widget.studentpos.idnumber}/${course.coursecode}_${widget.studentpos.idnumber}.pdf")
    ]);
  }

  List<DataColumn> columns = [
    DataColumn(
        label: Text(
      'Course Code',
      style: TextStyle(fontWeight: FontWeight.bold),
    )),
    DataColumn(
        label: Text(
      'Course Name',
      style: TextStyle(fontWeight: FontWeight.bold),
    )),
    DataColumn(
        label: Text(
      'Status',
      style: TextStyle(fontWeight: FontWeight.bold),
    )),
    DataColumn(
        label: Text(
      'Document ',
      style: TextStyle(fontWeight: FontWeight.bold),
    )),
  ];
  Widget _buildSchoolYearRow(SchoolYear year) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Text(
        "S.Y ${year.name}",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTermRow(Term term) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Text(
        term.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> retrieveEN19Form() async {
    EN19Form? form = await EN19Form.getFormFromFirestore(widget.studentpos.uid);

    setState(() {
      widget.en19 = form;
    });
  }

  Future<void> uploadEN19File() async {
    bool confirmSign = false;
    bool signedByGSC = false;
    bool signedByAdviser = false;
    bool passedExaminations = false;
    bool submittedCertificate = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: AlertDialog(
              title: Text('Confirm Signatories'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Please confirm that the document that will be\nuploaded is signed by the Coordinator and the Adviser.'),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Signed by Coordinator?',
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: signedByGSC,
                        onChanged: (bool? value) {
                          setState(() {
                            signedByGSC = value!;
                          });
                        },
                      ),
                      Text('Yes'),
                      Radio<bool>(
                        value: false,
                        groupValue: signedByGSC,
                        onChanged: (bool? value) {
                          setState(() {
                            signedByGSC = value!;
                          });
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Signed by adviser?',
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: signedByAdviser,
                        onChanged: (bool? value) {
                          setState(() {
                            signedByAdviser = value!;
                          });
                        },
                      ),
                      Text('Yes'),
                      Radio<bool>(
                        value: false,
                        groupValue: signedByAdviser,
                        onChanged: (bool? value) {
                          setState(() {
                            signedByAdviser = value!;
                          });
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                  Text(
                    'Evaluations:',
                    style: TextStyle(fontSize: 15),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckboxListTile(
                        title: Text('Passed Comprehensive Examinations'),
                        value: passedExaminations,
                        onChanged: (bool? value) {
                          setState(() {
                            passedExaminations = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Submitted Certificate of Completion'),
                        value: submittedCertificate,
                        onChanged: (bool? value) {
                          setState(() {
                            submittedCertificate = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    confirmSign = false;
                    Navigator.pop(context, false); // No, do not delete
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() async {
                      confirmSign = true;
                      if (confirmSign) {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        if (result != null) {
                          PlatformFile file = result.files.first;
                          String fileName =
                              '${widget.studentpos.idnumber}/Defense Forms/EN-19Form_${widget.studentpos.idnumber}.pdf';
                          Uint8List fileBytes = file.bytes!;

                          // Create EN19Form object
                          EN19Form form = EN19Form(
                            proposedTitle: widget.en19!.proposedTitle,
                            lastName: _capitalize(
                                widget.studentpos.displayname['lastname']!),
                            firstName: _capitalize(
                                widget.studentpos.displayname['firstname']!),
                            middleName: '',
                            idNumber: widget.studentpos.idnumber.toString(),
                            college: 'Computer Studies',
                            program: widget.studentpos.degree,
                            passedComprehensiveExams: passedExaminations,
                            submittedCertificate: submittedCertificate,
                            adviserName: widget.en19!.adviserName,
                            enrollmentStage: widget.en19!.enrollmentStage,
                            date: DateTime.now(),
                            leadPanel: widget.en19!.leadPanel,
                            panelMembers: [],
                            defenseDate: widget.en19!.defenseDate,
                            signedByGSC: signedByGSC,
                            signedByAdviser: signedByAdviser,
                            defenseTime: widget.en19!.defenseTime,
                            mainTitle: widget.en19!.mainTitle,
                            defenseType: widget.en19!.defenseType,
                            verdict: widget.en19!.verdict,
                          );

                          form.saveFormToFirestore(form, widget.studentpos.uid);
                          final ref =
                              FirebaseStorage.instance.ref().child(fileName);

                          await ref.putData(fileBytes);
                          setState(() {
                            retrieveEN19Form();
                          });

                          print('File uploaded successfully');
                          Navigator.pop(context, true);
                        } else {
                          print('No file selected');
                        }
                      }
                    });

                    Navigator.pop(context, true); // Yes, delete
                  },
                  child: Text('Proceed'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildSuggestedCourseRow(Course course, SchoolYear year, Term term) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            // Add the course to the POS in the specified school year and term
            setState(() {
              int syIndex = widget.studentpos.schoolYears.indexOf(year);
              int termIndex =
                  widget.studentpos.schoolYears[syIndex].terms.indexOf(term);

              for (int i = 0; i < widget.student.deviatedCourses.length; i++) {
                if (widget.student.deviatedCourses[i].coursecode ==
                    course.coursecode) {
                  widget.student.deviatedCourses.removeAt(i);
                }
              }

              for (int i = 0; i < widget.studentpos.schoolYears.length; i++) {
                for (int j = 0;
                    j < widget.studentpos.schoolYears[i].terms.length;
                    j++) {
                  for (int k = 0;
                      k <
                          widget.studentpos.schoolYears[i].terms[j].termcourses
                              .length;
                      k++) {
                    for (int a = 0;
                        a <
                            widget.studentpos.schoolYears[i].terms[j]
                                .termcourses.length;
                        a++) {
                      if (widget.studentpos.schoolYears[i].terms[j]
                              .termcourses[a].coursecode ==
                          course.coursecode) {
                        widget.studentpos.schoolYears[i].terms[j].termcourses
                            .removeAt(a);
                      }
                    }
                  }
                }
              }
              widget
                  .studentpos.schoolYears[syIndex].terms[termIndex].termcourses
                  .add(course);
              posEdited = true;

              isStillDeviated(
                  widget.studentpos.schoolYears[syIndex].terms[termIndex].name,
                  findSYTerm(course),
                  course);
              getDeviatedStudents();
            });
          },
          child: ListTile(
            title: Text(
              course.coursecode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            subtitle: Text(
              course.coursename,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseRow(Course course, String year, String term) {
    bool isCourseDone = (widget.studentpos.pastCourses
        .any((element) => element.coursecode == course.coursecode));
    bool isCourseIP = (widget.studentpos.enrolledCourses
        .any((element) => element.coursecode == course.coursecode));
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              course.coursecode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCourseDone
                    ? Colors.green
                    : isCourseIP
                        ? Colors.orange
                        : Colors.black,
              ),
            ),
          ),
          Tooltip(
            message: generateStudentList(
                "$year $term", course), // Display the list of students
            child: Icon(
              Icons.info_outline,
              color: Colors.blue,
              size: 16,
            ),
          ),
        ],
      ),
      subtitle: Text(
        course.coursename,
        style: TextStyle(
          fontSize: 12,
          color: isCourseDone
              ? Colors.green
              : isCourseIP
                  ? Colors.orange
                  : Colors.black,
        ),
      ),
    );
  }

  String generateStudentList(String syAndTerm, Course targetCourse) {
    String fulfillingStudentPOS = '';
    // Get the next SY and term
    List<String> sytermParts = syAndTerm.split(" ");

    for (int i = 0; i < studentPOSList.length; i++) {
      StudentPOS pos = studentPOSList[i];
      for (int j = 0; j < pos.schoolYears.length; j++) {
        SchoolYear sy = pos.schoolYears[j];
        if (sytermParts[0] == sy.name) {
          for (int k = 0; k < sy.terms.length; k++) {
            Term term = sy.terms[k];
            if (term.name == '${sytermParts[1]} ${sytermParts[2]}') {
              for (Course course in term.termcourses) {
                if (course.coursecode == targetCourse.coursecode) {
                  fulfillingStudentPOS +=
                      "${pos.idnumber}: ${pos.displayname['firstname']} ${pos.displayname['lastname']}\n";
                }
              }
            }
          }
        }
      }
    }
    if (fulfillingStudentPOS == '') {
      return "Students who will take the ${targetCourse.coursecode} on $syAndTerm:\nNo students found";
    } else {
      return "Students who will take the ${targetCourse.coursecode} on $syAndTerm:\n$fulfillingStudentPOS";
    }
  }

  Future<void> uploadDocFile(String coursecode) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName =
          '${widget.studentpos.idnumber}/Documentations/${coursecode}_${widget.studentpos.idnumber}.pdf';

      Uint8List fileBytes = file.bytes!;
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putData(fileBytes);
    }

    setState(() {
      documentations = FirebaseStorage.instance
          .ref('/${widget.studentpos.idnumber}/Documentations')
          .listAll();
      defenseForms = FirebaseStorage.instance
          .ref('/${widget.studentpos.idnumber}/Defense Forms')
          .listAll();
    });
  }
}

class Coursetest {
  final String courseName;
  final String courseCode;

  Coursetest({required this.courseName, required this.courseCode});
}

class Section {
  final String sectionName;
  final List<Coursetest> courses;
  bool isExpanded;

  Section(
      {required this.sectionName,
      required this.courses,
      this.isExpanded = false});
}
