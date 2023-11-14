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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Color getColorForCourseType(Course course) {
    if (currentStudent.pastCourses
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
    return Stack(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Student Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 16),
              Text(
                '${widget.student.displayname['firstname']} ${widget.student.displayname['lastname']}',
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              SizedBox(height: 8),
              Text(
                'Email: ${widget.student.email}',
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 8),
              Text(
                'ID Number: ${widget.student.idnumber}',
                textAlign: TextAlign.left,
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Align(
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                            width: 1500,

                            // TODO: Build your POS UI here
                            child: Center(
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    child: Table(
                                      border: TableBorder.all(),
                                      children: schoolyears.map((schoolYear) {
                                        return TableRow(
                                            decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 221, 221, 221)),
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Row(children: [
                                                  Expanded(
                                                      child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color
                                                              .fromARGB(255,
                                                              104, 177, 106),
                                                          border: Border.all(),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.zero,
                                                            bottomRight:
                                                                Radius.zero,
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: Text(
                                                                schoolYear.name,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        children: schoolYear
                                                            .terms
                                                            .map((term) {
                                                          return Expanded(
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border: Border
                                                                          .all(),
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        bottomLeft:
                                                                            Radius.circular(10),
                                                                        bottomRight:
                                                                            Radius.circular(10),
                                                                        topLeft:
                                                                            Radius.zero,
                                                                        topRight:
                                                                            Radius.zero,
                                                                      )),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Text(
                                                                      term.name,
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            17,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: term
                                                                        .termcourses
                                                                        .map(
                                                                            (termcourse) {
                                                                      return Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              Container(
                                                                                padding: EdgeInsets.all(8.0),
                                                                                child: Text(
                                                                                  "${termcourse.coursecode}: ${termcourse.coursename}",
                                                                                  style: TextStyle(color: getColorForCourseType(termcourse)),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          )
                                                                        ],
                                                                      );
                                                                    }).toList(),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      )
                                                    ],
                                                  ))
                                                ]),
                                              ),
                                            ]);
                                      }).toList(),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent),
                                    onPressed: () {},
                                    child: Text('Recommend a course'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
                child: Text('Show student POS'),
              ),
              SizedBox(height: 16),
              Text('Enrolled Courses:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                height: 100, // Set your preferred height
                child: ListView.builder(
                  itemCount: widget.student.enrolledCourses.length,
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
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(widget.student.pastCourses[index].coursecode),
                      subtitle: Text(
                          '${widget.student.pastCourses[index].coursename}\nGrade: ${widget.student.pastCourses[index].grade}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 40,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
