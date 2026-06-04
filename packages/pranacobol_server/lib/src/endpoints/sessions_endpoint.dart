import 'package:serverpod/serverpod.dart';
import '../../prana_database.dart';
import '../generated/protocol.dart';

class SessionsEndpoint extends Endpoint {
  Future<SessionsResponse> getSessions(Session session) async {
    final db = PranaDatabase.instance;
    db.incrementRequestCount();
    final lockData = db.getLockData();
    if (lockData.value == 'LOCKED') {
      return SessionsResponse(locked: true, sessions: []);
    } else {
      return SessionsResponse(locked: false, sessions: db.getSessions());
    }
  }

  Future<bool> addSession(Session session, String method, int duration, String notes) async {
    final db = PranaDatabase.instance;
    db.incrementRequestCount();
    db.saveSession(method, duration, notes);
    return true;
  }

  Future<bool> resetSessions(Session session, String pin) async {
    final db = PranaDatabase.instance;
    db.incrementRequestCount();
    final lockData = db.getLockData();
    if (pin == lockData.key) {
      db.resetSessions();
      return true;
    }
    return false;
  }
}
