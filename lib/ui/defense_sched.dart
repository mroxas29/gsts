import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date

class DefenseSchedulesAppBar extends StatelessWidget {
  final int currentStudentIndex;
  final int totalStudents;

  DefenseSchedulesAppBar({
    required this.currentStudentIndex,
    required this.totalStudents,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current date in a formatted string
    String formattedDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    // Calculate the progress
    double progress = currentStudentIndex / totalStudents;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
Row(
            children: [
              Text(
                '$currentStudentIndex of $totalStudents students scheduled',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
    
        ],
      ),
      
    );
  }
}
