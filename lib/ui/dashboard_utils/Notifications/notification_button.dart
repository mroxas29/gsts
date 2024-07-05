import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';

class NotificationButton extends StatefulWidget {
  final int notificationCount;
  final List<String> notifications;

  NotificationButton({
    required this.notificationCount,
    required this.notifications,
  });

  @override
  NotificationButtonState createState() => NotificationButtonState();
}

class NotificationButtonState extends State<NotificationButton> {
  OverlayEntry? _overlayEntry;

  void _toggleNotificationList() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context)?.insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    setState(() {});
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        right: 8,
        top: offset.dy + size.height + 8,
        width: 300,
        child: Material(
          elevation: 4,
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: _toggleNotificationList,
                    ),
                  ],
                ),
                Divider(),
                if (widget.notifications.isNotEmpty)
                  ...widget.notifications.map(
                    (notification) => ListTile(
                      onTap: () {
                        if (notification.toLowerCase().contains('loa')) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Returning Students'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      Text(
                                          'There are returning students for ${getCurrentSYandTerm()}\n'),
                                      Text(
                                        '● - Ineligible to enroll',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '● - Still Eligible',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (StudentPOS loa
                                                in fromLOAStudents)
                                              Text(
                                                  '${loa.idnumber} - ${loa.displayname['firstname']} ${loa.displayname['lastname']}',
                                                  style: TextStyle(
                                                    color:
                                                        !isGraduatingWithinTimeFrame(
                                                                loa.degree,
                                                                loa.idnumber
                                                                    .toString())
                                                            ? Colors.red
                                                            : Colors.black,
                                                  )),
                                          ]),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Click "Ineligible Students" tile in the dashboard to see all',
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the dialog
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (notification
                            .toLowerCase()
                            .contains('derf')) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('New Students'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      Text(
                                          'There are new students for the upcoming term ${getNextSYandTerm()}\n'),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (Student newStud
                                                in newStudentList)
                                              Text(
                                                '${newStud.idnumber} - ${newStud.displayname['firstname']} ${newStud.displayname['lastname']}',
                                              )
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Click the "New Students" tile on the dashboard to show more info about each student.',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the dialog
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      title: Text(notification),
                    ),
                  ),
                if (widget.notifications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('No notifications'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.notification_important),
            color: Color.fromARGB(255, 82, 138, 84),
            tooltip: 'Open notifications',
            onPressed: _toggleNotificationList,
          ),
        ),
        if (widget.notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 82, 138, 84),
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${widget.notificationCount}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
