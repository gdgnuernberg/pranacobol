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

abstract class SessionRecord
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SessionRecord._({
    required this.time,
    required this.method,
    required this.duration,
    required this.notes,
  });

  factory SessionRecord({
    required String time,
    required String method,
    required int duration,
    required String notes,
  }) = _SessionRecordImpl;

  factory SessionRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return SessionRecord(
      time: jsonSerialization['time'] as String,
      method: jsonSerialization['method'] as String,
      duration: jsonSerialization['duration'] as int,
      notes: jsonSerialization['notes'] as String,
    );
  }

  String time;

  String method;

  int duration;

  String notes;

  /// Returns a shallow copy of this [SessionRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SessionRecord copyWith({
    String? time,
    String? method,
    int? duration,
    String? notes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SessionRecord',
      'time': time,
      'method': method,
      'duration': duration,
      'notes': notes,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SessionRecord',
      'time': time,
      'method': method,
      'duration': duration,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SessionRecordImpl extends SessionRecord {
  _SessionRecordImpl({
    required String time,
    required String method,
    required int duration,
    required String notes,
  }) : super._(
         time: time,
         method: method,
         duration: duration,
         notes: notes,
       );

  /// Returns a shallow copy of this [SessionRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SessionRecord copyWith({
    String? time,
    String? method,
    int? duration,
    String? notes,
  }) {
    return SessionRecord(
      time: time ?? this.time,
      method: method ?? this.method,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
    );
  }
}
