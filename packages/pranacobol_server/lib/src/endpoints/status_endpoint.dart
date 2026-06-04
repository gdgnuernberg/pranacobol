import 'package:serverpod/serverpod.dart';
import '../../prana_database.dart';
import '../generated/protocol.dart';

class StatusEndpoint extends Endpoint {
  Future<ServerStatus> getStatus(Session session) async {
    final db = PranaDatabase.instance;
    db.incrementRequestCount();
    final lockData = db.getLockData();

    final now = DateTime.now();
    String pad(int val) => val.toString().padLeft(2, '0');
    final formattedTime = '${now.year}-${pad(now.month)}-${pad(now.day)} ${pad(now.hour)}:${pad(now.minute)}:${pad(now.second)}';

    return ServerStatus(
      status: 'online',
      uptimeSeconds: db.uptimeSeconds,
      requestCount: db.requestCount,
      lockStatus: lockData.value,
      systemTime: formattedTime,
    );
  }
}
