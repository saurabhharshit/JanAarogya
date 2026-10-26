import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';

class MedicineReminder {
  final String id;
  final String medicineName;
  final String dosageInstruction;
  final int frequencyPerDay;
  final List<String> reminderTimes; // e.g. ["08:00", "20:00"]
  final String startDate;
  final bool isActive;

  MedicineReminder({
    required this.id,
    required this.medicineName,
    required this.dosageInstruction,
    required this.frequencyPerDay,
    required this.reminderTimes,
    required this.startDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicine_name': medicineName,
      'dosage_instruction': dosageInstruction,
      'frequency_per_day': frequencyPerDay,
      'reminder_times': jsonEncode(reminderTimes),
      'start_date': startDate,
      'is_active': isActive ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory MedicineReminder.fromMap(Map<String, dynamic> map) {
    return MedicineReminder(
      id: map['id'],
      medicineName: map['medicine_name'],
      dosageInstruction: map['dosage_instruction'],
      frequencyPerDay: map['frequency_per_day'],
      reminderTimes: List<String>.from(jsonDecode(map['reminder_times'])),
      startDate: map['start_date'],
      isActive: map['is_active'] == 1,
    );
  }
}

class MedicineRepository {
  Future<void> addMedicineReminder(MedicineReminder reminder) async {
    final db = await AppDatabase.instance.database;

    await db.transaction((txn) async {
      await txn.insert(
        'medicine_reminders',
        reminder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert('sync_queue', {
        'id': 'sync_med_${DateTime.now().millisecondsSinceEpoch}',
        'entity_name': 'medicine_reminders',
        'action_type': 'INSERT',
        'payload': jsonEncode(reminder.toMap()),
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      });
    });
  }

  Future<void> deleteMedicineReminder(String id) async {
    final db = await AppDatabase.instance.database;

    await db.transaction((txn) async {
      await txn.delete(
        'medicine_reminders',
        where: 'id = ?',
        whereArgs: [id],
      );

      await txn.insert('sync_queue', {
        'id': 'sync_del_med_${DateTime.now().millisecondsSinceEpoch}',
        'entity_name': 'medicine_reminders',
        'action_type': 'DELETE',
        'payload': jsonEncode({'id': id}),
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      });
    });
  }

  Future<List<MedicineReminder>> getActiveReminders() async {
    final db = await AppDatabase.instance.database;
    final results = await db.query(
      'medicine_reminders',
      where: 'is_active = 1',
    );
    return results.map((m) => MedicineReminder.fromMap(m)).toList();
  }
}
