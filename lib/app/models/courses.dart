import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  String uid;
  String coursecode;
  String coursename;
  bool isactive;
  String facultyassigned;
  int numstudents;
  int units;

  Course(
      {required this.uid,
      required this.coursecode,
      required this.coursename,
      required this.isactive,
      required this.facultyassigned,
      required this.numstudents,
      required this.units});

  toJson() {
    return {
      "uid": uid,
      "coursecode": coursecode,
      "coursename": coursename,
      "isactive": isactive,
      "facultyassigned": facultyassigned,
      "numstudents": numstudents + 1,
      "units": units,
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
        units = map['units'];

  Map<String, dynamic> toMap() {
    return {
      'coursecode': coursecode,
      'coursename': coursename,
      'isactive': isactive,
      'facultyassigned': facultyassigned,
      'numstudents': numstudents,
      'units': units,
    };
  }
}

List<Course> courses = [];
List<Course> activecourses =
    courses.where((course) => course.isactive).toList();
Future<List<Course>> getCoursesFromFirestore() async {
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
      );

      courses.add(newCourse);
    }
    courses.forEach((user) {
      print(user.toJson());
    });
  } catch (e) {
    print("Error fetching courses from Firestore: $e");
  }

  return courses;
}
