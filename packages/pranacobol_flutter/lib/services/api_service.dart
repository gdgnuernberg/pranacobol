import 'package:pranacobol_client/pranacobol_client.dart' as pc;
import 'package:serverpod_flutter/serverpod_flutter.dart';
import '../models/breath_model.dart';

class ApiService {
  final pc.Client client;

  ApiService({String baseUrl = 'http://localhost:8080'})
      : client = pc.Client(
          baseUrl.replaceAll(':8080', ':8082').replaceAll(':8082/', ':8082') +
              (baseUrl.endsWith('/') ? '' : '/'),
        )..connectivityMonitor = FlutterConnectivityMonitor();

  /// Fetch list of breathing methods from the server
  Future<List<BreathingMethod>> fetchMethods() async {
    try {
      final list = await client.methods.getMethods();
      return list
          .map((m) => BreathingMethod(
                id: m.id,
                name: m.name,
                inhale: m.inhale,
                hold: m.hold,
                exhale: m.exhale,
                holdOut: m.holdOut,
                desc: m.desc,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch methods: $e');
    }
  }

  /// Fetch current server status
  Future<ServerStatus> fetchStatus() async {
    try {
      final s = await client.status.getStatus();
      return ServerStatus(
        status: s.status,
        uptimeSeconds: s.uptimeSeconds,
        requestCount: s.requestCount,
        lockStatus: s.lockStatus,
        systemTime: s.systemTime,
      );
    } catch (e) {
      throw Exception('Failed to fetch status: $e');
    }
  }

  /// Fetch history of breathing sessions
  /// Returns a Map with:
  /// - 'locked': bool
  /// - 'sessions': `List<SessionRecord>` (only if not locked)
  Future<Map<String, dynamic>> fetchSessions() async {
    try {
      final resp = await client.sessions.getSessions();
      if (resp.locked) {
        return {'locked': true, 'sessions': <SessionRecord>[]};
      } else {
        final List<SessionRecord> sessions = resp.sessions
            .map((s) => SessionRecord(
                  time: s.time,
                  method: s.method,
                  duration: s.duration,
                  notes: s.notes,
                ))
            .toList();
        return {'locked': false, 'sessions': sessions};
      }
    } catch (e) {
      throw Exception('Failed to fetch sessions: $e');
    }
  }

  /// Save a completed breathwork session to the server
  Future<bool> saveSession(String method, int duration, String notes) async {
    try {
      return await client.sessions.addSession(method, duration, notes);
    } catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }

  /// Toggle lock state. If locked, PIN is required. If unlocked, PIN is ignored.
  /// Returns a Map with 'success' (bool), and 'state' (String) or 'error' (String).
  Future<Map<String, dynamic>> toggleLock(String pin) async {
    try {
      final resp = await client.lock.toggleLock(pin.isEmpty ? null : pin);
      if (resp.success) {
        return {
          'success': true,
          'state': resp.state,
        };
      } else {
        return {
          'success': false,
          'error': resp.error ?? 'Unauthorized',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed: $e',
      };
    }
  }

  /// Reset all session records (requires PIN)
  /// Returns a Map with 'success' (bool) and 'error' (String, optional).
  Future<Map<String, dynamic>> resetSessions(String pin) async {
    try {
      final success = await client.sessions.resetSessions(pin);
      return {
        'success': success,
        if (!success) 'error': 'Invalid PIN',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed: $e',
      };
    }
  }
}

