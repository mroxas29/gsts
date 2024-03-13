import 'package:flutter/widgets.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/auth_io.dart';

class CalendarClient {
  // For storing the CalendarApi object, this can be used
  // for performing all the operations
  static var calendar;

  static void initializeCalendar(AuthClient client) {
    calendar = cal.CalendarApi(client);
  }
  // For creating a new calendar event
  Future<Map<String, String>> insert({
    required String title,
    required String description,
    required String location,
    required List<cal.EventAttendee> attendeeEmailList,
    required bool shouldNotifyAttendees,
    required bool hasConferenceSupport,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    Map<String, String> eventData = {};

    // If the account has multiple calendars, then select the "primary" one
    String calendarId = "primary";
    cal.Event event = cal.Event();

    event.summary = title;
    event.description = description;
    event.attendees = attendeeEmailList;
    event.location = location;

    if (hasConferenceSupport) {
      cal.ConferenceData conferenceData = cal.ConferenceData();
      cal.CreateConferenceRequest conferenceRequest =
          cal.CreateConferenceRequest();
      conferenceRequest.requestId =
          "${startTime.millisecondsSinceEpoch}-${endTime.millisecondsSinceEpoch}";
      conferenceData.createRequest = conferenceRequest;

      event.conferenceData = conferenceData;
    }

    cal.EventDateTime start = new cal.EventDateTime();
    start.dateTime = startTime;
    start.timeZone = "GMT+05:30";
    event.start = start;

    cal.EventDateTime end = new cal.EventDateTime();
    end.timeZone = "GMT+05:30";
    end.dateTime = endTime;
    event.end = end;
    
    try {
      
      await calendar.events
          .insert(event, calendarId,
              conferenceDataVersion: hasConferenceSupport ? 1 : 0,
              sendUpdates: shouldNotifyAttendees ? "all" : "none")
          .then((value) {
        print("Event Status: ${value.status}");
        if (value.status == "confirmed") {
          String joiningLink = "";
          String eventId;

          eventId = value.id;

          if (hasConferenceSupport) {
            joiningLink =
                "https://meet.google.com/\${value.conferenceData.conferenceId}";
          }

          eventData = {'id': eventId, 'link': joiningLink};

          print('Event added to Google Calendar');
        } else {
          print("Unable to add event to Google Calendar");
        }
      });
    } catch (e) {
      print('Error creating event $e');
    }

    return eventData;
  }
}
