import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:sysadmindb/app/models/AcademicCalendar.dart';
import 'package:sysadmindb/app/models/courses.dart';
import 'package:sysadmindb/app/models/en-19.dart';
import 'package:sysadmindb/app/models/faculty.dart';
import 'package:sysadmindb/app/models/studentPOS.dart';
import 'package:sysadmindb/app/models/student_user.dart';
import 'package:sysadmindb/main.dart';
import 'package:sysadmindb/app/models/user.dart';
import 'package:sysadmindb/ui/defense_card.dart';
import 'package:sysadmindb/ui/defense_sched.dart';
import 'package:sysadmindb/ui/forms/form.dart';
import 'package:sysadmindb/ui/reusable_widgets.dart';
import 'package:sysadmindb/ui/forms/user_form_dialog.dart';
import 'dart:math';

import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    MaterialApp(home: DITSec()),
  );
}

class DITSec extends StatefulWidget {
  const DITSec({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<DITSec> {
  final controller = TextEditingController();
  var collection = FirebaseFirestore.instance.collection('users');
  late List<Map<String, dynamic>> items;
  bool isLoaded = true;
  List<user> foundUser = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<List<Student>> graduateStudents = convertToStudentList(users);
  List<Course> foundCourse = [];
  bool isEditing = false;
  bool isValidPass = false;

  /// The currently selected index of the bar
  int selectedIndex = 0;
  String selectedProgramFilter = 'All';
  List<EN19Form> filteredDefenses = [];
  @override
  initState() {
    foundUser = users;
    foundCourse = courses;
    print("set state for found users");
    super.initState();
    filterDefenses();
  }

  void filterDefenses() {
    if (selectedProgramFilter == 'All') {
      filteredDefenses = allDefenseForms;
    } else {
      filteredDefenses = allDefenseForms
          .where((defense) => defense.program == selectedProgramFilter)
          .toList();
    }
  }

  void changeScreen(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void savePasswordChanges(
      String newPassword,
      bool isMatching,
      bool isatmost64chars,
      bool hasNum,
      bool hasSpecial,
      bool curpassinc,
      bool is12chars) async {
    if (isMatching &&
        isatmost64chars &&
        hasNum &&
        hasSpecial &&
        curpassinc &&
        is12chars) {
      try {
        // Update password if successfully reauthenticated
        await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password changed successfully'),
            duration: Duration(seconds: 5),
          ),
        );
        setState(() {
          curpass = newPassword;
        });
      } catch (updateError) {
        print('Error updating password: $updateError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating password: $updateError'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } else {
      if (!curpassinc) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Current password is incorrect'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('See password requirements'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  bool is12charslong(String password) {
    return password.length >= 12;
  }

  bool isatmost64chars(String password) {
    return password.length <= 64;
  }

  bool hasSpecialChar(String password) {
    // Replace this with your logic to check if password has at least one special character
    RegExp specialCharRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
    return specialCharRegex.hasMatch(password);
  }

  bool hasNumber(String password) {
    // Replace this with your logic to check if password has at least one number
    RegExp numberRegex = RegExp(r'\d');
    return numberRegex.hasMatch(password);
  }

// check if the password meets the specified requirements
  String _capitalize(String input) {
    if (input.isEmpty) {
      return '';
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
// Function to handle time parsing with error handling

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  TimeOfDay? tryParseTime(String timeString) {
    if (timeString == "No time set") {
      return null;
    }

    try {
      // Split the timeString into hours and minutes
      List<String> parts = timeString.split(':');
      int hours = int.parse(parts[0]);
      int minutes =
          int.parse(parts[1].split(' ')[0]); // Extract minutes without AM/PM

      // Convert 12-hour format to 24-hour format
      if (timeString.contains('PM') && hours < 12) {
        hours += 12;
      } else if (timeString.contains('AM') && hours == 12) {
        hours = 0;
      }

      // Create and return the TimeOfDay object
      return TimeOfDay(hour: hours, minute: minutes);
    } catch (e) {
      print("Error parsing time: $e");
      return null;
    }
  }

  DateTime? tryParseDate(String dateString) {
    if (dateString == "No date set") {
      return null;
    }
    try {
      // Try parsing with your expected date format (adjust if needed)
      return DateFormat('MMMM d, yyyy')
          .parse(dateString); // Assuming YYYY-MM-DD format
    } catch (e) {
      print("Error parsing date: $e");
      return null;
    }
  }

  // Function to capitalize the first letter of a string
  String capitalizeFirstLetter(String text) {
    return text.replaceFirst(RegExp(r'^[a-z]'), text[0].toUpperCase());
  }

  void showDefenseDetailsDialog(BuildContext context, EN19Form defense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController dateController = TextEditingController(
          text: defense.defenseDate != "No date set"
              ? defense.defenseDate
              : "No date set",
        );
        TimeOfDay selectedTime = defense.defenseTime != "No time set"
            ? tryParseTime(defense.defenseTime) ?? TimeOfDay.now()
            : TimeOfDay.now();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: getRandomColor(),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Defense details for ${capitalizeFirstLetter(defense.firstName)} ${capitalizeFirstLetter(defense.lastName)}',
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: defense.defenseDate != "No date set"
                                  ? tryParseDate(defense.defenseDate) ??
                                      DateTime.now()
                                  : DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dateController.text = DateFormat('MMMM d, yyyy')
                                    .format(pickedDate);
                                defense.defenseDate = DateFormat('MMMM d, yyyy')
                                    .format(pickedDate);
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                defense.defenseDate != "No date set"
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: Text(
                            defense.defenseDate != "No date set"
                                ? dateController.text
                                : 'No date set',
                            style: TextStyle(
                              color: defense.defenseDate != "No date set"
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedTime = pickedTime;
                                defense.defenseTime =
                                    pickedTime.format(context);
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                defense.defenseTime != "No time set"
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: Text(
                            defense.defenseTime == 'No time set'
                                ? 'No time set'
                                : selectedTime.format(context),
                            style: TextStyle(
                              color: defense.defenseTime != "No time set"
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Verdict:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        SizedBox(width: 5),
                        Text(defense.verdict,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'ID Number:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Text(defense.idNumber),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Enrollment Stage:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Text(defense.enrollmentStage),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Title:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Text(defense.mainTitle),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Adviser:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Text(defense.adviserName),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Lead Panel: ${defense.leadPanel}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Panel Members:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        // Text for panelMembers (if any)
                        Text(defense.panelMembers.join("\n")),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Defense Files:'),
                        SizedBox(width: 5),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () async {
                                try {
                                  String fileName =
                                      '${defense.idNumber}/Defense Forms/EN-18DefenseForm_${defense.idNumber}.pdf';
                                  final imageUrl = await FirebaseStorage
                                      .instance
                                      .ref()
                                      .child(fileName)
                                      .getDownloadURL();
                                  if (await canLaunch(imageUrl.toString())) {
                                    await launch(imageUrl.toString());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to download file'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('File does not exist'),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.file_download),
                                  SizedBox(
                                      width:
                                          8), // Add some space between the icon and the text
                                  Text('Download EN-18 Defense Form'),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Panel Report:'),
                        SizedBox(width: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.file_download,
                              ),
                              onPressed: () async {
                                try {
                                  String fileName =
                                      '${defense.idNumber}/Defense Forms/Form-R_23_${defense.idNumber}.pdf';
                                  final imageUrl = await FirebaseStorage
                                      .instance
                                      .ref()
                                      .child(fileName)
                                      .getDownloadURL();
                                  if (await canLaunch(imageUrl.toString())) {
                                    await launch(imageUrl.toString());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to download file'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('File does not exist'),
                                    ),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.attach_file),
                              onPressed: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles();

                                PlatformFile file = result!.files.first;
                                String fileName =
                                    '${defense.idNumber}/Defense Forms/Form-R_23_${defense.idNumber}.pdf';
                                Uint8List fileBytes = file.bytes!;
                                final ref = FirebaseStorage.instance
                                    .ref()
                                    .child(fileName);
                                await ref.putData(fileBytes);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Uploaded successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                                width:
                                    8), // Add some space between the icons and the text
                            Text(
                              'Download/Upload Panel Chair Report Form',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Evaluation Form:'),
                        SizedBox(width: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.file_download,
                              ),
                              onPressed: () async {
                                try {
                               String fileName =
                                      '${defense.idNumber}/Defense Forms/Eval_Form_${defense.lastName}_${defense.firstName}.docx';
                                  final imageUrl = await FirebaseStorage
                                      .instance
                                      .ref()
                                      .child(fileName)
                                      .getDownloadURL();
                                  if (await canLaunch(imageUrl.toString())) {
                                    await launch(imageUrl.toString());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to download file'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('File does not exist'),
                                    ),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.attach_file),
                              onPressed: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles();

                                PlatformFile file = result!.files.first;
                                String fileName =
                                    '${defense.idNumber}/Defense Forms/Eval_Form_${defense.lastName}_${defense.firstName}.docx';
                                Uint8List fileBytes = file.bytes!;
                                final ref = FirebaseStorage.instance
                                    .ref()
                                    .child(fileName);
                                await ref.putData(fileBytes);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Uploaded successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                                width:
                                    8), // Add some space between the icons and the text
                            Text(
                              'Download/Upload Evaluation Form',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    String formattedDate = dateController.text;
                    String formattedTime = selectedTime.format(context);

                    DateTime selectedDateTime;
                    try {
                      selectedDateTime =
                          DateFormat('MMMM d, yyyy').parse(formattedDate);
                      selectedDateTime = DateTime(
                        selectedDateTime.year,
                        selectedDateTime.month,
                        selectedDateTime.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                    } catch (e) {
                      selectedDateTime = DateTime.now();
                    }

                    if (selectedDateTime.isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid date or time'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    EN19Form formToModify = allDefenseForms.firstWhere(
                        (form) => form.idNumber == defense.idNumber);
                    setState(() {
                      formToModify.defenseDate = formattedDate;
                      formToModify.defenseTime = formattedTime;
                    });

                    String? studentUid = studentList
                        .firstWhere((student) =>
                            student.idnumber.toString() == defense.idNumber)
                        .uid;
                    try {
                      FirebaseFirestore.instance
                          .collection('defenseInformation')
                          .doc(studentUid)
                          .update({
                        'defenseDate': defense.defenseDate,
                        'defenseTime': defense.defenseTime,
                      });
                      print('Defense details updated successfully.');
                    } catch (e) {
                      print('Error updating defense details: $e');
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<EN19Form> getPastDefenseSchedules(List<EN19Form> allDefenseForms) {
    // Define the date and time format used in defenseDate and defenseTime
    final DateFormat dateFormat = DateFormat('MMMM d, yyyy');
    final DateFormat timeFormat = DateFormat('hh:mm a');

    DateTime parseDefenseDateTime(String date, String time) {
      final DateTime parsedDate = dateFormat.parse(date);
      final DateTime parsedTime = timeFormat.parse(time);

      return DateTime(parsedDate.year, parsedDate.month, parsedDate.day,
          parsedTime.hour, parsedTime.minute);
    }

    final DateTime now = DateTime.now();

    List<EN19Form> pastSchedules = allDefenseForms.where((defense) {
      if (defense.defenseDate == 'No date set' ||
          defense.defenseTime == 'No time set') {
        return false;
      }

      final DateTime defenseDateTime =
          parseDefenseDateTime(defense.defenseDate, defense.defenseTime);
      return defenseDateTime.isBefore(now);
    }).toList();

    return pastSchedules;
  }

  @override
  Widget build(BuildContext context) {
    bool is12chars = is12charslong(newPasswordController.text);
    bool isAtMost64chars = isatmost64chars(newPasswordController.text);
    bool hasSpecial = hasSpecialChar(newPasswordController.text);
    bool hasNum = hasNumber(newPasswordController.text);
    bool isMatching =
        confirmNewPasswordController.text == newPasswordController.text;
    bool curpassinc = false;

    List<String> scheduledDates = allDefenseForms
        .map((defense) => defense.defenseDate)
        .where((date) => date != "No date set")
        .toSet()
        .toList();

    List<EN19Form> noScheduleDates = allDefenseForms
        .where((defense) =>
            defense.defenseDate == 'No date set' ||
            defense.defenseTime == 'No time set')
        .toList();

    List<EN19Form> hasSchedDates = allDefenseForms
        .where((defense) =>
            defense.defenseDate != 'No date set' &&
            defense.defenseTime != 'No time set')
        .toList();

    List<EN19Form> pastDefenses = getPastDefenseSchedules(hasSchedDates);

// Remove pastDefenses from hasSchedDates
    hasSchedDates.removeWhere((defense) => pastDefenses.contains(defense));

    scheduledDates.sort((a, b) {
      if (a == "No date set" && b == "No date set") {
        return 0;
      } else if (a == "No date set") {
        return 1;
      } else if (b == "No date set") {
        return -1;
      } else {
        DateTime dateA = DateFormat("MMMM d, yyyy").parse(a);
        DateTime dateB = DateFormat("MMMM d, yyyy").parse(b);
        return dateA.compareTo(dateB);
      }
    });

    /// Views to display
    List<Widget> views = [
      //Defense SCREEN
      Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Row(
            children: [
              Expanded(
                child: DefenseSchedulesAppBar(
                  currentStudentIndex: hasSchedDates.length,
                  totalStudents: allDefenseForms.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: selectedProgramFilter,
                  onChanged: (newValue) {
                    setState(() {
                      selectedProgramFilter = newValue!;
                      filterDefenses();
                    });
                  },
                  items: ['All', 'MIT', 'MSIT']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'To-Schedule',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (EN19Form defense in noScheduleDates.where(
                              (sched) =>
                                  selectedProgramFilter == 'All' ||
                                  sched.program == selectedProgramFilter))
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  showDefenseDetailsDialog(context, defense);
                                },
                                child: DefenseCard(
                                  defense: defense,
                                  cardColor: Color.fromARGB(255, 53, 98, 134),
                                ),
                              ),
                            ),
                          if (noScheduleDates
                              .where((sched) =>
                                  (selectedProgramFilter == 'All' ||
                                      sched.program == selectedProgramFilter))
                              .isEmpty)
                            Text('No new defenses to set dates'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Defenses Scheduled',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (EN19Form defense in hasSchedDates.where((sched) {
                            if (selectedProgramFilter == 'All' ||
                                sched.program == selectedProgramFilter) {
                              return true;
                            }
                            return false;
                          }))
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  showDefenseDetailsDialog(context, defense);
                                },
                                child: DefenseCard(
                                  defense: defense,
                                  cardColor: Color.fromARGB(255, 7, 104, 28),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            'Finished Defenses',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              String fileName =
                                  'templates/R23 - Panel Chair Report.pdf';
                              final imageUrl = await FirebaseStorage.instance
                                  .ref()
                                  .child(fileName)
                                  .getDownloadURL();
                              if (await canLaunch(imageUrl.toString())) {
                                await launch(imageUrl.toString());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to download file'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              '(Download panel report template)',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 10),
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Download Defense Evaluation Sheet template: ',
                            style: TextStyle(color: Colors.black, fontSize: 10),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          TextButton(
                            onPressed: () async {
                              String fileName =
                                  'templates/MIT Final Capstone Project Defense Evaluation Sheet.docx';
                              final imageUrl = await FirebaseStorage.instance
                                  .ref()
                                  .child(fileName)
                                  .getDownloadURL();
                              if (await canLaunch(imageUrl.toString())) {
                                await launch(imageUrl.toString());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to download file'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'MIT',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 10),
                            ),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          TextButton(
                            onPressed: () async {
                              String fileName =
                                  'templates/MSIT Proposal Redefense Evaluation Sheet.docx';
                              final imageUrl = await FirebaseStorage.instance
                                  .ref()
                                  .child(fileName)
                                  .getDownloadURL();
                              if (await canLaunch(imageUrl.toString())) {
                                await launch(imageUrl.toString());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to download file'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'MSIT',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: pastDefenses.where((defense) {
                            if (selectedProgramFilter == 'All') {
                              return true;
                            } else if (selectedProgramFilter ==
                                defense.program) {
                              return true;
                            }
                            return false;
                          }).map((defense) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  showDefenseDetailsDialog(context, defense);
                                },
                                child: DefenseCard(
                                  defense: defense,
                                  cardColor:

                                      // Handle parse error if needed
                                      Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            );
                          }).toList()),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1, // Takes 1/3 of the screen
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Color.fromARGB(52, 88, 88, 88),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: scheduledDates.length,
                          itemBuilder: (context, index) {
                            String dateString = scheduledDates[index];
                            DateTime date = dateString == "No date set"
                                ? DateTime.now()
                                : DateFormat("MMMM d, yyyy").parse(dateString);

                            String formattedDate = dateString == "No date set"
                                ? dateString
                                : DateFormat('d MMMM').format(date);

                            // Filter defense forms for the current date
                            List<EN19Form> defensesForDate = filteredDefenses
                                .where((defense) =>
                                    defense.defenseDate == dateString)
                                .toList();

                            // Sort defenses for the current date by time in ascending order
                            defensesForDate.sort((a, b) {
                              // Handle cases where time is not specified
                              if (a.defenseTime == "No defense time set")
                                return 1;
                              if (b.defenseTime == "No defense time set")
                                return -1;

                              // Parse and compare time strings
                              try {
                                // Parse time strings to DateTime objects
                                DateTime timeA =
                                    DateFormat('hh:mm a').parse(a.defenseTime!);
                                DateTime timeB =
                                    DateFormat('hh:mm a').parse(b.defenseTime!);

                                // Compare the parsed DateTime objects
                                return timeA.compareTo(
                                    timeB); // Compare in ascending order
                              } catch (e) {
                                print("Error parsing time: $e");
                                return 0; // Default to no change in sorting order
                              }
                            });
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors
                                            .grey, // Grey color for the date
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  // Sorted defenses for the current date by time
                                  ...defensesForDate.map((defense) => InkWell(
                                        onTap: () {
                                          // Handle click event
                                          showDefenseDetailsDialog(
                                              context, defense);
                                          print('Clicked ${defense.program}');
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      defense.defenseTime ??
                                                          'No time specified',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      width:
                                                          3, // Increased width for the separator line
                                                      height: 20,
                                                      color: Color((Random()
                                                                          .nextDouble() *
                                                                      0xFFFFFF)
                                                                  .toInt() <<
                                                              0)
                                                          .withOpacity(1.0),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          defense.program,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .grey, // Grey color for the degree
                                                            fontSize:
                                                                12, // Adjusted font size
                                                          ),
                                                        ),
                                                        Text(
                                                          '${defense.firstName} ${defense.lastName}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                            ],
                                          ),
                                        ),
                                      )),
                                  SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 560,
                      child: SingleChildScrollView(
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 200, 70),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align text to the left
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Your profile",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  "${_capitalize(currentUser.displayname['firstname']!)} ${_capitalize(currentUser.displayname['lastname']!)} ",
                                  style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 23, 71, 25)),
                                ),
                                Text(currentUser.email),
                                Text('Status: ${currentUser.status}'),
                                Text(
                                  isValidPass
                                      ? '🔒 Your password is secure'
                                      : '✖ Your password is not secure',
                                  style: TextStyle(
                                      color: isValidPass
                                          ? Colors.green
                                          : Colors.red),
                                )
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 560, // Set your desired width
                    child: SingleChildScrollView(
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 200, 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Password Management",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              TextFormField(
                                controller: currentPasswordController,
                                enabled: isEditing,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Current Password',
                                ),
                                validator: (value) {
                                  if (value != curpass) {
                                    curpassinc = false;
                                    return 'Current password is incorrect';
                                  }
                                  return null;
                                },
                              ),
                              TextField(
                                controller: newPasswordController,
                                enabled: isEditing,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                ),
                                onChanged: (password) {
                                  setState(() {
                                    is12chars = is12charslong(password);
                                    isAtMost64chars = isatmost64chars(password);
                                    hasSpecial = hasSpecialChar(password);
                                    hasNum = hasNumber(password);
                                    isMatching =
                                        confirmNewPasswordController.text ==
                                            newPasswordController.text;
                                  });
                                },
                              ),
                              TextField(
                                controller: confirmNewPasswordController,
                                enabled: isEditing,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Confirm New Password',
                                ),
                                onChanged: (passwordTextController) {
                                  setState(() {
                                    isMatching =
                                        confirmNewPasswordController.text ==
                                            newPasswordController.text;
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Password Requirements:',
                                    style: TextStyle(
                                      color: isEditing
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    is12chars
                                        ? '✔ At least 12 characters long'
                                        : '✖ At least 12 characters long',
                                    style: TextStyle(
                                      color: is12chars
                                          ? Colors.green
                                          : (isEditing
                                              ? Colors.red
                                              : Colors.grey),
                                    ),
                                  ),
                                  Text(
                                    isAtMost64chars
                                        ? '✔ At most 64 characters long'
                                        : '✖ At most 64 characters long',
                                    style: TextStyle(
                                      color: isEditing
                                          ? (isAtMost64chars
                                              ? Colors.green
                                              : Colors.red)
                                          : Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    hasSpecial
                                        ? '✔ Contains at least one special character'
                                        : '✖ Contains at least one special character',
                                    style: TextStyle(
                                      color: hasSpecial
                                          ? Colors.green
                                          : (isEditing
                                              ? Colors.red
                                              : Colors.grey),
                                    ),
                                  ),
                                  Text(
                                    hasNum
                                        ? '✔ Contains at least one number'
                                        : '✖ Contains at least one number',
                                    style: TextStyle(
                                      color: hasNum
                                          ? Colors.green
                                          : (isEditing
                                              ? Colors.red
                                              : Colors.grey),
                                    ),
                                  ),
                                  Text(
                                    isMatching
                                        ? '✔ New passwords match'
                                        : '✖ Passwords do not match',
                                    style: TextStyle(
                                      color: isEditing
                                          ? (isMatching
                                              ? Colors.green
                                              : Colors.red)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isEditing = !isEditing;
                                    if (!isEditing) {
                                      // Save changes when editing is done
                                      //updateUserProfile();
                                      if (currentPasswordController.text ==
                                          curpass) {
                                        curpassinc = true;
                                      }
                                      savePasswordChanges(
                                        newPasswordController.text,
                                        isMatching,
                                        isAtMost64chars,
                                        hasNum,
                                        hasSpecial,
                                        curpassinc,
                                        is12chars,
                                      );
                                      // Clear password fields
                                      currentPasswordController.clear();
                                      newPasswordController.clear();
                                      confirmNewPasswordController.clear();
                                    }
                                  });
                                },
                                child: Text(
                                  isEditing
                                      ? 'Save Password'
                                      : 'Change Password',
                                  style: TextStyle(
                                      color: isEditing
                                          ? const Color.fromARGB(
                                              255, 23, 71, 25)
                                          : Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )),
    ];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // The row is needed to display the current view

        body: Row(
          children: [
            /// Pretty similar to the BottomNavigationBar!
            SideNavigationBar(
              header: SideNavigationBarHeader(
                  image: CircleAvatar(),
                  title: Text(
                    "${currentUser.displayname['firstname']!} ${currentUser.displayname['lastname']!}",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Text(
                    emailTextController.text.toLowerCase(),
                    style: TextStyle(
                      color: Color(0xFF747475),
                      fontSize: 12,
                    ),
                  )),
              footer: SideNavigationBarFooter(
                  label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.logout,
                      color: Color(0xFF747475),
                    ),
                    label: Text(
                      'Log Out',
                      style: TextStyle(color: Color(0xFF747475)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: () {
                      users.clear();
                      courses.clear();
                      activecourses.clear();
                      studentList.clear();
                      wrongCreds = false;
                      correctCreds = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ],
              )),
              selectedIndex: selectedIndex,
              items: const [
                SideNavigationBarItem(
                  icon: Icons.dashboard,
                  label: 'Defense Scheduling', // OLD CODE: label: 'Students',
                ),
                SideNavigationBarItem(
                    icon: Icons.settings, label: 'Profile Settings')
              ],
              onTap: changeScreen,
              toggler: SideBarToggler(
                  expandIcon: Icons.keyboard_arrow_right,
                  shrinkIcon: Icons.keyboard_arrow_left,
                  onToggle: () {}),
              theme: SideNavigationBarTheme(
                itemTheme: SideNavigationBarItemTheme(
                  labelTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 14),
                  unselectedItemColor: Color(0xFF747475),
                  selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
                  iconSize: 20,
                ),
                backgroundColor: Color(0xF0151718),
                togglerTheme: SideNavigationBarTogglerTheme(
                    expandIconColor: Colors.white,
                    shrinkIconColor: Colors.white),
                dividerTheme: SideNavigationBarDividerTheme.standard(),
              ),
            ),

            Expanded(
              child: views.elementAt(selectedIndex),
            )
          ],
        ),
      ),
    );
  }
}
