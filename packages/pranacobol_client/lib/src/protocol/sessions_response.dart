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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'session_record.dart' as _i2;
import 'package:pranacobol_client/src/protocol/protocol.dart' as _i3;

abstract class SessionsResponse implements _i1.SerializableModel {
  SessionsResponse._({
    required this.locked,
    required this.sessions,
  });

  factory SessionsResponse({
    required bool locked,
    required List<_i2.SessionRecord> sessions,
  }) = _SessionsResponseImpl;

  factory SessionsResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return SessionsResponse(
      locked: _i1.BoolJsonExtension.fromJson(jsonSerialization['locked']),
      sessions: _i3.Protocol().deserialize<List<_i2.SessionRecord>>(
        jsonSerialization['sessions'],
      ),
    );
  }

  bool locked;

  List<_i2.SessionRecord> sessions;

  /// Returns a shallow copy of this [SessionsResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SessionsResponse copyWith({
    bool? locked,
    List<_i2.SessionRecord>? sessions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SessionsResponse',
      'locked': locked,
      'sessions': sessions.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SessionsResponseImpl extends SessionsResponse {
  _SessionsResponseImpl({
    required bool locked,
    required List<_i2.SessionRecord> sessions,
  }) : super._(
         locked: locked,
         sessions: sessions,
       );

  /// Returns a shallow copy of this [SessionsResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SessionsResponse copyWith({
    bool? locked,
    List<_i2.SessionRecord>? sessions,
  }) {
    return SessionsResponse(
      locked: locked ?? this.locked,
      sessions: sessions ?? this.sessions.map((e0) => e0.copyWith()).toList(),
    );
  }
}
