import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/sendemail.dart';
import 'package:sysadmindb/app/models/student_user.dart';

class IneligibleList extends StatelessWidget {
  final Student student;
  const IneligibleList({super.key, required this.student});
  int graduatingYear(String degree, String idNumber) {
    print(int.parse(idNumber.substring(1, 3)));
    // Extract the year from the ID number
    int idYear =
        int.parse(idNumber.substring(1, 3)) + 2000; // Convert to full year

    // Calculate the maximum graduation year based on degree
    int maxGraduationYear;
    if (degree.toLowerCase().contains('doctorate')) {
      maxGraduationYear = idYear + 12;
    } else if (degree.toLowerCase().contains('masters')) {
      maxGraduationYear = idYear + 8;
    } else {
      // For other degrees, return true (no specific time frame)
      return idYear + 4;
    }

    // Check if the current year is within the time frame
    return maxGraduationYear;
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
                      "ID Number: ${student.idnumber} (Student should have graduated on ${graduatingYear(student.degree, student.idnumber.toString())})",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    Text(
                      "${student.displayname['firstname']} ${student.displayname['lastname']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      student.degree,
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Implement the functionality to send an email to the student's email address

                        await sendEmailWarning(
                          firstname: student.displayname['firstname'],
                          email: student.email,
                          toemail: student.email,
                          subject: 'Possible enrollment ineligibility',
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Email sent"),
                          ),
                        );
                      },
                      child: Text(
                        'Send email to ${student.email}',
                        style: TextStyle(fontSize: 14),
                      ),
                    )
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
