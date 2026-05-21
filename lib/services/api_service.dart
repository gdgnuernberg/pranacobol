import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/breath_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:8080'});

  /// Fetch list of breathing methods from the server
  Future<List<BreathingMethod>> fetchMethods() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/methods'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BreathingMethod.fromJson(json)).toList();
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch methods: $e');
    }
  }

  /// Fetch current server status
  Future<ServerStatus> fetchStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/status'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ServerStatus.fromJson(data);
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch status: $e');
    }
  }

  /// Fetch history of breathing sessions
  /// Returns a Map with:
  /// - 'locked': bool
  /// - 'sessions': List<SessionRecord> (only if not locked)
  Future<Map<String, dynamic>> fetchSessions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/sessions'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final bool locked = data['locked'] as bool? ?? true;
        if (locked) {
          return {'locked': true, 'sessions': <SessionRecord>[]};
        } else {
          final List<dynamic> sessionList = data['sessions'] as List<dynamic>? ?? [];
          final sessions = sessionList
              .map((json) => SessionRecord.fromJson(json as Map<String, dynamic>))
              .toList();
          return {'locked': false, 'sessions': sessions};
        }
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch sessions: $e');
    }
  }

  /// Save a completed breathwork session to the server
  Future<bool> saveSession(String method, int duration, String notes) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'method': method,
          'duration': duration.toString(),
          'notes': notes,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }

  /// Toggle lock state. If locked, PIN is required. If unlocked, PIN is ignored.
  /// Returns a Map with 'success' (bool), and 'state' (String) or 'error' (String).
  Future<Map<String, dynamic>> toggleLock(String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/lock/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'pin': pin}),
      );
      
      final Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': data['success'] as bool? ?? false,
          'state': data['state'] as String? ?? '',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] as String? ?? 'Unauthorized',
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/sessions/reset'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'pin': pin}),
      );
      
      final Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': data['success'] as bool? ?? false,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] as String? ?? 'Unauthorized',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed: $e',
      };
    }
  }
}
