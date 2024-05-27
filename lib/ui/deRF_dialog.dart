// course_dialog.dart
import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/main.dart';

Future<void> showCourseDialog({
  required BuildContext context,
  required List<Course> recommendedPriorityCourses,
  required List<Course> recommendedRemedialCourses,
  required ValueChanged<bool?> onCheckboxChanged,
  required Future<void> Function() onDownloadPressed,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Recommended Courses:'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...recommendedRemedialCourses.map((course) => ListTile(
                        title:
                            Text("${course.coursecode}: ${course.coursename}"),
                        subtitle: Text('Remedial Course'),
                      )),
                  ...recommendedPriorityCourses.map((course) => ListTile(
                        title:
                            Text("${course.coursecode}: ${course.coursename}"),
                        subtitle: Text('Foundation Course'),
                      )),
                  CheckboxListTile(
                    title: Text('Add ENG501M/ENGF01M'),
                    value: isEng501MChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isEng501MChecked = value!;
                        onCheckboxChanged(value);
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false); // No, do not delete
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: onDownloadPressed,
                child: Text('Download DeRF'),
              ),
            ],
          );
        },
      );
    },
  );
}
