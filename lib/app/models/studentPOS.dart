import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/main.dart';

class StudentPOS extends Student {
  List<SchoolYear> schoolYears;

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
  var currentYear = DateTime.now().year;
  String schoolYearName = '${currentYear + index - 1}-${currentYear + index}';
  List<Term> terms = List<Term>.generate(3, (termIndex) {
    return Term('Term ${termIndex + 1}', []);
  }).toList();
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
  String testUid = '';

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

          testUid = studentPOS.uid;
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
    print(testUid);
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
  // Get MIT program courses
  List<Course> programCourses = getMITCourses(courses);
  print("MIT COURSES ${programCourses.length}");

  // Get elective courses for MIT program
  List<Course> electiveCourses = getElectiveCourses(programCourses);
  print("elective COURSES ${electiveCourses.length}");

  // Get foundation courses for MIT program
  List<Course> foundationCourses = getFoundationCourses(programCourses);
  print("foundation COURSES ${foundationCourses.length}");

  StudentPOS newStudentPOS = StudentPOS(
      schoolYears: [],
      uid: student.uid,
      displayname: student.displayname,
      role: student.role,
      email: student.email,
      idnumber: student.idnumber,
      enrolledCourses: student.enrolledCourses,
      pastCourses: student.pastCourses,
      degree: student.degree,
      status: student.status);

  print(newStudentPOS.schoolYears.toString());
  // Track added courses to avoid duplication
  Set<String> addedCourses = {};

// Map to track occurrences of elective and foundation courses across all studentPOS instances
  Map<String, int> courseOccurrences = {};

  // Distribute elective and foundation courses based on occurrences
  newStudentPOS.schoolYears = defaultschoolyears;

  for (var schoolYear in newStudentPOS.schoolYears) {
    for (var term in schoolYear.terms) {
      term.termcourses.clear(); // Clear the list of courses in the term
    }
  }
// Iterate over studentPOS instances to count occurrences of elective and foundation courses
  for (var newStudentPOS in studentPOSList) {
    for (var schoolYear in newStudentPOS.schoolYears) {
      for (var term in schoolYear.terms) {
        for (var course in term.termcourses) {
          if (electiveCourses.contains(course) ||
              foundationCourses.contains(course)) {
            courseOccurrences[course.coursecode] ??= 0;
            courseOccurrences[course.coursecode] =
                (courseOccurrences[course.coursecode] ?? 0) + 1;
          }
        }
      }
    }
  }

  for (var i = 0; i < newStudentPOS.schoolYears.length; i++) {
    var currentSchoolYear = newStudentPOS.schoolYears[i];
    for (var termIndex = 0;
        termIndex < currentSchoolYear.terms.length;
        termIndex++) {
      var term = currentSchoolYear.terms[termIndex];
      print(
          'Current num of courses in ${term.name} ${term.termcourses.length}');
      int remainingUnits = 6;

      int electiveCount = 0;
      for (var course in [...foundationCourses, ...electiveCourses]) {
        if (!addedCourses.contains(course.coursecode) &&
            remainingUnits >= course.units &&
            electiveCount < 5) {
          // Limit elective courses to 5
          // Check occurrences across all students' POS instances
          int occurrences = courseOccurrences[course.coursecode] ?? 0;
          if (occurrences < 8) {
            term.termcourses.add(course);
            print(
                'course ${course.coursecode} added to ${currentSchoolYear.name} ${term.name}');
            addedCourses.add(course.coursecode);
            remainingUnits -= course.units;
            courseOccurrences[course.coursecode] = occurrences + 1;
            electiveCount++; // Increment the elective count
          }
        }
      }
      if (i == 1 && term.name == "Term 3") {
        // Adjust for SchoolYear[1] Term 3
        Course capProjW = courses.firstWhere(
          (course) => course.coursecode == "CIS411M",
        );
        Course oex = courses.firstWhere(
          (course) => course.coursecode == "OEX",
        );
        term.termcourses.clear();
        print("added $capProjW and $oex");
        term.termcourses.addAll([capProjW, oex]);
      } else if (i == 2 && term.name == "Term 1") {
        // Adjust for SchoolYear[2] Term 1
        Course capProjP = courses.firstWhere(
          (course) => course.coursecode == "CAPROP",
        );
        Course capProjF = courses.firstWhere(
          (course) => course.coursecode == "CAPFIND",
        );
        term.termcourses.clear();
        print("added $capProjP and $capProjF");
        term.termcourses.addAll([capProjP, capProjF]);
      }
    }
  }

// Adjust courses for specific terms

  return newStudentPOS;
}

StudentPOS generatePOSforMSIT(
    Student student, List<StudentPOS> studentPOSList, List<Course> courses) {
  // Get MSIT program courses
  List<Course> programCourses = getMSITCourses(courses);
  print("MSIT COURSES ${programCourses.length}");

  // Get elective courses for MSIT program
  List<Course> electiveCourses = getElectiveCourses(programCourses);
  print("elective COURSES ${electiveCourses.length}");

  // Get foundation courses for MSIT program
  List<Course> foundationCourses = getFoundationCourses(programCourses);
  print("foundation COURSES ${foundationCourses.length}");

  // Get specialized courses for MSIT program
  List<Course> specializedCourses = getSpecializedCourses(programCourses);
  print("specialized COURSES ${specializedCourses.length}");

  StudentPOS newStudentPOS = StudentPOS(
      schoolYears: [],
      uid: student.uid,
      displayname: student.displayname,
      role: student.role,
      email: student.email,
      idnumber: student.idnumber,
      enrolledCourses: student.enrolledCourses,
      pastCourses: student.pastCourses,
      degree: student.degree,
      status: student.status);

  print(newStudentPOS.schoolYears.toString());
  // Track added courses to avoid duplication
  Set<String> addedCourses = {};

  // Map to track occurrences of elective, foundation, and specialized courses across all studentPOS instances
  Map<String, int> courseOccurrences = {};

  // Distribute elective, foundation, and specialized courses based on occurrences
  newStudentPOS.schoolYears = defaultschoolyears;

  for (var schoolYear in newStudentPOS.schoolYears) {
    for (var term in schoolYear.terms) {
      term.termcourses.clear(); // Clear the list of courses in the term
    }
  }

  // Iterate over studentPOS instances to count occurrences of elective, foundation, and specialized courses
  for (var existingStudentPOS in studentPOSList) {
    for (var schoolYear in existingStudentPOS.schoolYears) {
      for (var term in schoolYear.terms) {
        for (var course in term.termcourses) {
          if (electiveCourses.contains(course) ||
              foundationCourses.contains(course) ||
              specializedCourses.contains(course)) {
            courseOccurrences[course.coursecode] ??= 0;
            courseOccurrences[course.coursecode] =
                (courseOccurrences[course.coursecode] ?? 0) + 1;
          }
        }
      }
    }
  }
  for (var i = 0; i < newStudentPOS.schoolYears.length; i++) {
    var currentSchoolYear = newStudentPOS.schoolYears[i];
    for (var termIndex = 0;
        termIndex < currentSchoolYear.terms.length;
        termIndex++) {
      var term = currentSchoolYear.terms[termIndex];
      print(
          'Current num of courses in ${term.name} ${term.termcourses.length}');
      int remainingUnits = 6;

      int electiveCount = 0;
      for (var course in [
        ...foundationCourses,
        ...specializedCourses,
        ...electiveCourses
      ]) {
        if (!addedCourses.contains(course.coursecode) &&
            remainingUnits >= course.units &&
            electiveCount < 3) {
          // Limit elective courses to 3
          // Check occurrences across all students' POS instances
          int occurrences = courseOccurrences[course.coursecode] ?? 0;
          if (occurrences < 8) {
            term.termcourses.add(course);
            print(
                'course ${course.coursecode} added to ${currentSchoolYear.name} ${term.name}');
            addedCourses.add(course.coursecode);
            remainingUnits -= course.units;
            courseOccurrences[course.coursecode] = occurrences + 1;
            electiveCount++; // Increment the elective count
          }
        }
      }

      // Adjust courses for specific terms
      if (i == 1 && term.name == "Term 2") {
        // Adjust for SchoolYear[1] Term 3
        Course capProjW = courses.firstWhere(
          (course) => course.coursecode == "CIS801M",
        );
        Course elec3 = courses.firstWhere(
          (course) => course.coursecode == "CIS493M",
        );
        Course oex = courses.firstWhere(
          (course) => course.coursecode == "OEX",
        );
        term.termcourses.clear();
        term.termcourses.addAll([capProjW, elec3, oex]);
      } else if (i == 1 && term.name == 'Term 3') {
        // Adjust for SchoolYear[1] Term 3
        Course THWR1 = courses.firstWhere(
          (course) => course.coursecode == "THWR1",
        );
        Course THPRO = courses.firstWhere(
          (course) => course.coursecode == "THPROD",
        );
        term.termcourses.clear();
        term.termcourses.addAll([THWR1, THPRO]);
      } else if (i == 2 && term.name == "Term 1") {
        // Adjust for SchoolYear[2] Term 1
        Course THWR2 = courses.firstWhere(
          (course) => course.coursecode == "THWR2",
        );
        Course THFIND = courses.firstWhere(
          (course) => course.coursecode == "THFIND",
        );
        term.termcourses.clear();
        term.termcourses.addAll([THWR2, THFIND]);
      }
    }
  }

  return newStudentPOS;
}

List<Course> getMITCourses(List<Course> courseList) {
  return courseList.where((course) => course.program.contains('MIT')).toList();
}

List<Course> getMSITCourses(List<Course> courseList) {
  return courseList.where((course) => course.program.contains('MSIT')).toList();
}

List<Course> getElectiveCourses(List<Course> courseList) {
  return courseList
      .where((course) => course.type.contains('Elective'))
      .toList();
}

List<Course> getSpecializedCourses(List<Course> courseList) {
  return courseList
      .where((course) => course.type.contains('Specialized'))
      .toList();
}

List<Course> getFoundationCourses(List<Course> courseList) {
  return courseList
      .where((course) => course.type.contains('Foundation'))
      .toList();
}
