import 'package:cloud_firestore/cloud_firestore.dart';


class EN19Form {
  String lastName;
  String firstName;
  String middleName;
  String idNumber;
  String college;
  String program;
  bool passedComprehensiveExams;
  bool submittedCertificate;
  String adviserName;
  String enrollmentStage;
  DateTime date;
  String proposedTitle;
  String leadPanel;
  List<String> panelMembers;
  String defenseDate; // Changed to String
  bool signedByGSC;
  bool signedByAdviser;
  String defenseTime;
  String mainTitle;
  String defenseType;
  String verdict;
  
  EN19Form({
    required this.lastName,
    required this.firstName,
    required this.middleName,
    required this.idNumber,
    required this.college,
    required this.program,
    required this.passedComprehensiveExams,
    required this.submittedCertificate,
    required this.adviserName,
    required this.enrollmentStage,
    required this.date,
    required this.proposedTitle,
    required this.leadPanel,
    required this.panelMembers,
    required this.defenseDate, // Added to constructor
    required this.signedByGSC,
    required this.signedByAdviser,
    required this.defenseTime,
    required this.mainTitle,
    required this.defenseType,
    required this.verdict,
  });

  Map<String, dynamic> toMap() {
    return {
      'lastName': lastName,
      'firstName': firstName,
      'middleName': middleName,
      'idNumber': idNumber,
      'college': college,
      'program': program,
      'passedComprehensiveExams': passedComprehensiveExams,
      'submittedCertificate': submittedCertificate,
      'adviserName': adviserName,
      'enrollmentStage': enrollmentStage,
      'date': date.toIso8601String(),
      'proposedTitle': proposedTitle,
      'leadPanel': leadPanel,
      'panelMembers': panelMembers,
      'defenseDate': defenseDate, // Added to map
      'signedByGSC': signedByGSC,
      'signedByAdviser': signedByAdviser,
      'defenseTime':defenseTime,
      'mainTitle': mainTitle,
      'defenseType' : defenseType,
      'verdict': verdict
    };
  }

  factory EN19Form.fromMap(Map<String, dynamic> map) {
    return EN19Form(
        lastName: map['lastName'],
        firstName: map['firstName'],
        middleName: map['middleName'] ?? '',
        idNumber: map['idNumber'],
        college: map['college'],
        program: map['program'],
        passedComprehensiveExams: map['passedComprehensiveExams'],
        submittedCertificate: map['submittedCertificate'],
        adviserName: map['adviserName'],
        enrollmentStage: map['enrollmentStage'],
        date: DateTime.parse(map['date']),
        proposedTitle: map['proposedTitle'],
        leadPanel: map['leadPanel'],
        panelMembers: List<String>.from(map['panelMembers']),
        defenseDate: map['defenseDate'], // Added to factory constructor
        signedByGSC: map['signedByGSC'],
        signedByAdviser: map['signedByAdviser'],
        defenseTime: map['defenseTime'],
        mainTitle: map['mainTitle'],
        defenseType: map['defenseType'],
        verdict: map['verdict']
        );
  }

  Future<void> saveFormToFirestore(EN19Form form, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('defenseInformation')
          .doc(uid)
          .set(form.toMap());
      print('Form saved successfully');
    } catch (e) {
      print('Error saving form: $e');
    }
  }

  static Future<EN19Form?> getFormFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('defenseInformation')
          .doc(uid)
          .get();

      if (doc.exists) {
        print(uid);
        return EN19Form.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print('Document does not exist');
        // Create EN19Form object
        EN19Form form = EN19Form(
          proposedTitle: '',
          lastName: '',
          firstName: '',
          middleName: '',
          idNumber: '',
          college: '',
          program: '',
          passedComprehensiveExams: false,
          submittedCertificate: false,
          adviserName: '',
          enrollmentStage: '',
          date: DateTime.now(),
          leadPanel: '',
          panelMembers: [],
          defenseDate: ' ',
          signedByGSC: false,
          signedByAdviser: false,
          defenseTime: ' ',
          mainTitle: ' ',
          defenseType: ' ',
          verdict: ' ',
        );

        return form;
      }
    } catch (e) {
      print('Error retrieving form: $e');
      EN19Form form = EN19Form(
          proposedTitle: '',
          lastName: '',
          firstName: '',
          middleName: '',
          idNumber: '',
          college: '',
          program: '',
          passedComprehensiveExams: false,
          submittedCertificate: false,
          adviserName: '',
          enrollmentStage: '',
          date: DateTime.now(),
          leadPanel: '',
          panelMembers: [],
          defenseDate: ' ',
          signedByGSC: false,
          signedByAdviser: false,
          defenseTime: '',
           mainTitle: ' ',
           defenseType: ' ',
           verdict:  ' ',
      );

      return form;
    }
  }

  static Future<bool> hasEn19Form(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('defenseInformation')
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking document existence: $e');
      return false;
    }
  }

}
 Future<List<EN19Form>> getAllFormsFromFirestore() async {
    try {
      // Get a reference to the collection
      CollectionReference formsCollection =
          FirebaseFirestore.instance.collection('defenseInformation');

      // Get all documents in the collection as a query snapshot
      QuerySnapshot querySnapshot = await formsCollection.get();

      // Initialize an empty list to store the forms
      List<EN19Form> allDefenseForms = [];

      // Loop through each document in the snapshot
      for (var doc in querySnapshot.docs) {
        // Check if the document exists
        if (doc.exists) {
          // Convert the document data to an EN19Form object
          EN19Form form = EN19Form.fromMap(doc.data() as Map<String, dynamic>);
          // Add the form to the list
          allDefenseForms.add(form);
        } else {
          print('Document ${doc.id} does not exist');
        }
      }

      return allDefenseForms;
    } catch (e) {
      print('Error retrieving forms: $e');
      return []; // Return an empty list on error
    }
  }
