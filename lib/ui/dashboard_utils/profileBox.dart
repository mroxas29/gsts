import 'package:flutter/material.dart';
import 'package:sysadmindb/ui/dashboard/gsc_dash.dart';
import 'package:sysadmindb/ui/info_page/studentInfoPage.dart';

class ProfileBox extends StatefulWidget {
  final int totalStudents;
  final int newStudents;
  final int deviatedStudents;
  final int ineligibleStudents;
  final int cardCount;
  final int graduatingStudents;
  const ProfileBox(
      {super.key,
      required this.totalStudents,
      required this.newStudents,
      required this.deviatedStudents,
      required this.cardCount,
      required this.ineligibleStudents,
      required this.graduatingStudents});

  @override
  State<ProfileBox> createState() => _ProfileBoxState();
}

class _ProfileBoxState extends State<ProfileBox> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4, // Adjust the elevation as needed
      color: widget.cardCount == 0
          ? Color.fromARGB(255, 53, 98, 134)
          : widget.cardCount == 2
              ? Color.fromARGB(255, 187, 63, 54)
              : widget.cardCount == 1
                  ? const Color.fromARGB(255, 170, 63, 189)
                  : widget.cardCount == 4
                      ? const Color.fromARGB(255, 28, 95, 30)
                      : Colors.black,
      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300, maxHeight: 100),
        child: Stack(
          children: [
            if (widget.cardCount == 0)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(17, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.people,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Total Students',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Spacer(),
                    Text(
                      widget.totalStudents.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 35,
                      ),
                    )
                  ],
                ),
              ),
            if (widget.cardCount == 1)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(17, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.new_releases,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'New Students',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Spacer(),
                    Text(
                      widget.newStudents.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 35,
                      ),
                    )
                  ],
                ),
              ),
            if (widget.cardCount == 2)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(17, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.call_split_outlined,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Deviated Students',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Spacer(),
                    Text(
                      widget.deviatedStudents.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 35,
                      ),
                    )
                  ],
                ),
              ),
            if (widget.cardCount == 3)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(17, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.no_encryption_rounded,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Ineligible Students',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Spacer(),
                    Text(
                      widget.ineligibleStudents.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 35,
                      ),
                    )
                  ],
                ),
              ),
            if (widget.cardCount == 4)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(17, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Graduating Students',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Spacer(),
                    Text(
                      widget.graduatingStudents.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 35,
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
