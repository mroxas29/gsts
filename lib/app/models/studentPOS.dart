import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/schoolYear.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/main.dart';

class StudentPOS extends Student {
  final List<SchoolYear> schoolYears;

  StudentPOS({
    required this.schoolYears,
    required String uid,
    required Map<String, String> displayname,
    required String role,
    required String email,
    required int idnumber,
    required String degree,
    required String status,
    required List<EnrolledCourseData> enrolledCourses,
    required List<PastCourse> pastCourses,
  }) : super(
            uid: uid,
            displayname: displayname,
            role: role,
            email: email,
            idnumber: idnumber,
            enrolledCourses: enrolledCourses,
            pastCourses: pastCourses,
            degree: degree,
            status: status);

  factory StudentPOS.fromJson(Map<String, dynamic> json) {
    final List<dynamic> schoolYearsJson = json['schoolYears'] ?? [];
    final List<SchoolYear> schoolYears = schoolYearsJson
        .map(
            (yearJson) => SchoolYear.fromJson(yearJson as Map<String, dynamic>))
        .toList();

    return StudentPOS(
        schoolYears: schoolYears,
        uid: json['uid'],
        displayname: Map<String, String>.from(
            json['displayname'] as Map<String, dynamic>),
        role: json['role'],
        email: json['email'],
        idnumber: json['idnumber'],
        enrolledCourses: (json['enrolledCourses'] as List<dynamic>)
            .map<EnrolledCourseData>((courseJson) {
          return EnrolledCourseData.fromJson(
              courseJson as Map<String, dynamic>);
        }).toList(),
        pastCourses: (json['pastCourses'] as List<dynamic>)
            .map<PastCourse>((courseJson) {
          return PastCourse.fromJson(courseJson as Map<String, dynamic>);
        }).toList(),
        degree: json['degree'],
        status: json['status']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'schoolYears': schoolYears.map((year) => year.toJson()).toList(),
    };
    data.addAll(super.toJson());
    return data;
  }
}

void studentPOSDefault() {
  studentPOS = StudentPOS(
      schoolYears: defaultschoolyears,
      uid: currentStudent!.uid,
      displayname: currentStudent!.displayname,
      role: currentStudent!.role,
      email: currentStudent!.email,
      idnumber: currentStudent!.idnumber,
      enrolledCourses: currentStudent!.enrolledCourses,
      pastCourses: currentStudent!.pastCourses,
      degree: currentStudent!.degree,
      status: currentStudent!.status);
}

List<SchoolYear> defaultschoolyears = List.generate(3, (index) {
  final currentYear = DateTime.now().year;
  final schoolYearName = '${currentYear + index} - ${currentYear + index + 1}';
  final terms = List<Term>.generate(3, (termIndex) {
    return Term('Term ${termIndex + 1}', []);
  });
  return SchoolYear(schoolYearName, terms);
});
List<Term> defaultTerm = List<Term>.generate(3, (termIndex) {
  return Term('Term ${termIndex + 1}', []);
});
Future<StudentPOS> retrieveStudentPOS(String uid) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DocumentReference documentReference =
      firestore.collection('studentpos').doc(uid); // Use provided UID

  try {
    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      // Document exists, retrieve data
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        // Create a StudentPOS object from the retrieved data

        initializeSchoolYears();
        studentPOS = StudentPOS.fromJson(data);
        // Now you can use the studentPOS object as needed
      } else {
        print('Document data is null');
      }
    } else {
      print('Document does not exist for $uid');

      initializeSchoolYears();
      studentPOSDefault();
    }
  } catch (e) {
    print('Error retrieving document for Student POS: $e');
  }

  return studentPOS;
}

Future<List<StudentPOS>> retrieveAllPOS() async {
  studentPOSList.clear();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference collectionReference =
      firestore.collection('studentpos');

  try {
    QuerySnapshot querySnapshot = await collectionReference.get();

    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      if (documentSnapshot.exists) {
        // Retrieve data
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          // Create a StudentPOS object from the retrieved data
          StudentPOS studentPOS = StudentPOS.fromJson(data);
          studentPOSList.add(studentPOS);
        } else {
          print('Document data is null');
        }
      } else {
        print(
            'Document does not exist for document ID: ${documentSnapshot.id}');
      }
    }
  } catch (e) {
    print('Error retrieving documents from Student POS collection: $e');
  }
  return studentPOSList;
}

void initializeSchoolYears() async {
  schoolyears = studentPOS.schoolYears;
}

List<SchoolYear> schoolyears = studentPOS.schoolYears;
StudentPOS studentPOS = StudentPOS(
    schoolYears: defaultschoolyears,
    uid: currentStudent!.uid,
    displayname: currentStudent!.displayname,
    role: currentStudent!.role,
    email: currentStudent!.email,
    idnumber: currentStudent!.idnumber,
    enrolledCourses: currentStudent!.enrolledCourses,
    pastCourses: currentStudent!.pastCourses,
    degree: currentStudent!.degree,
    status: currentStudent!.status);

List<StudentPOS> studentPOSList = [];
int countCourseOccurrences(
    List<StudentPOS> studentPOSList, String courseCode, String termName) {
  // Initialize a counter for course occurrences
  int occurrences = 0;

  // Iterate over each StudentPOS in the list
  for (var studentPOS in studentPOSList) {
    // Find the desired term within the StudentPOS
    final term = studentPOS.schoolYears.expand((year) => year.terms).firstWhere(
          (term) => term.name == termName,
        );

    // If the term is found, count the occurrences of the course in that term
    if (term != null) {
      final courseCount = term.termcourses
          .where((course) => course.coursecode == courseCode)
          .length;
      occurrences += courseCount;
    }
  }
  print(occurrences);
  return occurrences;
}
StudentPOS generatePOSforMIT(
    Student student, List<StudentPOS> studentPOSList, List<Course> courses) {
  // Initialize StudentPOS object
  StudentPOS studentPOS = StudentPOS(
    schoolYears: defaultschoolyears,
    uid: student.uid,
    displayname: student.displayname,
    role: student.role,
    email: student.email,
    idnumber: student.idnumber,
    enrolledCourses: student.enrolledCourses,
    pastCourses: student.pastCourses,
    degree: student.degree,
    status: student.status,
  );

  // Get MIT program courses
  List<Course> programCourses = getMITCourses(courses);

  // Get elective courses for MIT program
  List<Course> electiveCourses = getElectiveCourses(programCourses);

  // Get foundation courses for MIT program
  List<Course> foundationCourses = getFoundationCourses(programCourses);

  // Track added courses to avoid duplication
  Set<String> addedCourses = {};

  // Distribute foundation courses and elective courses
  for (var i = 0; i < studentPOS.schoolYears.length; i++) {
    for (var term in studentPOS.schoolYears[i].terms) {
      // Distribute foundation courses
      for (var course in foundationCourses) {
        if (countCourseOccurrences(studentPOSList, course.coursecode, term.name) <
                8 &&
            !addedCourses.contains(course.coursecode)) {
          term.termcourses.add(course);
          addedCourses.add(course.coursecode);
        } else if (!addedCourses.contains(course.coursecode)) {
          // Check if the course is underrepresented across all StudentPOS instances
          bool isUnderrepresented = false;
          for (var studentPOS in studentPOSList) {
            int occurrences =
                countCourseOccurrences(studentPOSList, course.coursecode, term.name);
            if (occurrences < 8) {
              isUnderrepresented = true;
              break;
            }
          }
          // If the course is underrepresented, add it to the current term
          if (isUnderrepresented) {
            term.termcourses.add(course);
            addedCourses.add(course.coursecode);
          }
        }
      }
      // Distribute elective courses
      for (var course in electiveCourses) {
        if (countCourseOccurrences(studentPOSList, course.coursecode, term.name) <
                8 &&
            !addedCourses.contains(course.coursecode)) {
          term.termcourses.add(course);
          addedCourses.add(course.coursecode);
        } else if (!addedCourses.contains(course.coursecode)) {
          // Check if the course is underrepresented across all StudentPOS instances
          bool isUnderrepresented = false;
          for (var studentPOS in studentPOSList) {
            int occurrences =
                countCourseOccurrences(studentPOSList, course.coursecode, term.name);
            if (occurrences < 8) {
              isUnderrepresented = true;
              break;
            }
          }
          // If the course is underrepresented, add it to the current term
          if (isUnderrepresented) {
            term.termcourses.add(course);
            addedCourses.add(course.coursecode);
          }
        }
      }
      // Adjust courses for specific terms
      if (i == 1 && term.name == "Term 3") {
        // Adjust for SchoolYear[1] Term 3
        Course capProjW = courses.firstWhere(
            (course) => course.coursecode == "CIS411M",
            );
            Course oex = courses.firstWhere(
          (course) => course.coursecode == "OEX",
        );
      
        
        term.termcourses.clear();
        term.termcourses.addAll([
         capProjW,
          oex
        ]);
      } else if (i == 2 && term.name == "Term 1") {
        // Adjust for SchoolYear[2] Term 1
        Course capProjP = courses.firstWhere(
          (course) => course.coursecode == "Capstone Project Proposal",
        );
          Course capProjF = courses.firstWhere(
          (course) => course.coursecode == "Capstone Project Final",
        );
        term.termcourses.clear();
        term.termcourses.addAll([
          capProjP,
         capProjF,
        ]);
      }
    }
  }
  return studentPOS;
}

List<Course> getMITCourses(List<Course> courseList) {
  return courseList.where((course) => course.program.contains('MIT')).toList();
}

List<Course> getElectiveCourses(List<Course> courseList) {
  return courseList.where((course) => course.type.contains('Elective')).toList();
}

List<Course> getFoundationCourses(List<Course> courseList) {
  return courseList
      .where((course) => course.type.contains('Foundation'))
      .toList();
}

