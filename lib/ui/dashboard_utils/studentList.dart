import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/student_user.dart';

class StudentList extends StatelessWidget {
  final Student student;
  const StudentList({super.key, required this.student});

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
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.person), // Icon on the left
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ID Number: ${student.idnumber}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${student.displayname['firstname']} ${student.displayname['lastname']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      student.email,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(),
                    Icon(Icons.keyboard_arrow_right_sharp),
                    Spacer(),
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
