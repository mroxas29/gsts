import 'dart:math';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/api/calendar/appointment_editor.dart';

class CalendarSF extends StatefulWidget {
  const CalendarSF({super.key});

  @override
  State<CalendarSF> createState() => _CalendarSFState();
}

late List<Color> colorCollection;
late List<String> colorNames;
int selectedColorIndex = 0;
int selectedTimeZoneIndex = 0;
int selectedResourceIndex = 0;
late List<String> timeZoneCollection;
late DataSource events;
Meeting? selectedAppointment;
late DateTime startDate;
late TimeOfDay startTime;
late DateTime endDate;
late TimeOfDay endTime;
late bool isAllDay;
String subject = '';
String notes = '';
late List<CalendarResource> employeeCollection;
late List<String> nameCollection;

class _CalendarSFState extends State<CalendarSF> {
  late List<String> eventNameCollection;
  late List<Meeting> appointments;
  CalendarController calendarController = CalendarController();
  @override
  void initState() {
    appointments = getMeetingDetails();
    events = DataSource(appointments);
    selectedAppointment = null;
    selectedColorIndex = 0;
    selectedTimeZoneIndex = 0;
    subject = '';
    notes = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(child: getEventCalendar(events, onCalendarTapped)),
    );
  }

  SfCalendar getEventCalendar(CalendarDataSource calendarDataSource,
      CalendarTapCallback calendarTapCallback) {
    return SfCalendar(
        view: CalendarView.month,
        controller: calendarController,
        allowedViews: const [
          CalendarView.week,
          CalendarView.timelineWeek,
          CalendarView.month
        ],
        dataSource: calendarDataSource,
        onTap: calendarTapCallback,
        appointmentBuilder: (context, calendarAppointmentDetails) {
          final Meeting meeting = calendarAppointmentDetails.appointments.first;
          return Container(
            color: meeting.background.withOpacity(0.8),
            child: Text(meeting.eventName),
          );
        },
        initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 0, 0, 0),
        monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        timeSlotViewSettings: const TimeSlotViewSettings(
            minimumAppointmentDuration: Duration(minutes: 60)));
  }

  void onCalendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement != CalendarElement.calendarCell &&
        calendarTapDetails.targetElement != CalendarElement.appointment) {
      return;
    }

    setState(() {
      selectedAppointment = null;
      isAllDay = false;
      selectedColorIndex = 0;
      selectedTimeZoneIndex = 0;
      subject = '';
      if (calendarController.view == CalendarView.month) {
        calendarController.view = CalendarView.day;
      } else {
        if (calendarTapDetails.appointments != null &&
            calendarTapDetails.appointments!.length == 1) {
          final Meeting meetingDetails = calendarTapDetails.appointments![0];
          setState(() {
               startDate = meetingDetails.from;
            endDate = meetingDetails.to;
            isAllDay = meetingDetails.isAllDay;
            selectedColorIndex =
                colorCollection.indexOf(meetingDetails.background);
            selectedTimeZoneIndex = meetingDetails.startTimeZone == ''
                ? 0
                : timeZoneCollection.indexOf(meetingDetails.startTimeZone);
            subject = meetingDetails.eventName == '(No title)'
                ? ''
                : meetingDetails.eventName;
            notes = meetingDetails.description;
            
            selectedAppointment = meetingDetails;
          });
       
        } else {
          final DateTime date = calendarTapDetails.date!;
          startDate = date;
          endDate = date.add(const Duration(hours: 1));
        }
        startTime = TimeOfDay(hour: startDate.hour, minute: startDate.minute);
        endTime = TimeOfDay(hour: endDate.hour, minute: endDate.minute);
        Navigator.push<Widget>(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => AppointmentEditor()),
        );
      }
    });
  }

  List<Meeting> getMeetingDetails() {
    final List<Meeting> meetingCollection = <Meeting>[];

    nameCollection = <String>[];
    nameCollection.add('John');
    nameCollection.add('Bryan');
    nameCollection.add('Robert');
    nameCollection.add('Kenny');

    eventNameCollection = <String>[];
    eventNameCollection.add('General Meeting');
    eventNameCollection.add('Plan Execution');
    eventNameCollection.add('Project Plan');
    eventNameCollection.add('Consulting');

    colorCollection = <Color>[];
    colorCollection.add(const Color(0xFF0F8644));
    colorCollection.add(const Color(0xFF8B1FA9));
    colorCollection.add(const Color(0xFFD20100));
    colorCollection.add(const Color(0xFFFC571D));

    colorNames = <String>[];
    colorNames.add('Green');
    colorNames.add('Purple');
    colorNames.add('Red');
    colorNames.add('Orange');

    timeZoneCollection = <String>[];
    timeZoneCollection.add('Default Time');
    timeZoneCollection.add('Singapore Standard Time');

    final DateTime today = DateTime.now();
    final Random random = Random();
    for (int month = -1; month < 2; month++) {
      for (int day = -5; day < 5; day++) {
        for (int hour = 9; hour < 18; hour += 5) {
          meetingCollection.add(Meeting(
            from: today
                .add(Duration(days: (month * 30) + day))
                .add(Duration(hours: hour)),
            to: today
                .add(Duration(days: (month * 30) + day))
                .add(Duration(hours: hour + 2)),
            background: colorCollection[random.nextInt(4)],
            startTimeZone: '',
            endTimeZone: '',
            description: 'TEst description',
            isAllDay: false,
            eventName: eventNameCollection[random.nextInt(4)],
            ids: [],
          ));
        }
      }
    }

    return meetingCollection;
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;

  @override
  String getSubject(int index) => appointments![index].eventName;

  @override
  String getStartTimeZone(int index) => appointments![index].startTimeZone;

  @override
  String getNotes(int index) => appointments![index].description;

  @override
  String getEndTimeZone(int index) => appointments![index].endTimeZone;

  @override
  Color getColor(int index) => appointments![index].background;

  @override
  DateTime getStartTime(int index) => appointments![index].from;

  @override
  DateTime getEndTime(int index) => appointments![index].to;
}

class Meeting {
  Meeting(
      {required this.from,
      required this.to,
      this.background = Colors.green,
      this.isAllDay = false,
      this.eventName = '',
      this.startTimeZone = '',
      this.endTimeZone = '',
      this.description = '',
      this.notes = '',
      required this.ids});

   String eventName;
   DateTime from;
   DateTime to;
   Color background;
   bool isAllDay;
   String startTimeZone;
   String endTimeZone;
   String description;
   String notes;
   List<String> ids;
}
