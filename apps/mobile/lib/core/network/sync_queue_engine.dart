import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/app_database.dart';

class SyncQueueEngine {
  static final SyncQueueEngine instance = SyncQueueEngine._init();
  SyncQueueEngine._init();

  bool _isSyncing = false;

  /// Process all pending sync events stored locally in SQLite
  Future<void> processSyncQueue(String backendApiUrl, String jwtToken) async {
    if (_isSyncing) return;
    _isSyncing = true;

    final db = await AppDatabase.instance.database;

    try {
      final pendingEvents = await db.query(
        'sync_queue',
        where: 'status = ?',
        whereArgs: ['pending'],
        orderBy: 'created_at ASC',
      );

      if (pendingEvents.isEmpty) {
        _isSyncing = false;
        return;
      }

      final payloadList = pendingEvents.map((e) {
        return {
          'event_id': e['id'],
          'entity': e['entity_name'],
          'action': e['action_type'],
          'payload': jsonDecode(e['payload'] as String),
          'client_timestamp': e['created_at'],
        };
      }).toList();

      final response = await http.post(
        Uri.parse('$backendApiUrl/sync/push'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'events': payloadList}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        final List<dynamic> processedIds = resData['processed_event_ids'] ?? [];

        for (final id in processedIds) {
          await db.delete(
            'sync_queue',
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }
    } catch (e) {
      // Retain offline queue on connection loss; retried on next online trigger
    } finally {
      _isSyncing = false;
    }
  }
}
