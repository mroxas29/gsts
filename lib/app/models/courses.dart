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

  Course(
      {required this.uid,
      required this.coursecode,
      required this.coursename,
      required this.isactive,
      required this.facultyassigned,
      required this.numstudents,
      required this.units,
      required this.type,
      required this.program});

  toJson() {
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
    };
  }

  // Add this constructor to create a Course object from a map
  Course.fromMap(Map<String, dynamic> map)
      : uid = map['uid'],
        coursecode = map['coursecode'],
        coursename = map['coursename'],
        isactive = map['isactive'],
        facultyassigned = map['facultyassigned'],
        numstudents = map['numstudents'],
        units = map['units'],
        type = map['type'],
        program = map['program'];

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
      'program': program
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
final blankCourse = Course(
    uid: 'blank',
    coursecode: 'Select a course',
    coursename: '',
    facultyassigned: '',
    units: 0,
    numstudents: 0,
    isactive: false,
    type: '',
    program: '');
Future<List<Course>> getCoursesFromFirestore() async {
  courses.clear();
  activecourses.clear();
  inactivecourses.clear();
  remedialcourses.clear();
  foundationcourses.clear();
  electivecourses.clear();
  capstonecourses.clear();
  examcourses.clear();

  print("Add course from FS executed");
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection('courses').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> document
        in querySnapshot.docs) {
      Map<String, dynamic> courseData = document.data();

      Course newCourse = Course(
          uid: document.id,
          coursecode: courseData['coursecode'],
          coursename: courseData['coursename'],
          facultyassigned: courseData['facultyassigned'],
          isactive: courseData['isactive'],
          numstudents: courseData['numstudents'],
          units: courseData['units'],
          type: courseData['type'],
          program: courseData['program']);

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
    }
 
  } catch (e) {
    print("Error fetching courses from Firestore: $e");
  }

  courses.sort((a, b) => a.coursecode.compareTo(b.coursecode));
  return courses;
}
