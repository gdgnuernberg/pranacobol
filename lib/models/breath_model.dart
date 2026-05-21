class BreathingMethod {
  final String id;
  final String name;
  final int inhale;
  final int hold;
  final int exhale;
  final int holdOut;
  final String desc;

  BreathingMethod({
    required this.id,
    required this.name,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.holdOut,
    required this.desc,
  });

  factory BreathingMethod.fromJson(Map<String, dynamic> json) {
    return BreathingMethod(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      inhale: _toInt(json['inhale']),
      hold: _toInt(json['hold']),
      exhale: _toInt(json['exhale']),
      holdOut: _toInt(json['holdOut']),
      desc: json['desc'] as String? ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class ServerStatus {
  final String status;
  final int uptimeSeconds;
  final int requestCount;
  final String lockStatus;
  final String systemTime;

  ServerStatus({
    required this.status,
    required this.uptimeSeconds,
    required this.requestCount,
    required this.lockStatus,
    required this.systemTime,
  });

  bool get isLocked => lockStatus.trim().toUpperCase() == 'LOCKED';

  factory ServerStatus.fromJson(Map<String, dynamic> json) {
    return ServerStatus(
      status: json['status'] as String? ?? 'offline',
      uptimeSeconds: _toInt(json['uptime_seconds']),
      requestCount: _toInt(json['request_count']),
      lockStatus: json['lock_status'] as String? ?? 'LOCKED',
      systemTime: json['system_time'] as String? ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class SessionRecord {
  final String time;
  final String method;
  final int duration;
  final String notes;

  SessionRecord({
    required this.time,
    required this.method,
    required this.duration,
    required this.notes,
  });

  factory SessionRecord.fromJson(Map<String, dynamic> json) {
    return SessionRecord(
      time: json['time'] as String? ?? '',
      method: json['method'] as String? ?? '',
      duration: _toInt(json['duration']),
      notes: json['notes'] as String? ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
