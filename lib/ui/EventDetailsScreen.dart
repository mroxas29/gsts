import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:sysadmindb/api/calendar_client.dart';
import 'package:sysadmindb/app/models/secrets.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:url_launcher/url_launcher.dart';
import 'package:sysadmindb/app/models/user.dart';

class EventDetailsScreen extends StatefulWidget {
  final DateTime selectedDate;
  EventDetailsScreen({required this.selectedDate});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController linkController; 
  late TextEditingController recipientsController;
  bool shouldNotifyAttendees = false;
  bool hasConferenceSupport = false;
  late DateTime selectedStartTime;
  late DateTime selectedEndTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    locationController = TextEditingController();
    linkController = TextEditingController();
    recipientsController = TextEditingController();
    selectedStartTime = DateTime.now();
    selectedEndTime = DateTime.now().add(Duration(hours: 1)); // Default to one hour ahead
    addUserFromFirestore();
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
              'Recipients:', // Label for recipients
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
           TypeAheadField(
              controller: recipientsController,
              
              suggestionsCallback: (pattern) async {
                // Split the pattern into individual recipient email patterns
                List<String> emailPatterns = pattern.split(',').map((e) => e.trim()).toList();
                
                // Filter users based on individual email patterns
                List<user> filteredUsers = [];
                for (String emailPattern in emailPatterns) {
                  filteredUsers.addAll(users.where((user) =>
                    user.email.contains(emailPattern) ||
                    formatMapToString(user.displayname).contains(emailPattern)
                  ));
                }
              
              return Future.value(filteredUsers);
            },
              
              itemBuilder: (context, suggesteduser) {
                // Build suggestion list item
                return ListTile(
                  title: Text(suggesteduser.email),
                  subtitle: Text(formatMapToString(suggesteduser.displayname)),
                  onTap: (){
                    final currentText = recipientsController.text;
                    final commaIndex = currentText.lastIndexOf(',');
                    final newText = commaIndex != -1 ? currentText.substring(0, commaIndex + 1) : ''; // Include the comma
                    recipientsController.text = '$newText${suggesteduser.email}, ';
                  }
                );
              },
              onSelected: (suggesteduser) {
                // Add selected recipient to the text field
                recipientsController.text +=
                    '${suggesteduser.email}, '; // Adjust this as needed
              },
            ),
            SizedBox(height: 16.0),
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
              'Location:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: 'Enter location',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Link:', // Label for link
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: linkController, // Assign the controller
              decoration: InputDecoration(
                hintText: 'Enter link',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Checkbox(
                  value: shouldNotifyAttendees,
                  onChanged: (value) {
                    setState(() {
                      shouldNotifyAttendees = value!;
                    });
                  },
                ),
                Text('Should Notify Attendees'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: hasConferenceSupport,
                  onChanged: (value) {
                    setState(() {
                      hasConferenceSupport = value!;
                    });
                  },
                ),
                Text('Has Conference Support'),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(selectedStartTime),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Show time picker for start time
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedStartTime),
                    );

                    if (pickedTime != null) {
                      setState(() {
                        selectedStartTime = DateTime(
                          widget.selectedDate.year,
                          widget.selectedDate.month,
                          widget.selectedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  },
                  child: Text('Select Start Time'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Time:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(selectedEndTime),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Show time picker for end time
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedEndTime),
                    );

                    if (pickedTime != null) {
                      setState(() {
                        selectedEndTime = DateTime(
                          widget.selectedDate.year,
                          widget.selectedDate.month,
                          widget.selectedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  },
                  child: Text('Select End Time'),
                ),
              ],
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
