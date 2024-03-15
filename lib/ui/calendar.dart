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

// CALENDAR PAGE || Following guide: https://www.youtube.com/watch?v=6Gxa-v7Zh7I&ab_channel=AIwithFlutter
class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
  //final DateTime selectedDate;
  //Calendar({required this.selectedDate});
}

class _CalendarState extends State<Calendar> {
  DateTime today = DateTime.now();
  DateTime selectedTime = DateTime.now();

  // Store Events created
  //Map<DateTime, List<Event>> events = {};
  TextEditingController _eventController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: 
          Text(
            'Google Calendar Page', 
            textDirection: TextDirection.ltr,
            style: TextStyle(fontFamily: 'Outfit', fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
          ),
        
        backgroundColor: Color(0xFF174719),
      ),
      body: Center(
        child: Column(
          children: [
            
            Text(
              'Calendar',
              textDirection: TextDirection.ltr,
              style: TextStyle(fontFamily: 'Outfit', fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF174719)),
            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context)
            {
              return AlertDialog(
                scrollable: true,title: Text ("Event Details"),
                content: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Event Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Event Name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Event Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Event Description';
                          }
                          return null;
                        },
                      ),
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
                                //widget.selectedDate.year,
                                //widget.selectedDate.month,
                                //widget.selectedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        },
                        child: Text('Select Time'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Submit"),
                  )
                ],
              );
            }
          );
        },
        child: Icon(Icons.add),
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