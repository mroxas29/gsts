import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  String uid;
  String coursecode;
  String coursename;
  bool isactive;
  String facultyassigned;
  int numstudents;
  int units;
  String type;
  String program;
  String setup;
  List<Map<String, String>> dayTimes;
  String syAndTerm; // auto-generated
  String section; // New section field
  String roomNum;
  String? onlineDay; // New onlineDay field

  Course({
    required this.uid,
    required this.coursecode,
    required this.coursename,
    required this.isactive,
    required this.facultyassigned,
    required this.numstudents,
    required this.units,
    required this.type,
    required this.program,
    required this.setup,
    required this.dayTimes,
    required this.syAndTerm,
    required this.section, // Initialize section
    required this.roomNum,
    this.onlineDay, // Initialize onlineDay
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "coursecode": coursecode,
      "coursename": coursename,
      "isactive": isactive,
      "facultyassigned": facultyassigned,
      "numstudents": numstudents,
      "units": units,
      "type": type,
      "program": program,
      "setup": setup,
      "dayTimes": dayTimes,
      "syAndTerm": syAndTerm,
      "section": section, // Add section to JSON
      "roomNum": roomNum,
      "onlineDay": onlineDay, // Add onlineDay to JSON
    };
  }

  // Add this constructor to create a Course object from a map
  Course.fromMap(Map<String, dynamic> map)
      : uid = map['uid'],
        roomNum = map['roomNum'],
        setup = map['setup'],
        coursecode = map['coursecode'],
        coursename = map['coursename'],
        isactive = map['isactive'],
        facultyassigned = map['facultyassigned'],
        numstudents = map['numstudents'],
        units = map['units'],
        type = map['type'],
        program = map['program'],
        dayTimes = List<Map<String, String>>.from(map['dayTimes']),
        syAndTerm = map['syAndTerm'],
        section = map['section'], // Initialize section from map
        onlineDay = map['onlineDay']; // Initialize onlineDay from map

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'coursecode': coursecode,
      'coursename': coursename,
      'isactive': isactive,
      'facultyassigned': facultyassigned,
      'numstudents': numstudents,
      'units': units,
      'type': type,
      'program': program,
      'setup': setup,
      'dayTimes': dayTimes,
      'syAndTerm': syAndTerm,
      'section': section, // Add section to map
      'roomNum': roomNum,
      'onlineDay': onlineDay, // Add onlineDay to map
    };
  }
}

List<Course> courses = [];
List<Course> activecourses = [];
List<Course> inactivecourses = [];
List<Course> remedialcourses = [];
List<Course> foundationcourses = [];
List<Course> electivecourses = [];
List<Course> capstonecourses = [];
List<Course> examcourses = [];
List<Course> specializedcourses = [];
List<Course> thesiscourses = [];
final blankCourse = Course(
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
);
Future<List<Course>> getCoursesFromFirestore() async {
  courses.clear();
  activecourses.clear();
  inactivecourses.clear();
  remedialcourses.clear();
  foundationcourses.clear();
  electivecourses.clear();
  capstonecourses.clear();
  examcourses.clear();
  thesiscourses.clear();

  print("Add course from FS executed");
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection('courses').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> document
        in querySnapshot.docs) {
      Map<String, dynamic> courseData = document.data();

      // Convert dayTimes back to the desired format
      List<Map<String, String>> dayTimes = [];
      if (courseData['dayTimes'] != null) {
        courseData['dayTimes'].forEach((day, times) {
          dayTimes
              .add({'day': day, 'start': times['start'], 'end': times['end']});
        });
      }

      Course newCourse = Course(
          uid: document.id,
          setup: courseData['setup'],
          coursecode: courseData['coursecode'],
          coursename: courseData['coursename'],
          isactive: courseData['isactive'],
          facultyassigned: courseData['facultyassigned'],
          numstudents: courseData['numstudents'],
          units: courseData['units'],
          type: courseData['type'],
          program: courseData['program'],
          dayTimes: dayTimes,
          syAndTerm: courseData['syAndTerm'],
          section: courseData['section'], // Initialize section from Firestore
          roomNum: courseData['roomNum'],
          onlineDay: courseData['onlineDay'] // Add onlineDay field
          );

      print(newCourse.uid);

      courses.add(newCourse);

      if (newCourse.isactive == true) {
        activecourses.add(newCourse);
      } else {
        inactivecourses.add(newCourse);
      }

      if (newCourse.type.toLowerCase().contains('foundation')) {
        foundationcourses.add(newCourse);
      }

      if (newCourse.type.toLowerCase().contains('remedial')) {
        remedialcourses.add(newCourse);
      }

      if (newCourse.type.toLowerCase().contains('elective')) {
        electivecourses.add(newCourse);
      }

      if (newCourse.type.toLowerCase().contains('capstone')) {
        capstonecourses.add(newCourse);
      }

      if (newCourse.type.toLowerCase().contains('exam')) {
        examcourses.add(newCourse);
      }

      if (newCourse.type.toLowerCase().contains('specialized')) {
        specializedcourses.add(newCourse);
      }

      if (newCourse.type.toLowerCase().contains('thesis')) {
        thesiscourses.add(newCourse);
      }
    }
  } catch (e) {
    print("Error fetching courses from Firestore: $e");
  }

  courses.sort((a, b) => a.coursecode.compareTo(b.coursecode));

  List<String> desiredThesisOrder = [
    'CIS801M', // Methods of Research
    'THWR1', // Thesis Writing 1
    'THPROD', // Thesis Proposal Defense
    'THWR2', // Thesis Writing 2
    'THFIND', // Thesis Final Defense
  ];

  // Sort thesiscourses list based on the desired order
  thesiscourses.sort((a, b) {
    int indexA = desiredThesisOrder.indexOf(a.coursecode);
    int indexB = desiredThesisOrder.indexOf(b.coursecode);
    return indexA.compareTo(indexB);
  });

  List<String> desiredCapstoneOrder = [
    'CIS411M',
    'Capstone Project Proposal',
    'Capstone Project Final',
  ];

  capstonecourses.sort((a, b) {
    int indexA = desiredCapstoneOrder.indexOf(a.coursecode);
    int indexB = desiredCapstoneOrder.indexOf(b.coursecode);

    // If either course is CIS411M, prioritize it
    if (a.coursecode == 'CIS411M') {
      return -1; // Put a before b
    } else if (b.coursecode == 'CIS411M') {
      return 1; // Put b before a
    }

    // Otherwise, sort based on their index in desiredCapstoneOrder
    return indexA.compareTo(indexB);
  });

  return courses;
}
