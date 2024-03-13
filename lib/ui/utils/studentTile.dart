import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/DeviatedStudents.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/term.dart';

class StudentTile extends StatelessWidget {
  final DeviatedStudent student;
  const StudentTile({super.key, required this.student});

  String findSYTerm(Course course) {
    for (int i = 0; i < student.studentPOS.schoolYears.length; i++) {
      SchoolYear sy = student.studentPOS.schoolYears[i];
      for (int j = 0; j < sy.terms.length; j++) {
        Term term = sy.terms[j];

        if (term.termcourses.any((c) => c.coursecode == course.coursecode)) {
          return '${sy.name} ${term.name}';
        }
      }
    }
    return '(not found on POS)';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 4, // Adjust the elevation as needed
        borderRadius: BorderRadius.circular(10),
        child: IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.person), // Icon on the left
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ID Number: ${student.studentPOS.idnumber}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${student.studentPOS.displayname['firstname']} ${student.studentPOS.displayname['lastname']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      student.studentPOS.email,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Student enrolled in:",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    for (Course course in student.deviatedCourses)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${course.coursecode}: ${course.coursename}",
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            "Course is supposed to be taken on ${findSYTerm(course)}",
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
