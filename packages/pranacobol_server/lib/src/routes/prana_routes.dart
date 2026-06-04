import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../../prana_database.dart';

Headers _headers(Map<String, String> map) {
  return Headers.fromMap(map.map((k, v) => MapEntry(k, [v])));
}

// Helper to find the dashboard.html file
File _getDashboardFile() {
  if (File('packages/pranacobol_server/dashboard.html').existsSync()) {
    return File('packages/pranacobol_server/dashboard.html');
  } else if (File('dashboard.html').existsSync()) {
    return File('dashboard.html');
  }
  return File('dashboard.html');
}

class RootRoute extends Route {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final file = _getDashboardFile();
    if (!file.existsSync()) {
      return Response.notFound(
        body: Body.fromString('dashboard.html not found'),
      );
    }
    final html = file.readAsStringSync();
    return Response.ok(
      body: Body.fromString(html, mimeType: MimeType.html),
    );
  }
}

class MethodsRoute extends Route {
  @override
  Set<Method> get methods => {Method.get, Method.options};

  @override
  Future<Result> handleCall(Session session, Request request) async {
    if (request.method == Method.options) {
      return Response.ok(
        body: Body.fromString(''),
        headers: _headers({
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        }),
      );
    }
    PranaDatabase.instance.incrementRequestCount();
    final methods = [
      {
        'id': 'box',
        'name': 'Box Breathing',
        'inhale': 4,
        'hold': 4,
        'exhale': 4,
        'holdOut': 4,
        'desc': 'Relieves stress, calms the nervous system.'
      },
      {
        'id': 'sleep',
        'name': '4-7-8 Method',
        'inhale': 4,
        'hold': 7,
        'exhale': 8,
        'holdOut': 0,
        'desc': 'Deep relaxation, helps with falling asleep.'
      },
      {
        'id': 'resonant',
        'name': 'Resonant Coherence',
        'inhale': 5,
        'hold': 0,
        'exhale': 5,
        'holdOut': 0,
        'desc': 'Balances autonomic nervous system.'
      },
      {
        'id': 'energy',
        'name': 'Energizing Breath',
        'inhale': 2,
        'hold': 0,
        'exhale': 2,
        'holdOut': 10,
        'desc': 'Rapid cycles followed by retention for energy.'
      },
      {
        'id': 'wimhof',
        'name': 'Wim Hof Method',
        'inhale': 2,
        'hold': 0,
        'exhale': 2,
        'holdOut': 60,
        'desc': 'Hyperventilation cycles followed by deep breath retention.'
      }
    ];
    return Response.ok(
      body: Body.fromString(jsonEncode(methods), mimeType: MimeType.json),
      headers: _headers({
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json',
      }),
    );
  }
}

class StatusRoute extends Route {
  @override
  Set<Method> get methods => {Method.get, Method.options};

  @override
  Future<Result> handleCall(Session session, Request request) async {
    if (request.method == Method.options) {
      return Response.ok(
        body: Body.fromString(''),
        headers: _headers({
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        }),
      );
    }
    final db = PranaDatabase.instance;
    db.incrementRequestCount();
    final lockData = db.getLockData();
    final now = DateTime.now();
    String pad(int val) => val.toString().padLeft(2, '0');
    final formattedTime =
        '${now.year}-${pad(now.month)}-${pad(now.day)} ${pad(now.hour)}:${pad(now.minute)}:${pad(now.second)}';

    final status = {
      'status': 'online',
      'uptime_seconds': db.uptimeSeconds.toString(),
      'request_count': db.requestCount,
      'lock_status': lockData.value,
      'system_time': formattedTime,
    };
    return Response.ok(
      body: Body.fromString(jsonEncode(status), mimeType: MimeType.json),
      headers: _headers({
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json',
      }),
    );
  }
}

class SessionsRoute extends Route {
  @override
  Set<Method> get methods => {Method.get, Method.post, Method.options};

  @override
  Future<Result> handleCall(Session session, Request request) async {
    print('SessionsRoute hit! Method: ${request.method}');
    final headers = _headers({
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Content-Type': 'application/json',
    });

    if (request.method == Method.options) {
      print('SessionsRoute: handling OPTIONS');
      return Response.ok(
        body: Body.fromString(''),
        headers: headers,
      );
    }

    final db = PranaDatabase.instance;
    db.incrementRequestCount();

    if (request.method == Method.get) {
      print('SessionsRoute: handling GET');
      final lockData = db.getLockData();
      if (lockData.value == 'LOCKED') {
        return Response.ok(
          body: Body.fromString(jsonEncode({'locked': true}),
              mimeType: MimeType.json),
          headers: headers,
        );
      } else {
        final list = db
            .getSessions()
            .map((s) => {
                  'time': s.time,
                  'method': s.method,
                  'duration': s.duration,
                  'notes': s.notes,
                })
            .toList();
        return Response.ok(
          body: Body.fromString(
              jsonEncode({'locked': false, 'sessions': list}),
              mimeType: MimeType.json),
          headers: headers,
        );
      }
    } else if (request.method == Method.post) {
      print('SessionsRoute: handling POST');
      try {
        final bodyStr = await request.readAsString();
        print('SessionsRoute: bodyStr = "$bodyStr"');
        final data = jsonDecode(bodyStr);
        final method = data['method'] as String? ?? '';
        final durationStr = data['duration'] as String? ?? '0';
        final duration = int.tryParse(durationStr) ?? 0;
        final notes = data['notes'] as String? ?? '';

        db.saveSession(method, duration, notes);
        print('SessionsRoute: saved session');

        return Response.ok(
          body: Body.fromString(jsonEncode({'success': true}),
              mimeType: MimeType.json),
          headers: headers,
        );
      } catch (e, stack) {
        print('SessionsRoute: error = $e');
        print('Stack trace: $stack');
        return Response.ok(
          body: Body.fromString(
              jsonEncode({'success': false, 'error': e.toString()}),
              mimeType: MimeType.json),
          headers: headers,
        );
      }
    }

    return Response.notFound(
      body: Body.fromString('Method not supported'),
      headers: headers,
    );
  }
}

class LockToggleRoute extends Route {
  @override
  Set<Method> get methods => {Method.post, Method.options};

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final headers = _headers({
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Content-Type': 'application/json',
    });

    if (request.method == Method.options) {
      return Response.ok(
        body: Body.fromString(''),
        headers: headers,
      );
    }

    if (request.method != Method.post) {
      return Response.notFound(
        body: Body.fromString('Method not supported'),
        headers: headers,
      );
    }

    final db = PranaDatabase.instance;
    db.incrementRequestCount();
    final lockData = db.getLockData();
    final currentState = lockData.value;
    final expectedPin = lockData.key;

    if (currentState == 'UNLOCKED') {
      db.setLockState('LOCKED');
      return Response.ok(
        body: Body.fromString(jsonEncode({'success': true, 'state': 'LOCKED'}),
            mimeType: MimeType.json),
        headers: headers,
      );
    } else {
      try {
        final bodyStr = await request.readAsString();
        final data = jsonDecode(bodyStr);
        final pin = data['pin'] as String? ?? '';

        if (pin == expectedPin) {
          db.setLockState('UNLOCKED');
          return Response.ok(
            body: Body.fromString(
                jsonEncode({'success': true, 'state': 'UNLOCKED'}),
                mimeType: MimeType.json),
            headers: headers,
          );
        } else {
          return Response(
            401,
            body: Body.fromString(
                jsonEncode({'success': false, 'error': 'Invalid PIN'}),
                mimeType: MimeType.json),
            headers: headers,
          );
        }
      } catch (e) {
        return Response(
          400,
          body: Body.fromString(
              jsonEncode({'success': false, 'error': e.toString()}),
              mimeType: MimeType.json),
          headers: headers,
        );
      }
    }
  }
}

class ResetSessionsRoute extends Route {
  @override
  Set<Method> get methods => {Method.post, Method.options};

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final headers = _headers({
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Content-Type': 'application/json',
    });

    if (request.method == Method.options) {
      return Response.ok(
        body: Body.fromString(''),
        headers: headers,
      );
    }

    if (request.method != Method.post) {
      return Response.notFound(
        body: Body.fromString('Method not supported'),
        headers: headers,
      );
    }

    final db = PranaDatabase.instance;
    db.incrementRequestCount();
    final lockData = db.getLockData();
    final expectedPin = lockData.key;

    try {
      final bodyStr = await request.readAsString();
      final data = jsonDecode(bodyStr);
      final pin = data['pin'] as String? ?? '';

      if (pin == expectedPin) {
        db.resetSessions();
        return Response.ok(
          body: Body.fromString(jsonEncode({'success': true}),
              mimeType: MimeType.json),
          headers: headers,
        );
      } else {
        return Response(
          401,
          body: Body.fromString(
              jsonEncode({'success': false, 'error': 'Invalid PIN'}),
              mimeType: MimeType.json),
          headers: headers,
        );
      }
    } catch (e) {
      return Response(
        400,
        body: Body.fromString(
            jsonEncode({'success': false, 'error': e.toString()}),
            mimeType: MimeType.json),
        headers: headers,
      );
    }
  }
}
