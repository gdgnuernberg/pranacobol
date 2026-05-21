import 'dart:io';
import 'src/generated/session_record.dart';

class PranaDatabase {
  static final PranaDatabase instance = PranaDatabase._internal();

  PranaDatabase._internal();

  final DateTime startupTime = DateTime.now();
  int _requestCount = 0;
  final _lock = Object();

  // Helper to find database files relative to the project root
  File _getFile(String name) {
    if (File('melos.yaml').existsSync()) {
      return File(name);
    } else if (File('../../melos.yaml').existsSync()) {
      return File('../../$name');
    }
    return File(name);
  }

  File get _lockFile => _getFile('lock.dat');
  File get _sessionsFile => _getFile('sessions.dat');

  void incrementRequestCount() {
    synchronized(() {
      _requestCount++;
    });
  }

  int get requestCount {
    int count = 0;
    synchronized(() {
      count = _requestCount;
    });
    return count;
  }

  int get uptimeSeconds {
    return DateTime.now().difference(startupTime).inSeconds;
  }

  // Lock logic
  // Returns Map entry of (PIN, State)
  MapEntry<String, String> getLockData() {
    return synchronized(() {
      final file = _lockFile;
      if (!file.existsSync()) {
        _writeLockData('1234', 'LOCKED');
        return const MapEntry('1234', 'LOCKED');
      }
      try {
        final line = file.readAsLinesSync().first;
        final parts = line.split('|');
        if (parts.length >= 2) {
          final pin = parts[0].trim();
          final state = parts[1].trim();
          return MapEntry(pin, state);
        }
      } catch (_) {}
      // Fallback
      _writeLockData('1234', 'LOCKED');
      return const MapEntry('1234', 'LOCKED');
    });
  }

  void _writeLockData(String pin, String state) {
    // Pad PIN to 4 characters, state to 8 characters matching COBOL:
    // LOCK-PIN PIC X(4) -> pin
    // LOCK-DELIM PIC X -> '|'
    // LOCK-STATE PIC X(8) -> state
    final paddedPin = pin.padRight(4).substring(0, 4);
    final paddedState = state.padRight(8).substring(0, 8);
    final record = '$paddedPin|$paddedState';
    _lockFile.writeAsStringSync('$record\n');
  }

  void setLockState(String state) {
    synchronized(() {
      final current = getLockData();
      _writeLockData(current.key, state);
    });
  }

  // Sessions logic
  List<SessionRecord> getSessions() {
    return synchronized(() {
      final file = _sessionsFile;
      if (!file.existsSync()) {
        return [];
      }
      final List<SessionRecord> records = [];
      try {
        final lines = file.readAsLinesSync();
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          final parts = line.split('|');
          if (parts.length >= 4) {
            final time = parts[0].trim();
            final method = parts[1].trim();
            final duration = int.tryParse(parts[2].trim()) ?? 0;
            final notes = parts[3].trim();
            records.add(SessionRecord(
              time: time,
              method: method,
              duration: duration,
              notes: notes,
            ));
          }
        }
      } catch (_) {}
      return records;
    });
  }

  void saveSession(String method, int duration, String notes) {
    synchronized(() {
      // Format time as YYYY-MM-DD HH:MM:SS
      final now = DateTime.now();
      String pad(int val) => val.toString().padLeft(2, '0');
      final formattedTime = '${now.year}-${pad(now.month)}-${pad(now.day)} ${pad(now.hour)}:${pad(now.minute)}:${pad(now.second)}';

      // SESS-TIME PIC X(19) -> 19 chars
      // SESS-METHOD PIC X(30) -> 30 chars
      // SESS-DURATION PIC X(6) -> 6 chars
      // SESS-NOTES PIC X(50) -> 50 chars
      final timePart = formattedTime.padRight(19).substring(0, 19);
      final methodPart = method.padRight(30).substring(0, 30);
      final durationPart = duration.toString().padRight(6).substring(0, 6);
      final notesPart = notes.padRight(50).substring(0, 50);

      final record = '$timePart|$methodPart|$durationPart|$notesPart';
      _sessionsFile.writeAsStringSync('$record\n', mode: FileMode.append);
    });
  }

  void resetSessions() {
    synchronized(() {
      _sessionsFile.writeAsStringSync('');
    });
  }

  T synchronized<T>(T Function() action) {
    lock(_lock);
    try {
      return action();
    } finally {
      // release lock
    }
  }

  // Simple spin lock helper
  void lock(Object obj) {
    // Dart is single-threaded, so this lock is mostly for future async boundary safety.
    // Sync operations are safe.
  }
}
