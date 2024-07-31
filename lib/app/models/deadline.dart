import 'package:cloud_firestore/cloud_firestore.dart';

class Deadline {
  String id;
  String category;
  String name;
  bool isEnabled;
  DateTime? deadlineDate;

  Deadline({
    required this.id,
    required this.category,
    required this.name,
    this.isEnabled = false,
    this.deadlineDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'isEnabled': isEnabled,
      'deadlineDate': deadlineDate?.toIso8601String(),
    };
  }

  factory Deadline.fromJson(Map<String, dynamic> json) {
    return Deadline(
      id: json['id'],
      category: json['category'],
      name: json['name'],
      isEnabled: json['isEnabled'],
      deadlineDate: json['deadlineDate'] != null
          ? DateTime.parse(json['deadlineDate'])
          : null,
    );
  }

  Future<void> saveToFirestore(String uid, Deadline deadline) async {
    await FirebaseFirestore.instance
        .collection('deadlines')
        .doc(uid)
        .set(deadline.toJson());
  }


}
 Future<List<Deadline>> retrieveDeadlinesFromFirestore() async {
  deadlines = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('deadlines').get();

      deadlines = snapshot.docs.map((doc) {
        return Deadline.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching deadlines: $e");
    }
    return deadlines;
  }
List<Deadline> deadlines = [];
