import 'dart:convert';
import '../../../core/database/app_database.dart';

class ConsultationRequest {
  final String id;
  final String patientNotes;
  final String status;
  final String createdAt;

  ConsultationRequest({
    required this.id,
    required this.patientNotes,
    required this.status,
    required this.createdAt,
  });
}

class ConsultationRepository {
  Future<void> submitRequest(String notes) async {
    final db = await AppDatabase.instance.database;

    final reqId = 'req_${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'id': reqId,
      'patient_notes': notes,
      'status': 'queued',
      'created_at': DateTime.now().toIso8601String(),
    };

    await db.insert('sync_queue', {
      'id': 'sync_consult_$reqId',
      'entity_name': 'consultation_requests',
      'action_type': 'INSERT',
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
  }
}
