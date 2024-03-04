import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:intl/intl.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

class EventDetailsScreen extends StatefulWidget {
  final DateTime selectedDate;
  EventDetailsScreen({required this.selectedDate});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

const _scopes = [CalendarApi.calendarScope];

var _credentials = ClientId(
    "703443900752-bm9ft9siccts76cs44tgj6p4966lieq8.apps.googleusercontent.com");

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
              onPressed: () {
                // Create a new event object
                EventDateTime _eventDateTime =
                    EventDateTime(dateTime: selectedTime);

                Event event = Event()
                  ..summary = titleController.text
                  ..description = descriptionController.text
                  ..start = _eventDateTime;
                  

                // Call insertEvent with the created event
                insertEvent(event);
              },
              child: Text('Confirm Event'),
            ),
          ],
        ),
      ),
    );
  }

  insertEvent(event) async {
    try {
      final client = auth.clientViaApiKey(
        "AIzaSyD_e5JNG5j59-pHqT9sL_0tLfIeMbvFcc4",
      );
      var calendar = CalendarApi(client);
      String calendarId = "primary";
      var value = await calendar.events.insert(event, calendarId);
      print("ADDEDDD_________________${value.status}");
      if (value.status == "confirmed") {
        log('Event added in google calendar');
      } else {
        log("Unable to add event in google calendar");
      }
    } catch (e, stackTrace) {
      log('Error creating event: $e');
      print('Stack trace: $stackTrace');
    }

    void prompt(String url) async {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    @override
    void dispose() {
      titleController.dispose();
      descriptionController.dispose();
      super.dispose();
    }
  }
}
