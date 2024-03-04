import 'package:flutter/material.dart';
import 'package:sysadmindb/ui/studentInfoPage.dart';

class ProfileBox extends StatelessWidget {
  final int totalStudents;
  final int newStudents;
  final int deviatedStudents;
  final int cardCount;
  const ProfileBox(
      {super.key,
      required this.totalStudents,
      required this.newStudents,
      required this.deviatedStudents,
      required this.cardCount});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4, // Adjust the elevation as needed
      color: cardCount == 0
          ? Color.fromARGB(255, 53, 98, 134)
          : cardCount == 2
              ? Color.fromARGB(255, 187, 63, 54)
              : const Color.fromARGB(255, 170, 63, 189),
      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: 300,
            maxHeight: 100), // Adjust the maximum width as needed
        child: Stack(
          children: [
            if (cardCount == 0)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(17, 255, 255,
                                255), // Set your desired background color
                            borderRadius: BorderRadius.circular(
                                20), // Set your desired border radius
                          ),
                          child: Icon(
                            Icons.people,
                            size: 25,
                            color: Colors.white,
                          ), // Adjust size of icon as needed
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Total Students',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                    Spacer(),
                    Text(
                      totalStudents.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 45),
                    )
                  ],
                ),
              ),
            if (cardCount == 1)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(17, 255, 255,
                                255), // Set your desired background color
                            borderRadius: BorderRadius.circular(
                                20), // Set your desired border radius
                          ),
                          child: Icon(
                            Icons.new_releases,
                            size: 25,
                            color: Colors.white,
                          ), // Adjust size of icon as needed
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'New Students',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                    Spacer(),
                    Text(
                      newStudents.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 45),
                    )
                  ],
                ),
              ),
            if (cardCount == 2)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(17, 255, 255,
                                255), // Set your desired background color
                            borderRadius: BorderRadius.circular(
                                20), // Set your desired border radius
                          ),
                          child: Icon(
                            Icons.call_split_outlined,
                            size: 25,
                            color: Colors.white,
                          ), // Adjust size of icon as needed
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Deviated Students',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                    Spacer(),
                    Text(
                      deviatedStudents.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 45),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
