import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sysadmindb/app/models/en-19.dart';
import 'package:sysadmindb/app/models/student_user.dart';

class DefenseCard extends StatelessWidget {
  final EN19Form defense;
  final Color cardColor;

  DefenseCard({required this.defense, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      color: cardColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
                 Text(
              defense.program,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            
            
            Text(
              "${defense.firstName} ${defense.lastName}",
              style: const TextStyle(
                fontSize: 21,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              defense.idNumber,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    color: defense.defenseDate == 'No date set'
                        ? Color.fromARGB(179, 0, 0, 0)
                        : Colors.white,
                    size: 16),
                SizedBox(width: 5),
                Text(
                  defense.defenseDate,
                  style: TextStyle(
                      color: defense.defenseDate == 'No date set'
                          ? Color.fromARGB(179, 0, 0, 0)
                          : Colors.white),
                ),
                SizedBox(width: 10),
                Text(
                  "|",
                  style: TextStyle(
                      color: defense.defenseDate == 'No date set'
                          ? Color.fromARGB(179, 0, 0, 0)
                          : Colors.white),
                ),
                SizedBox(width: 10),
                Icon(Icons.access_time,
                    color: defense.defenseTime == 'No time set'
                        ? Color.fromARGB(179, 0, 0, 0)
                        : Colors.white,
                    size: 16),
                SizedBox(width: 5),
                Text(
                  defense.defenseTime,
                  style: TextStyle(
                      color: defense.defenseTime == 'No time set'
                          ? Color.fromARGB(179, 0, 0, 0)
                          : Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
