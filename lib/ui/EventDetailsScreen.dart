import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:sysadmindb/api/calendar_client.dart';
import 'package:sysadmindb/app/models/secrets.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatefulWidget {
  final DateTime selectedDate;
  EventDetailsScreen({required this.selectedDate});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  DateTime selectedTime = DateTime.now(); // Changed type to DateTime

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Enter title',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Enter description',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Time:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () async {
                // Show time picker
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(selectedTime),
                );

                if (pickedTime != null) {
                  setState(() {
                    selectedTime = DateTime(
                      widget.selectedDate.year,
                      widget.selectedDate.month,
                      widget.selectedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              },
              child: Text('Select Time'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Selected Date: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            // Add Confirm Button
            ElevatedButton(
              onPressed: () async {
                try {
                  final GoogleSignInAccount? googleUser =
                      await GoogleSignIn().signIn();

                  if (googleUser != null) {
                    final GoogleSignInAuthentication googleAuth =
                        await googleUser.authentication;

                    final credential = GoogleAuthProvider.credential(
                      accessToken: googleAuth.accessToken,
                      idToken: googleAuth.idToken,
                    );

                    await FirebaseAuth.instance
                        .signInWithCredential(credential);

                    CalendarClient client =
                        CalendarClient(); // Create an instance of CalendarClient

                    // Insert the event
                    final eventData = await client.insert(
                      title: "TEST",
                      description: "DESCRIPTION TEST",
                      location: "ONLINE",
                      attendeeEmailList: [],
                      shouldNotifyAttendees: false,
                      hasConferenceSupport: false,
                      startTime: DateTime.now(),
                      endTime: DateTime.now(),
                    );

                    String? eventId = eventData['id'];
                    String? eventLink = eventData['link'];
                    // Handle eventId and eventLink as needed

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Event created successfully!')),
                    );
                  }
                } catch (error) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating event: $error')),
                  );
                  print('Error creating event: $error');
                }
              },
              child: Text('Confirm Event'),
            ),
          ],
        ),
      ),
    );
  }
}

void prompt(String url) async {
  Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}
