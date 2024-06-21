import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/api/email/invoice_service.dart';
import 'package:sysadmindb/app/models/DeviatedStudents.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/en-19.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/ui/deRF_dialog.dart';
import 'package:sysadmindb/ui/forms/addcourse.dart';
import 'package:sysadmindb/ui/dashboard/gsc_dash.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

class StudentInfoPage extends StatefulWidget {
  final Student student;
  StudentPOS studentpos;
  EN19Form? en19;
  StudentInfoPage(
      {required this.student, required this.studentpos, required this.en19});

  @override
  StudentInfoPageState createState() => StudentInfoPageState();
}

late Future<ListResult> documentations;
late Future<ListResult> defenseForms;

class StudentInfoPageState extends State<StudentInfoPage>
    with SingleTickerProviderStateMixin {
  bool studentDeviated = false;
  late TabController _tabController;
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
          "${widget.studentpos.idnumber}/Documentations/${course.coursecode}_${widget.studentpos.idnumber}.pdf")
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
                              '${widget.student!.idnumber}/Defense Forms/EN-19Form_${widget.student!.idnumber}.pdf';
                          Uint8List fileBytes = file.bytes!;

                          // Create EN19Form object
                          EN19Form form = EN19Form(
                            proposedTitle: widget.en19!.proposedTitle,
                            lastName: _capitalize(
                                widget.student!.displayname['lastname']!),
                            firstName: _capitalize(
                                widget.student!.displayname['firstname']!),
                            middleName: '',
                            idNumber: widget.student!.idnumber.toString(),
                            college: 'Computer Studies',
                            program: widget.student!.degree,
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

                          form.saveFormToFirestore(form, widget.student!.uid);
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

  Widget _buildTermRow(Term term) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Text(
        term.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
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
    bool isCourseDone = (widget.student.pastCourses
        .any((element) => element.coursecode == course.coursecode));
    bool isCourseIP = (widget.student.enrolledCourses
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
        .doc(widget.student.uid)
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
  }

  Student fetchStudentInfo(Student student) {
    // Replace this with your actual data fetching logic
    // For now, dummy data is used for illustration

    return Student(
        uid: student.uid,
        displayname: student.displayname,
        role: student.role,
        email: student.email,
        idnumber: student.idnumber,
        enrolledCourses: student.enrolledCourses,
        pastCourses: student.pastCourses,
        degree: student.degree,
        status: student.status);
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
      setState(() {
        studentDeviated = true;
      });
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

  bool posEdited = false;

  PlatformFile? pickedFile;
  final PdfInvoiceService service = PdfInvoiceService();

  List<Course> recommendedRemedialCourses = [];
  List<Course> recommendedPriorityCourses = [];
  bool _showDialog = false; // Flag to control dialog visibility

  @override
  void initState() {
    super.initState();
    documentations = FirebaseStorage.instance
        .ref('/${widget.studentpos.idnumber}/Documentations')
        .listAll();
    defenseForms = FirebaseStorage.instance
        .ref('/${widget.student!.idnumber}/Defense Forms')
        .listAll();
    _tabController = TabController(length: 3, vsync: this);
    if (_tabController.index == 2 &&
        newStudentList.any((newStudent) =>
            newStudent.idnumber == widget.student.idnumber &&
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

  Future<void> downloadEN19File() async {
    String fileName =
        '${widget.student.idnumber}/Defense Forms/EN-19Form_${widget.student.idnumber}.pdf';

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
    bool exists = await EN19Form.hasEn19Form(widget.student.uid);
    setState(() {
      hasEn19Form = exists;
    });
  }

  Future<void> uploadGeneratedPdf(Uint8List data) async {
    String fileName =
        '${widget.student!.idnumber}/Defense Forms/EN-19Form_${widget.student!.idnumber}.pdf';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.putData(data);
    print('Generated PDF uploaded successfully');
  }

  Future<void> modifyDefenseForm(BuildContext context) async {
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      widget.student.displayname['lastname']!),
                                  firstName: _capitalize(
                                      widget.student.displayname['firstname']!),
                                  middleName: '',
                                  idNumber: widget.student.idnumber.toString(),
                                  college: 'Computer Studies',
                                  program: widget.student.degree,
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
                                    form, widget.student.uid);
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles();

                                PlatformFile file = result!.files.first;
                                String fileName =
                                    '${widget.student!.idnumber}/Defense Forms/EN-18DefenseForm_${widget.student!.idnumber}.pdf';
                                Uint8List fileBytes = file.bytes!;

                                final ref = FirebaseStorage.instance
                                    .ref()
                                    .child(fileName);

                                await ref.putData(fileBytes);
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

  Future<void> retrieveEN19Form() async {
    EN19Form? form = await EN19Form.getFormFromFirestore(widget.student.uid);

    setState(() {
      widget.en19 = form;
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

    Student studentInfo = fetchStudentInfo(widget.student);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.student.displayname['firstname']}\'s profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Student Information'),
            Tab(text: 'Program of Study'),
            Tab(
              text: (widget.student.degree == 'MIT')
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
                                        "${_capitalize(studentInfo.displayname['firstname']!)} ${_capitalize(studentInfo.displayname['lastname']!)} ",
                                        style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 23, 71, 25)),
                                      ),
                                      Text(studentInfo.degree.contains('MSIT')
                                          ? 'Master of Science in Information Technology - ${studentInfo.idnumber.toString()}'
                                          : 'Master in Information Technology - ${studentInfo.idnumber.toString()}'),
                                      Text(studentInfo.email),
                                      Text(
                                          'Enrollment Status: ${studentInfo.status}'),
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
                                        itemCount:
                                            studentInfo.enrolledCourses.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final enrolledCourse = studentInfo
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
                                        itemCount:
                                            studentInfo.pastCourses.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final pastCourse =
                                              studentInfo.pastCourses[index];
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
                        TextButton(
                          onPressed: () async {
                            String? hostname = html.window.location.hostname;
                            int port = html.window.location.port.isEmpty
                                ? 80
                                : int.parse(html.window.location.port);

                            // html.window.open( 'http://localhost:$port/assets/pdfs/RoxasResume.pdf','_blank');
                            final data =
                                await service.createInvoice(widget.studentpos);
                            service.savePdfFile(
                                "POS_${widget.studentpos.idnumber}.pdf", data);
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
                        SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            // Inside your widget where you want to show the dialog

                            showCourseDialog(
                              context: context,
                              recommendedPriorityCourses:
                                  recommendedPriorityCourses,
                              recommendedRemedialCourses:
                                  recommendedRemedialCourses,
                              onCheckboxChanged: (bool? value) {
                                setState(() {
                                  isEng501MChecked = value ?? false;
                                });
                              },
                              onDownloadPressed: () async {
                                final data =
                                    await service.createRecommendationForm(
                                  widget.studentpos,
                                  recommendedRemedialCourses,
                                  recommendedPriorityCourses,
                                  isEng501MChecked,
                                );
                                await service.savePdfFile(
                                  "DeRF_${widget.studentpos.idnumber}.pdf",
                                  data,
                                );

                                if (widget.student.degree
                                    .toLowerCase()
                                    .contains('mit')) {
                                  setState(() {
                                    widget.studentpos = generatePOSforMIT(
                                      widget.student,
                                      widget.studentpos,
                                      studentPOSList,
                                      courses,
                                    );
                                  });
                                } else if (widget.student.degree
                                    .toLowerCase()
                                    .contains('msit')) {
                                  setState(() {
                                    widget.studentpos = generatePOSforMSIT(
                                      widget.student,
                                      widget.studentpos,
                                      studentPOSList,
                                      courses,
                                    );
                                    shownRecoGuide = true;
                                  });
                                }
                                Navigator.pop(context, true);
                              },
                            );
                          }, // Disable the button when no course is added
                          child: Text("Download Recommendation Form"),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // Implement logic to save studentPOS
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirm clear?'),
                                  content: Text(
                                      "Are you sure you want to clear this student's pos?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context,
                                            false); // No, do not delete
                                      },
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          for (SchoolYear sy in widget
                                              .studentpos.schoolYears) {
                                            for (Term term in sy.terms) {
                                              term.termcourses.clear();
                                            }
                                          }
                                        });
                                        Navigator.pop(
                                            context, true); // Yes, delete
                                      },
                                      child: Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }, // Disable the button when no course is added
                          child: Text("Clear student pos"),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.studentpos.enrolledCourses.isEmpty
                            ? Text(
                                " ",
                                style: TextStyle(fontSize: 14),
                              )
                            : Text(
                                "Student enrolled in:",
                                style: TextStyle(fontSize: 14),
                              ),
                        for (Course course in widget.studentpos.enrolledCourses)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Course ${course.coursecode}: ${course.coursename} supposed to be taken on ${findSYTerm(course)}",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
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
                      // Allow horizontal scrolling
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
                                          style: TextStyle(fontSize: 16.0),
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
                                                style:
                                                    TextStyle(fontSize: 14.0),
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
                                                              recommendedRemedialCourses
                                                                  .removeWhere((toremove) =>
                                                                      toremove
                                                                          .coursecode ==
                                                                      course
                                                                          .coursecode);

                                                              recommendedPriorityCourses
                                                                  .removeWhere((toremove) =>
                                                                      toremove
                                                                          .coursecode ==
                                                                      course
                                                                          .coursecode);
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
                                                      int totalunits = widget
                                                          .studentpos
                                                          .schoolYears[syIndex]
                                                          .terms[termIndex]
                                                          .termcourses
                                                          .fold(
                                                              0,
                                                              (total, course) =>
                                                                  total +
                                                                  course.units);

                                                      if (widget.studentpos
                                                                  .status ==
                                                              'Part Time' &&
                                                          totalunits > 6) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Units Exceeding'),
                                                              content: Text(
                                                                  "The student is a ${widget.studentpos.status} student, it is recommended that they take at most 6 units per term."),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      widget
                                                                          .studentpos
                                                                          .schoolYears[
                                                                              syIndex]
                                                                          .terms[
                                                                              termIndex]
                                                                          .termcourses
                                                                          .remove(
                                                                              course);
                                                                    });

                                                                    Navigator.pop(
                                                                        context,
                                                                        false); // No, do not delete
                                                                  },
                                                                  child: Text(
                                                                      "Don't add"),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        false); // No, do not delete
                                                                  },
                                                                  child: Text(
                                                                      'Add course'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }

                                                      if (widget.studentpos
                                                                  .status ==
                                                              'Full Time' &&
                                                          totalunits > 12) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Units Exceeding'),
                                                              content: Text(
                                                                  "The student is a ${widget.studentpos.status} student, it is recommended that they take at most 12 units per term."),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      widget
                                                                          .studentpos
                                                                          .schoolYears[
                                                                              syIndex]
                                                                          .terms[
                                                                              termIndex]
                                                                          .termcourses
                                                                          .remove(
                                                                              course);
                                                                    });

                                                                    Navigator.pop(
                                                                        context,
                                                                        false); // No, do not delete
                                                                  },
                                                                  child: Text(
                                                                      "Don't add"),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        false); // No, do not delete
                                                                  },
                                                                  child: Text(
                                                                      'Add course'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }

                                                      posEdited = true;

                                                      if (course.type ==
                                                          'Bridging/Remedial Courses') {
                                                        recommendedRemedialCourses
                                                            .add(course);
                                                      } else {
                                                        recommendedPriorityCourses
                                                            .add(course);
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
                padding: const EdgeInsets.all(8.0),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.file_upload),
                                    onPressed: uploadEN19File,
                                    tooltip:
                                        'Upload EN-19 Form, make sure that the uploaded EN-19 form is signed',
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.file_download),
                                    onPressed: downloadEN19File,
                                    tooltip: 'Download EN-19 Form',
                                  ),
                                ],
                              ),
                            ],
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Defense Form'),
                                Text(
                                  'Verdict: ${widget.en19!.verdict}',
                                  style: TextStyle(
                                    color: () {
                                      switch (
                                          widget.en19!.verdict.toLowerCase()) {
                                        case 'passed':
                                          return Colors.green;
                                        case 'failed':
                                          return Colors.red;
                                        case 'redefense':
                                          return Colors.orange;
                                        default:
                                          return Colors.black;
                                      }
                                    }(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text('')),
                          DataCell(Text(widget.en19!.adviserName)),
                          DataCell(Text(widget.en19!.leadPanel)),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.file_upload),
                                onPressed: () {
                                  modifyDefenseForm(context);
                                },
                                tooltip: 'Upload EN-18 Defense Form',
                              ),
                              IconButton(
                                icon: Icon(Icons.download),
                                tooltip: 'Download EN-18 Defense Form',
                                onPressed: () async {
                                  String fileName =
                                      '${widget.student!.idnumber}/Defense Forms/EN-18DefenseForm_${widget.student!.idnumber}.pdf';
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
                              )
                            ],
                          )),
                        ]),
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
