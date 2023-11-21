import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/main.dart';

class StudentInfoPopup extends StatefulWidget {
  final Student student;

  StudentInfoPopup(this.student);

  @override
  State<StudentInfoPopup> createState() => _StudentInfoPopupState();
}

class _StudentInfoPopupState extends State<StudentInfoPopup> {
  @override
  Widget build(BuildContext context) {
    return 
    SingleChildScrollView(
      child:  Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    ),
    );
   
  }

  Color getColorForCourseType(Course course) {
    if (currentStudent!.pastCourses
        .any((pastcourse) => pastcourse.coursecode == course.coursecode)) {
      return Colors.grey;
    } else {
      if (course.type.toLowerCase().contains('bridging')) {
        return Colors.blue;
      } // Choose the color you want for Bridging
      else if (course.type.toLowerCase().contains('foundation')) {
        return Colors.green;
      } // Choose the color you want for Foundation
      else if (course.type.toLowerCase().contains('exam')) {
        return Colors.red;
      } // Choose the color you want for Exam
      else if (course.type.toLowerCase().contains('elective')) {
        return Colors.orange;
      } // Choose the color you want for Elective
      else {
        return Colors.black;
      } // Default color for unknown types
    }
  }

  Widget contentBox(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(top: 60),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 10),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Information',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 16),
                Text(
                  '${widget.student.displayname['firstname']} ${widget.student.displayname['lastname']} (${widget.student.idnumber})',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                SizedBox(height: 8),
                Text(
                  widget.student.email,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8),
                Text(
                  widget.student.degree,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 25),
                Text('Enrolled Courses:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 100, // Set your preferred height
                  child: ListView.builder(
                    itemCount: widget.student.enrolledCourses.length,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            widget.student.enrolledCourses[index].coursecode),
                        subtitle: Text(
                            widget.student.enrolledCourses[index].coursename),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text('Past Courses:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 100, // Set your preferred height
                  child: ListView.builder(
                    itemCount: widget.student.pastCourses.length,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title:
                            Text(widget.student.pastCourses[index].coursecode),
                        subtitle: Text(
                            '${widget.student.pastCourses[index].coursename}\nGrade: ${widget.student.pastCourses[index].grade}'),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Program of Study:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        for (var schoolYear in schoolyears)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: Text(
                              schoolYear.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                      ],
                    ),
                    TableRow(
                      children: [
                        for (var schoolYear in schoolyears)
                          Column(
                            children: [
                              for (var term in schoolYear.terms)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                          child: Text(
                                        term.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                    for (var course in term.termcourses)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "${course.coursecode}: ${course.coursename}",
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                  ],
                                )
                            ],
                          ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
