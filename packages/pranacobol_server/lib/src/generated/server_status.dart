/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class ServerStatus
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ServerStatus._({
    required this.status,
    required this.uptimeSeconds,
    required this.requestCount,
    required this.lockStatus,
    required this.systemTime,
  });

  factory ServerStatus({
    required String status,
    required int uptimeSeconds,
    required int requestCount,
    required String lockStatus,
    required String systemTime,
  }) = _ServerStatusImpl;

  factory ServerStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return ServerStatus(
      status: jsonSerialization['status'] as String,
      uptimeSeconds: jsonSerialization['uptimeSeconds'] as int,
      requestCount: jsonSerialization['requestCount'] as int,
      lockStatus: jsonSerialization['lockStatus'] as String,
      systemTime: jsonSerialization['systemTime'] as String,
    );
  }

  String status;

  int uptimeSeconds;

  int requestCount;

  String lockStatus;

  String systemTime;

  /// Returns a shallow copy of this [ServerStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ServerStatus copyWith({
    String? status,
    int? uptimeSeconds,
    int? requestCount,
    String? lockStatus,
    String? systemTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ServerStatus',
      'status': status,
      'uptimeSeconds': uptimeSeconds,
      'requestCount': requestCount,
      'lockStatus': lockStatus,
      'systemTime': systemTime,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ServerStatus',
      'status': status,
      'uptimeSeconds': uptimeSeconds,
      'requestCount': requestCount,
      'lockStatus': lockStatus,
      'systemTime': systemTime,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ServerStatusImpl extends ServerStatus {
  _ServerStatusImpl({
    required String status,
    required int uptimeSeconds,
    required int requestCount,
    required String lockStatus,
    required String systemTime,
  }) : super._(
         status: status,
         uptimeSeconds: uptimeSeconds,
         requestCount: requestCount,
         lockStatus: lockStatus,
         systemTime: systemTime,
       );

  /// Returns a shallow copy of this [ServerStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ServerStatus copyWith({
    String? status,
    int? uptimeSeconds,
    int? requestCount,
    String? lockStatus,
    String? systemTime,
  }) {
    return ServerStatus(
      status: status ?? this.status,
      uptimeSeconds: uptimeSeconds ?? this.uptimeSeconds,
      requestCount: requestCount ?? this.requestCount,
      lockStatus: lockStatus ?? this.lockStatus,
      systemTime: systemTime ?? this.systemTime,
    );
  }
}
