import 'dart:math';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:sysadmindb/api/calendar/appointment_editor.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleAPI;
import 'package:http/io_client.dart' show IOClient, IOStreamedResponse;
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

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
late GoogleDataSource events;
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
  late List<GoogleAPI.Event> appointments;
  CalendarController calendarController = CalendarController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '703443900752-d0o2p65v12dkmfq8vt4dd8pmtp3k7ish.apps.googleusercontent.com',
    scopes: <String>[
      GoogleAPI.CalendarApi.calendarScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  @override
  void initState() {
    // appointments = getGoogleEventsData() as List<GoogleAPI.Event>;
    // events = GoogleDataSource(events: [appointments]);
    selectedAppointment = null;
    selectedColorIndex = 0;
    selectedTimeZoneIndex = 0;
    subject = '';
    notes = '';
    super.initState();
    getMeetingDetails();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        //getGoogleEventsData();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<List<GoogleAPI.Event>> getGoogleEventsData() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    var httpClient = (await _googleSignIn.authenticatedClient())!;

    final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
    final GoogleAPI.Events calEvents = await calendarApi.events.list(
      "primary",
    );

    final List<GoogleAPI.Event> appointments = <GoogleAPI.Event>[];
    if (calEvents.items != null) {
      for (int i = 0; i < calEvents.items!.length; i++) {
        final GoogleAPI.Event event = calEvents.items![i];
        if (event.start == null) {
          continue;
        }
        appointments.add(event);
      }
    }

    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getGoogleEventsData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Expanded(child: getEventCalendar(onCalendarTapped, snapshot));
      },
    );
  }

  @override
  void dispose() {
    if (_googleSignIn.currentUser != null) {
      _googleSignIn.disconnect();
      _googleSignIn.signOut();
    }

    super.dispose();
  }

  SfCalendar getEventCalendar(
      CalendarTapCallback calendarTapCallback, AsyncSnapshot snapshot) {
    return SfCalendar(
        view: CalendarView.month,
        controller: calendarController,
        allowedViews: const [
          CalendarView.week,
          CalendarView.timelineWeek,
          CalendarView.month
        ],
        dataSource: GoogleDataSource(events: snapshot.data),
        onTap: calendarTapCallback,
        appointmentBuilder: (context, calendarAppointmentDetails) {
          final GoogleAPI.Event meeting =
              calendarAppointmentDetails.appointments.first;
          return Container(
            color: Colors.green,
            child: Text(meeting.summary!),
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
            description: '',
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
/*
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
*/

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({required List<GoogleAPI.Event>? events}) {
    appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.start?.date ?? event.start!.dateTime!.toLocal();
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].start.date != null;
  }

  @override
  DateTime getEndTime(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.endTimeUnspecified != null && event.endTimeUnspecified!
        ? (event.start?.date ?? event.start!.dateTime!.toLocal())
        : (event.end?.date != null
            ? event.end!.date!.add(const Duration(days: -1))
            : event.end!.dateTime!.toLocal());
  }

  @override
  String getLocation(int index) {
    return appointments![index].location ?? '';
  }

  @override
  String getNotes(int index) {
    return appointments![index].description ?? '';
  }

  @override
  String getSubject(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.summary == null || event.summary!.isEmpty
        ? 'No Title'
        : event.summary!;
  }
}

class GoogleAPIClient extends IOClient {
  final Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url,
          headers: (headers != null ? (headers..addAll(_headers)) : headers));
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
