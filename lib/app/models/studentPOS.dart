import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/enrolledcourses.dart';
import 'package:sysadmindb/app/models/pastcourses.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/app/models/term.dart';
import 'package:sysadmindb/main.dart';
import 'dart:core';

class StudentPOS extends Student {
  List<SchoolYear> schoolYears;
  String acceptanceTerm;
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
    required this.acceptanceTerm,
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
        acceptanceTerm: json['acceptanceTerm'],
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
      'acceptanceTerm': getCurrentSYandTerm()
    };

    data.addAll(super.toJson());
    return data;
  }
}

void studentPOSDefault() {
  studentPOS = StudentPOS(
      acceptanceTerm: getCurrentSYandTerm(),
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
  var currentYear = DateTime.now().year + 1;
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
    acceptanceTerm: getCurrentSYandTerm(),
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
    final courseCount = term.termcourses
        .where((course) => course.coursecode == courseCode)
        .length;
    occurrences += courseCount;
  }
  print(occurrences);
  return occurrences;
}

StudentPOS generatePOSforMIT(
  Student student,
  StudentPOS studentpos,
  List<StudentPOS> studentPOSList,
  List<Course> courses,
) {
  // Get MIT program courses
  List<Course> programCourses = getMITCourses(courses);
  List<Course> electiveCourses = getElectiveCourses(programCourses);
  List<Course> foundationCourses = getFoundationCourses(programCourses);
  int maxUnitsPerTerm = 6;

  // Initialize a new StudentPOS
  StudentPOS newStudentPOS = StudentPOS(
    acceptanceTerm: getCurrentSYandTerm(),
    schoolYears: studentpos.schoolYears,
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

  // Add CIS411M and OEX
  Course cis411m =
      courses.firstWhere((course) => course.coursecode == "CIS411M");
  Course oex = courses.firstWhere((course) => course.coursecode == "OEX");

  // Add CAPROP and CAPFIND
  Course caprop = courses.firstWhere((course) => course.coursecode == "CAPROP");
  Course capfind =
      courses.firstWhere((course) => course.coursecode == "CAPFIND");

  // Helper function to find the best term for a course
  Term? findBestTermForCourse(Course course, List<Term> excludeTerms) {
    Term? bestTerm;
    int maxCount = -1;
    for (var year in newStudentPOS.schoolYears) {
      for (var term in year.terms) {
        if (!excludeTerms.contains(term) &&
            term.termcourses.length < 2 &&
            term.termcourses.fold<int>(0, (acc, course) => acc + course.units) +
                    course.units <=
                maxUnitsPerTerm) {
          int count = studentPOSList
              .where((pos) =>
                  pos.status != 'LOA' &&
                  pos.schoolYears.any((sy) => sy.terms.any((t) =>
                      t.name == term.name &&
                      t.termcourses
                          .any((c) => c.coursecode == course.coursecode))))
              .length;
          if (count > maxCount) {
            maxCount = count;
            bestTerm = term;
          }
        }
      }
    }
    return bestTerm;
  }

  // Add foundation courses to the POS
  List<Term> capstoneTerms = [];
  for (var course in foundationCourses) {
    Term? term = findBestTermForCourse(course, capstoneTerms);
    if (term != null) {
      term.termcourses.add(course);
    }
  }

  // Sort elective courses by the number of potential classmates
  electiveCourses.sort((a, b) {
    int aCount = studentPOSList
        .where((pos) =>
            pos.status != 'LOA' &&
            pos.schoolYears.any((sy) => sy.terms.any(
                (t) => t.termcourses.any((c) => c.coursecode == a.coursecode))))
        .length;
    int bCount = studentPOSList
        .where((pos) =>
            pos.status != 'LOA' &&
            pos.schoolYears.any((sy) => sy.terms.any(
                (t) => t.termcourses.any((c) => c.coursecode == b.coursecode))))
        .length;
    return bCount.compareTo(aCount); // Sort in descending order
  });

  // Add only the top 5 elective courses
  for (var i = 0; i < 5 && i < electiveCourses.length; i++) {
    var course = electiveCourses[i];
    Term? term = findBestTermForCourse(course, capstoneTerms);
    if (term != null) {
      term.termcourses.add(course);
    }
  }

  // Find the term for CIS411M and OEX after all other courses have been added
  Term? termForCisOex = findBestTermForCourse(cis411m, capstoneTerms);
  if (termForCisOex != null) {
    termForCisOex.termcourses.add(cis411m);
    capstoneTerms.add(termForCisOex);
    if (termForCisOex.termcourses
                .fold<int>(0, (acc, course) => acc + course.units) +
            oex.units <=
        maxUnitsPerTerm) {
      termForCisOex.termcourses.add(oex);
    }
  }

  // Find the term for CAPROP and CAPFIND after CIS411M and OEX
  Term? termForCapstone = findBestTermForCourse(caprop, capstoneTerms);
  if (termForCapstone != null) {
    termForCapstone.termcourses.add(caprop);
    termForCapstone.termcourses.add(capfind);
    capstoneTerms.add(termForCapstone);
  }

  // Handle any remaining courses that couldn't be added in the first pass
  for (var course in foundationCourses + electiveCourses) {
    if (!newStudentPOS.schoolYears.any((year) =>
        year.terms.any((term) => term.termcourses.contains(course)))) {
      for (var year in newStudentPOS.schoolYears) {
        for (var term in year.terms) {
          if (!capstoneTerms.contains(term) &&
              term.termcourses.length < 2 &&
              term.termcourses
                          .fold<int>(0, (acc, course) => acc + course.units) +
                      course.units <=
                  maxUnitsPerTerm) {
            term.termcourses.add(course);
            break;
          }
        }
      }
    }
  }

  return newStudentPOS;
}

StudentPOS generatePOSforMSIT(
  Student student,
  StudentPOS studentpos,
  List<StudentPOS> studentPOSList,
  List<Course> courses,
) {
  // Get MSIT program courses
  List<Course> programCourses = getMSITCourses(courses);
  print(programCourses.length);

  List<Course> electiveCourses = getElectiveCourses(programCourses);
  print(electiveCourses.length);

  List<Course> foundationCourses = getFoundationCourses(programCourses);
  print(foundationCourses.length);

  List<Course> specializationCourses = getSpecializedCourses(programCourses);

  print(specializationCourses.length);

  int maxUnitsPerTerm = 6;

  // Initialize a new StudentPOS
  StudentPOS newStudentPOS = StudentPOS(
    acceptanceTerm: getCurrentSYandTerm(),
    schoolYears: studentpos.schoolYears,
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

  // Add THPROD and THWR1
  Course thprod = courses.firstWhere((course) => course.coursecode == "THPROD");
  Course thwr1 = courses.firstWhere((course) => course.coursecode == "THWR1");

  // Add THFIND and THWR2
  Course thfind = courses.firstWhere((course) => course.coursecode == "THFIND");
  Course thwr2 = courses.firstWhere((course) => course.coursecode == "THWR2");

  // Helper function to find the best term for a course
  Term? findBestTermForCourse(Course course, List<Term> excludeTerms) {
    Term? bestTerm;
    int maxCount = -1;
    for (var year in newStudentPOS.schoolYears) {
      for (var term in year.terms) {
        if (!excludeTerms.contains(term) &&
            term.termcourses.length < 2 &&
            term.termcourses.fold<int>(0, (acc, course) => acc + course.units) +
                    course.units <=
                maxUnitsPerTerm) {
          int count = studentPOSList
              .where((pos) =>
                  pos.status != 'LOA' &&
                  pos.schoolYears.any((sy) => sy.terms.any((t) =>
                      t.name == term.name &&
                      t.termcourses
                          .any((c) => c.coursecode == course.coursecode))))
              .length;
          if (count > maxCount) {
            maxCount = count;
            bestTerm = term;
          }
        }
      }
    }
    return bestTerm;
  }

  // Add foundation courses to the POS
  List<Term> thesisTerms = [];
  for (var course in foundationCourses) {
    Term? term = findBestTermForCourse(course, thesisTerms);
    if (term != null) {
      term.termcourses.add(course);
    }
  }

  // Add specialization courses to the POS
  for (var course in specializationCourses) {
    Term? term = findBestTermForCourse(course, thesisTerms);
    if (term != null) {
      term.termcourses.add(course);
    }
  }

  // Sort elective courses by the number of potential classmates
  electiveCourses.sort((a, b) {
    int aCount = studentPOSList
        .where((pos) =>
            pos.status != 'LOA' &&
            pos.schoolYears.any((sy) => sy.terms.any(
                (t) => t.termcourses.any((c) => c.coursecode == a.coursecode))))
        .length;
    int bCount = studentPOSList
        .where((pos) =>
            pos.status != 'LOA' &&
            pos.schoolYears.any((sy) => sy.terms.any(
                (t) => t.termcourses.any((c) => c.coursecode == b.coursecode))))
        .length;
    return bCount.compareTo(aCount); // Sort in descending order
  });

  // Add all elective courses
  for (var course in electiveCourses) {
    Term? term = findBestTermForCourse(course, thesisTerms);
    if (term != null) {
      term.termcourses.add(course);
    }
  }

  // Find the term for THPROD and THWR1 after all other courses have been added
  Term? termForThprodThwr1 = findBestTermForCourse(thprod, thesisTerms);
  if (termForThprodThwr1 != null) {
    termForThprodThwr1.termcourses.add(thprod);
    thesisTerms.add(termForThprodThwr1);
    if (termForThprodThwr1.termcourses
                .fold<int>(0, (acc, course) => acc + course.units) +
            thwr1.units <=
        maxUnitsPerTerm) {
      termForThprodThwr1.termcourses.add(thwr1);
    }
  }

  // Find the term for THWR2 and THFIND after THPROD and THWR1
  Term? termForThwr2Thfind = findBestTermForCourse(thwr2, thesisTerms);
  if (termForThwr2Thfind != null) {
    termForThwr2Thfind.termcourses.add(thwr2);
    termForThwr2Thfind.termcourses.add(thfind);
    thesisTerms.add(termForThwr2Thfind);
  }

  // Handle any remaining courses that couldn't be added in the first pass
  for (var course
      in foundationCourses + electiveCourses + specializationCourses) {
    if (!newStudentPOS.schoolYears.any((year) =>
        year.terms.any((term) => term.termcourses.contains(course)))) {
      for (var year in newStudentPOS.schoolYears) {
        for (var term in year.terms) {
          if (!thesisTerms.contains(term) &&
              term.termcourses.length < 2 &&
              term.termcourses
                          .fold<int>(0, (acc, course) => acc + course.units) +
                      course.units <=
                  maxUnitsPerTerm) {
            term.termcourses.add(course);
            break;
          }
        }
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
