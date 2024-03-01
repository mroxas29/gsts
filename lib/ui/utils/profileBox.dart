import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/ui/studentInfoPage.dart';

class ProfileBox extends StatelessWidget {
  final Student student;
  final StudentPOS pos;
  const ProfileBox({super.key, required this.student, required this.pos});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4, // Adjust the elevation as needed
      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: 300), // Adjust the maximum width as needed
        child: Stack(
          children: [
            Container(
              height: 50, // Adjust the height of the container
              decoration: BoxDecoration(
                color:
                    Color.fromARGB(255, 25, 87, 27), // Set the color to green
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ), // Adjust the border radius as needed
              ),
              child: SizedBox(
                height: 50, // Height of the container
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ), // Match the border radius of the container
                  child: Image.asset(
                    'assets/images/De_La_Salle_University_Seal.png', // Path to the image asset
                    fit: BoxFit
                        .cover, // Crop the image to cover the entire container
                    width: double
                        .infinity, // Take the entire width of the container
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 50), // Add padding to the top of the main content
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(10), // Adjust the radius as needed
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display student's full name
                    Text(
                      "${student.displayname['firstname']} ${student.displayname['lastname']}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    // Display student's email
                    Text(
                      "Email: ${student.email}",
                      style: TextStyle(fontSize: 14),
                    ),
                    // Display student's ID Number
                    Text(
                      "ID Number: ${student.idnumber}",
                      style: TextStyle(fontSize: 14),
                    ),
                    // Button to view student's profile
                    Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentInfoPage(
                                student: student,
                                studentpos: pos,
                              ),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 255, 255, 255)),
                          elevation: MaterialStateProperty.all<double>(0),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              border:
                                  Border(top: BorderSide(color: Colors.grey))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Color.fromARGB(255, 25, 87, 27),
                                ), // Add an icon before text
                                SizedBox(
                                    width:
                                        10), // Add spacing between icon and text
                                Text(
                                  "View Profile",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 25, 87, 27)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
