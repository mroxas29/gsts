import 'package:cloud_firestore/cloud_firestore.dart';

class CourseDemand {
  final String coursecode;
  final int studentidnumber;
  final String date;

  CourseDemand({
    required this.coursecode,
    required this.studentidnumber,
    required this.date,
  });

  factory CourseDemand.fromFirestore(Map<String, dynamic> data) {
    return CourseDemand(
      coursecode: data['coursecode'] ?? '',
      studentidnumber: data['studentIdNumber'] ?? 0,
      date: data['date'] ??
          '', // Assuming the date is stored as a Firestore Timestamp
    );
  }
}

List<CourseDemand> courseDemands = [];

Map<String, int> courseDemandCountMap = {};
Map<String, Set<String>> courseDemandDatesMap = {};
Map<String, List<int>> demandByMonth = getDemandByMonth(uniqueCourses);
List<Map<String, dynamic>> uniqueCourses = courseDemandCountMap.entries
    .map((entry) => {
          'coursecode': entry.key,
          'demandCount': entry.value,
          'uniqueDates': courseDemandDatesMap[entry.key]?.toList(),
        })
    .toList();
// Convert the maps to a list of unique course codes, their demand counts, and unique dates
void getUniqueCourses() {
  uniqueCourses.clear();
  uniqueCourses = courseDemandCountMap.entries
      .map((entry) => {
            'coursecode': entry.key,
            'demandCount': entry.value,
            'uniqueDates': courseDemandDatesMap[entry.key]?.toList(),
          })
      .toList();
}

Future<List<CourseDemand>> getCourseDemandsFromFirestore() async {
  courseDemands.clear();
  courseDemandCountMap.clear();
  courseDemandDatesMap.clear();

  try {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('offerings').get();

    querySnapshot.docs.forEach((doc) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final CourseDemand courseDemand = CourseDemand.fromFirestore(data);
      courseDemands.add(courseDemand);
      
    });
  } catch (e) {
    print('Error fetching course demands: $e');
  }

  for (var demand in courseDemands) {
    final coursecode = demand.coursecode;
    final date = demand.date;

    courseDemandCountMap[coursecode] ??= 0; // Initialize count if null
    courseDemandCountMap[coursecode] =
        (courseDemandCountMap[coursecode] ?? 0) + 1; // Increment the count

    if (courseDemandDatesMap.containsKey(coursecode)) {
      courseDemandDatesMap[coursecode]?.add(date); // Add the date to the set
    } else {
      courseDemandDatesMap[coursecode] = {
        date
      }; // Initialize the set with the date
    }
  }

  // Convert the maps to a list of unique course codes, their demand counts, and unique dates
  uniqueCourses = courseDemandCountMap.entries
      .map((entry) => {
            'coursecode': entry.key,
            'demandCount': entry.value,
            'uniqueDates': courseDemandDatesMap[entry.key]?.toList(),
          })
      .toList();

  // Sort the list by demand count in descending order
  uniqueCourses.sort((a, b) => b['demandCount'].compareTo(a['demandCount']));
  print("Dito ba yon??${uniqueCourses.toList()}");

  return courseDemands;
}

void updateCourseData() {
  courseDemandCountMap = {};
  courseDemandDatesMap = {};

  for (var demand in courseDemands) {
    final coursecode = demand.coursecode;
    final date = demand.date;

    courseDemandCountMap[coursecode] ??= 0; // Initialize count if null
    courseDemandCountMap[coursecode] =
        (courseDemandCountMap[coursecode] ?? 0) + 1; // Increment the count

    if (courseDemandDatesMap.containsKey(coursecode)) {
      courseDemandDatesMap[coursecode]?.add(date); // Add the date to the set
    } else {
      courseDemandDatesMap[coursecode] = {
        date
      }; // Initialize the set with the date
    }
    print(courseDemandDatesMap);
  }

  // Sort the list by demand count in descending order
  uniqueCourses.sort((a, b) => b['demandCount'].compareTo(a['demandCount']));
  print("Eto ba yon? ${uniqueCourses.toList()}");
}

Map<String, List<int>> getDemandByMonth(
    List<Map<String, dynamic>> courseDemands) {
  return courseDemands.fold<Map<String, List<int>>>({}, (acc, courseDemand) {
    courseDemand['uniqueDates'].forEach((date) {
      final month = DateTime.parse(date).month.toString().padLeft(2, '0');
      if (acc[month] == null) {
        acc[month] = [];
      }
      acc[month]?.add(courseDemand['demandCount']);
    });
    return acc;
  });
}
