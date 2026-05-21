import 'package:serverpod/serverpod.dart';
import '../../prana_database.dart';
import '../generated/protocol.dart';

class LockEndpoint extends Endpoint {
  Future<LockResponse> toggleLock(Session session, String? pin) async {
    final db = PranaDatabase.instance;
    db.incrementRequestCount();
    final lockData = db.getLockData();
    final currentState = lockData.value;
    final expectedPin = lockData.key;

    if (currentState == 'UNLOCKED') {
      db.setLockState('LOCKED');
      return LockResponse(success: true, state: 'LOCKED');
    } else {
      if (pin == expectedPin) {
        db.setLockState('UNLOCKED');
        return LockResponse(success: true, state: 'UNLOCKED');
      } else {
        return LockResponse(success: false, state: 'LOCKED', error: 'Invalid PIN');
      }
    }
  }
}
