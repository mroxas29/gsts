import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/courses.dart';

class CircularProgressWidget extends StatelessWidget {
  final List<Course> courses;
  final List<Course> pastCourses;

  CircularProgressWidget({
    required this.courses,
    required this.pastCourses,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = pastCourses.length / courses.length;

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 150.0,
        height: 150.0,
        child: Stack(
          children: [
            SizedBox(
              height: 400,
              width: 400,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 20.0,
                strokeCap: StrokeCap.round,
                color: const Color.fromARGB(255, 38, 110, 41),
                backgroundColor: const Color.fromARGB(
                    255, 218, 217, 217), // Set the background color
              ),
            ),
            Center(
              child: Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
