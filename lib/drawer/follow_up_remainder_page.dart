import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/reminder.dart';  // New model

class Follow_up_remainder extends StatefulWidget {
  const Follow_up_remainder({super.key});

  @override
  State<Follow_up_remainder> createState() => _Follow_up_remainderState();
}

class _Follow_up_remainderState extends State<Follow_up_remainder> {
  List<Reminder> reminders = [];
  List<Reminder> pendingReminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('reminders');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      setState(() {
        reminders = decoded.map((e) => Reminder.fromJson(e)).toList();
        pendingReminders = reminders.where((r) => r.date.isAfter(DateTime.now()) && r.date.day == DateTime.now().day).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Pending Follow-ups",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("${pendingReminders.length} follow-ups today"),
            Expanded(
              child: ListView.builder(
                itemCount: pendingReminders.length,
                itemBuilder: (context, index) {
                  final reminder = pendingReminders[index];
                  return Card(
                    child: ListTile(
                      title: Text(reminder.title),
                      subtitle: Text(reminder.description),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "All Follow-up Reminders",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return Card(
                    child: ListTile(
                      title: Text(reminder.title),
                      subtitle: Text("${reminder.description} - ${reminder.date}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}