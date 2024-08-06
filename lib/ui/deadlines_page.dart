import 'package:flutter/material.dart';
import 'package:sysadmindb/app/models/deadline.dart';
import 'package:intl/intl.dart'; // Import intl package

class Deadlines extends StatefulWidget {
  const Deadlines({super.key});

  @override
  State<Deadlines> createState() => _DeadlinesState();
}

class _DeadlinesState extends State<Deadlines> {
  @override
  Widget build(BuildContext context) {
    // Group deadlines by category
    final Map<String, List<Deadline>> categorizedDeadlines = {};
    for (var deadline in deadlines) {
      categorizedDeadlines
          .putIfAbsent(deadline.category, () => [])
          .add(deadline);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deadlines'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: categorizedDeadlines.keys.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    category,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  children: categorizedDeadlines[category]!.map((deadline) {
                    return _buildDeadlineCard(deadline);
                  }).toList(),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDeadlineCard(Deadline deadline) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deadline.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      _pickDateTime(context, deadline);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor:  Color.fromARGB(255, 12, 80, 4),
                    ),
                    child: Text(
                      'Deadline: ${_formatDate(deadline.deadlineDate)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Switch(
                  value: deadline.isEnabled,
                  onChanged: (value) {
                    setState(() {
                      deadline.isEnabled = value;
                      deadline.saveToFirestore(deadline.id, deadline);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to format date
  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not set';
    }
    return DateFormat('MMMM d, yyyy h:mm a').format(date);
  }

  Future<void> _pickDateTime(BuildContext context, Deadline deadline) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: deadline.deadlineDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(deadline.deadlineDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          deadline.deadlineDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          deadline.saveToFirestore(deadline.id, deadline);
        });
      }
    }
  }
}
