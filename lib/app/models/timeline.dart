import 'package:cloud_firestore/cloud_firestore.dart';

class Timeline {
  DateTime date;
  String title;
  String type;
  String description;

  Timeline({
    required this.date,
    required this.title,
    required this.type,
    required this.description,
  });

  // Convert a Timeline object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'title': title,
      'type': type,
      'description': description,
    };
  }

  // Create a Timeline object from a map
  factory Timeline.fromMap(Map<String, dynamic> map) {
    return Timeline(
      date: DateTime.parse(map['date']),
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

Future<void> fetchStudentTimelines(String studentUid) async {
  timelines.clear();
  try {
    // Retrieve the document from Firestore
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(
            'timelines') // Collection name where student documents are stored
        .doc(studentUid) // Document ID for the specific student
        .get();

    if (snapshot.exists) {
      // Extract the 'timeline' field from the document
      List<dynamic> timelineData = snapshot.get('timeline');

      // Parse the data into List<Timeline>
      List<Timeline> studentTimelines = timelineData.map((item) {
        return Timeline(
          date: DateTime.parse(item['date']), // Convert the string to DateTime
          title: item['title'],
          type: item['type'],
          description: item['description'],
        );
      }).toList();
      timelines = studentTimelines;
      // You can now use studentTimelines in your application
      print("Retrieved timelines: $studentTimelines");
    } else {
      print("No document found for student ID: $studentUid");
    }
  } catch (e) {
    print("Error retrieving timelines: $e");
  }
}

List<Timeline> timelines = [];

Future<void> addTimelineEvent(String studentUid, Timeline newTimeline) async {
  try {
    // Prepare the timeline data
    Map<String, dynamic> timelineData = {
      'date':
          newTimeline.date.toIso8601String(), // Convert DateTime to ISO string
      'title': newTimeline.title,
      'type': newTimeline.type,
      'description': newTimeline.description,
    };

    // Reference to the Firestore document
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('timelines') // Collection name
        .doc(studentUid); // Document ID for the specific student

    // Fetch the current document
    DocumentSnapshot snapshot = await docRef.get();

    if (snapshot.exists) {
      // Retrieve the current list of timelines
      List<dynamic> currentTimelineList = snapshot.get('timeline') ?? [];

      // Append the new timeline event to the list
      currentTimelineList.add(timelineData);

      // Update the document with the new list
      await docRef.update({'timeline': currentTimelineList}).then((value) {
        print("Timeline event added successfully");
      }).catchError((error) {
        print("Failed to add timeline event: $error");
      });
    } else {
      // If the document does not exist, create it with the new timeline
      await docRef.set({
        'timeline': [timelineData]
      }).then((value) {
        print("Timeline document created and event added successfully");
      }).catchError((error) {
        print("Failed to create timeline document: $error");
      });
    }
  } catch (e) {
    print("Error adding timeline event: $e");
  }
}
