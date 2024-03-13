import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sysadmindb/ui/EventDetailsScreen.dart';

// CALENDAR PAGE || Following guide: https://www.youtube.com/watch?v=6Gxa-v7Zh7I&ab_channel=AIwithFlutter
class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime today = DateTime.now();

  // Store Events created
  //Map<DateTime, List<Event>> events = {};
  TextEditingController _eventController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Calendar'),
        backgroundColor: const Color.fromARGB(255, 23, 71, 25),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Calendar',
              textDirection: TextDirection.ltr,
              style: TextStyle(fontFamily: 'Segoe UI', fontSize: 30),
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

      // GUIDE: https://www.youtube.com/watch?v=ASCs_g8RJ9s&ab_channel=AIwithFlutter
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
                  child: TextField(
                    controller: _eventController,
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