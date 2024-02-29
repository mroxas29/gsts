import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sysadmindb/ui/EventDetailsScreen.dart';

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
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Calendar',
              textDirection: TextDirection.ltr,
              style: TextStyle(fontFamily: 'Inter', fontSize: 30),
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