import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/DeviatedStudents.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/SchoolYear.dart';
import 'package:sysadmindb/app/models/term.dart';

class StudentTile extends StatefulWidget {
  final DeviatedStudent student;
  const StudentTile({super.key, required this.student});

  @override
  State<StudentTile> createState() => _StudentTileState();
}

class _StudentTileState extends State<StudentTile> {
  String findSYTerm(Course course) {
    for (int i = 0; i < widget.student.studentPOS.schoolYears.length; i++) {
      SchoolYear sy = widget.student.studentPOS.schoolYears[i];
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
                      "ID Number: ${widget.student.studentPOS.idnumber}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${widget.student.studentPOS.displayname['firstname']} ${widget.student.studentPOS.displayname['lastname']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      widget.student.studentPOS.email,
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
                    for (Course course in widget.student.deviatedCourses)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Course ${course.coursecode}: ${course.coursename}\nplanned on ${findSYTerm(course)}",
                                softWrap: true,
                                style:
                                    TextStyle(fontSize: 14, color: Colors.red),
                                maxLines: null, // Allow unlimited lines
                                overflow: TextOverflow
                                    .visible, // Allow the text to wrap to the next line
                              ),
                            ],
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
