import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:sysadmindb/ui/calendar.dart';
import 'package:sysadmindb/api/calendar_client.dart';
import 'package:sysadmindb/app/models/secrets.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:url_launcher/url_launcher.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sysadmindb/ui/EventDetailsScreen.dart';
import 'package:intl/intl.dart';

// CALENDAR PAGE || Following guide: https://www.youtube.com/watch?v=6Gxa-v7Zh7I&ab_channel=AIwithFlutter
class Calendar extends StatefulWidget {
  //final DateTime selectedDate;
  //Calendar({required this.selectedDate});
  @override
  _CalendarState createState() => _CalendarState();
}
 
// Event Type Choices
enum EventTypeRadio { online, f2f }

// Today's Date
DateTime today = DateTime.now();

class _CalendarState extends State<Calendar> {
  DateTime selectedTime = DateTime.now();
  TimeOfDay? pickedStartTime;
  TimeOfDay? pickedEndTime;
  String currentDate = 
      "Today is: ${DateFormat('MMMM').format(today)} ${today.day}, ${today.year}";

  EventTypeRadio? _eventtype = EventTypeRadio.online;

  // Store Events created
  //Map<DateTime, List<Event>> events = {};
  TextEditingController _eventController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // PAGE HEADER
        title: 
          Text(
            'Calendar', 
            style: TextStyle(
              fontFamily: 'Outfit', 
              fontSize: 30, 
              fontWeight: FontWeight.bold, 
              color: Color.fromARGB(255, 255, 255, 255)
            ),
          ),
        
        backgroundColor: Color(0xFF174719),
      ),

      body: Center(
        child: Column(
          children: [
            // PAGE LANDING TITLE
            Text(
              currentDate,
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF174719)),
            ),

            // CALENDAR
            TableCalendar(
              headerStyle: HeaderStyle(titleCentered: true),
              focusedDay: today,
              firstDay: DateTime.utc(2024, 2, 1),
              lastDay: DateTime.utc(2030, 12, 30),
              onDaySelected: (selectedDay, _) {
                setState(() {
                  today = selectedDay;
                });
              },
              selectedDayPredicate: (day) => isSameDay(day, today),
            ),
          ],
        ),
      ),

      // GUIDES:
      // https://www.youtube.com/watch?v=6yY-VHZiG5k (Flutter to GCal)
      // https://www.youtube.com/watch?v=JiQmjt5ta9Y (GCal to Flutter)
      // https://www.youtube.com/watch?v=HQ_ytw58tC4 (Flutter Basics)
      // https://www.youtube.com/watch?v=ASCs_g8RJ9s&ab_channel=AIwithFlutter (Add Event to Calendar)
      // https://m2.material.io/components/time-pickers/flutter#mobile-time-input-pickers (Time Picker)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    scrollable: true,
                    title: Text(
                      "Set Event Details for ${DateFormat('MMMM').format(today)} ${today.day}, ${today.year}",
                    ),
                    content: Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [


                          // === EVENT NAME ===
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Event Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Event Name';
                              }
                              return null;
                            },
                          ),


                          // === EVENT DESCRIPTION ===
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Event Description'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Event Description';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.multiline,
                            minLines: 3,
                            maxLines: 20,
                            maxLength: 1000,
                          ),


                          // === EVENT TYPE === (Online or Face-to-Face || Make into radio buttons: https://api.flutter.dev/flutter/material/Radio-class.html)
                          ListTile(
                            title: const Text('Online'),
                            leading: Radio<EventTypeRadio>(
                              value: EventTypeRadio.online,
                              groupValue: _eventtype,
                              onChanged: (EventTypeRadio? value) {
                                setState(() {
                                  _eventtype = value;
                                });
                              },
                            ),
                          ),

                          ListTile(
                            title: const Text('Face to Face'),
                            leading: Radio<EventTypeRadio>(
                              value: EventTypeRadio.f2f,
                              groupValue: _eventtype,
                              onChanged: (EventTypeRadio? value) {
                                setState(() {
                                  _eventtype = value;
                                });
                              },
                            ),
                          ),


                          // === LOCATION PICKER ===
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Location'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Event Name';
                              }
                              return null;
                            },
                          ),



                          // === TIME PICKERS ===


                          // START TIME

                          // Start Time Label
                          Container(
                            margin: const EdgeInsets.only(top: 30.0),
                            child: 
                              Text(
                                (pickedStartTime == null)
                                    ? 'Start Time: Please select START Time'
                                    : 'Start Time: ${pickedStartTime!.format(context)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                          ),

                          // Start Time Button
                          Container(
                            margin: const EdgeInsets.only(top: 5.0),
                            child: 
                              ElevatedButton(
                                onPressed: () async {
                                  // Show time picker
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: pickedStartTime ?? TimeOfDay.now(),
                                  );

                                  if (pickedTime != null) {
                                    setState(() {
                                      pickedStartTime = pickedTime;
                                    });
                                  }
                                },
                                child: Text('Select Start Time'),
                              ),
                          ),


                          // END TIME

                          // End Time Label
                          Container(
                            margin: const EdgeInsets.only(top: 15.0),
                            child:
                              Text(
                                (pickedEndTime == null)
                                    ? 'End Time: Please select END Time'
                                    : (pickedStartTime!.hour >
                                                pickedEndTime!.hour ||
                                            (pickedStartTime!.hour ==
                                                    pickedEndTime!.hour &&
                                                pickedStartTime!.minute >=
                                                    pickedEndTime!.minute))
                                        ? 'End Time: ${pickedEndTime!.format(context)}\n(ERROR: Start Time must be earlier than End Time!)'
                                        : 'End Time: ${pickedEndTime!.format(context)}',
                                style: (pickedEndTime == null)
                                    ? TextStyle(fontWeight: FontWeight.bold)
                                    : (pickedStartTime!.hour >
                                                pickedEndTime!.hour ||
                                            (pickedStartTime!.hour ==
                                                    pickedEndTime!.hour &&
                                                pickedStartTime!.minute >=
                                                    pickedEndTime!.minute))
                                        ? TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)
                                        : TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                          ),
                          
                          // End Time Button
                          Container(
                            margin: const EdgeInsets.only(top: 5.0),
                            child:
                              ElevatedButton(
                                onPressed: () async {
                                  // Show time picker
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: pickedEndTime ?? TimeOfDay.now(),
                                  );

                                  if (pickedTime != null) {
                                    setState(() {
                                      pickedEndTime = pickedTime;
                                    });
                                  }
                                },
                                child: Text('Select End Time'),
                              ),
                          ),




                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: (pickedStartTime == null ||
                                pickedEndTime == null ||
                                (pickedStartTime!.hour > pickedEndTime!.hour ||
                                    (pickedStartTime!.hour ==
                                            pickedEndTime!.hour &&
                                        pickedStartTime!.minute >=
                                            pickedEndTime!.minute)))
                            ? null
                            : () {
                                // Handle submission
                              },
                        child: Text("Submit"),
                      )
                    ],
                  );
                },
              );
            },
          );
        },
        
        icon: Icon(Icons.add), 
        label: Text("Add New Event"),
      ),
      // OLD CODE @ 48
      //    Navigator.push(
      //      context,
      //      MaterialPageRoute(
      //        builder: (context) => EventDetailsScreen(selectedDate: today),
      //      ),
      //    );
    );
  }
}
