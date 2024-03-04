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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(selectedDate: today),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}