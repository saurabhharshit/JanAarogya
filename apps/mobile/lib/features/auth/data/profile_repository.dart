import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';

class UserProfile {
  final String id;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String villageName;
  final String districtName;
  final String preferredLanguage;
  final String emergencyContactPhone;
  final List<String> knownAllergies;
  final List<String> existingConditions;
  final bool isPregnant;
  final String? lmpDate;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.villageName,
    required this.districtName,
    required this.preferredLanguage,
    required this.emergencyContactPhone,
    required this.knownAllergies,
    required this.existingConditions,
    required this.isPregnant,
    this.lmpDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'village_name': villageName,
      'district_name': districtName,
      'preferred_language': preferredLanguage,
      'emergency_contact_phone': emergencyContactPhone,
      'known_allergies': jsonEncode(knownAllergies),
      'existing_conditions': jsonEncode(existingConditions),
      'is_pregnant': isPregnant ? 1 : 0,
      'lmp_date': lmpDate,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      fullName: map['full_name'],
      dateOfBirth: map['date_of_birth'],
      gender: map['gender'],
      villageName: map['village_name'],
      districtName: map['district_name'],
      preferredLanguage: map['preferred_language'] ?? 'hi',
      emergencyContactPhone: map['emergency_contact_phone'],
      knownAllergies: map['known_allergies'] != null
          ? List<String>.from(jsonDecode(map['known_allergies']))
          : [],
      existingConditions: map['existing_conditions'] != null
          ? List<String>.from(jsonDecode(map['existing_conditions']))
          : [],
      isPregnant: map['is_pregnant'] == 1,
      lmpDate: map['lmp_date'],
    );
  }
}

class ProfileRepository {
  Future<void> saveProfileLocally(UserProfile profile) async {
    final db = await AppDatabase.instance.database;

    await db.transaction((txn) async {
      await txn.insert(
        'profiles',
        profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Queue for background cloud sync
      await txn.insert('sync_queue', {
        'id': 'sync_${DateTime.now().millisecondsSinceEpoch}',
        'entity_name': 'profiles',
        'action_type': 'INSERT',
        'payload': jsonEncode(profile.toMap()),
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      });
    });
  }

  Future<UserProfile?> getActiveProfile({String? profileId}) async {
    final db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> results;

    if (profileId != null) {
      results = await db.query('profiles',
          where: 'id = ?', whereArgs: [profileId], limit: 1);
    } else {
      results = await db.query('profiles', limit: 1);
    }

    if (results.isNotEmpty) {
      return UserProfile.fromMap(results.first);
    }
    return null;
  }

  Future<List<UserProfile>> getAllProfiles() async {
    final db = await AppDatabase.instance.database;
    final results = await db.query('profiles', orderBy: 'full_name ASC');
    return results.map((m) => UserProfile.fromMap(m)).toList();
  }

  Future<void> deleteProfile(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }
}
