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
import 'breathing_method.dart' as _i2;
import 'lock_response.dart' as _i3;
import 'server_status.dart' as _i4;
import 'session_record.dart' as _i5;
import 'sessions_response.dart' as _i6;
import 'package:pranacobol_client/src/protocol/breathing_method.dart' as _i7;
export 'breathing_method.dart';
export 'lock_response.dart';
export 'server_status.dart';
export 'session_record.dart';
export 'sessions_response.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.BreathingMethod) {
      return _i2.BreathingMethod.fromJson(data) as T;
    }
    if (t == _i3.LockResponse) {
      return _i3.LockResponse.fromJson(data) as T;
    }
    if (t == _i4.ServerStatus) {
      return _i4.ServerStatus.fromJson(data) as T;
    }
    if (t == _i5.SessionRecord) {
      return _i5.SessionRecord.fromJson(data) as T;
    }
    if (t == _i6.SessionsResponse) {
      return _i6.SessionsResponse.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.BreathingMethod?>()) {
      return (data != null ? _i2.BreathingMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.LockResponse?>()) {
      return (data != null ? _i3.LockResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ServerStatus?>()) {
      return (data != null ? _i4.ServerStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.SessionRecord?>()) {
      return (data != null ? _i5.SessionRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.SessionsResponse?>()) {
      return (data != null ? _i6.SessionsResponse.fromJson(data) : null) as T;
    }
    if (t == List<_i5.SessionRecord>) {
      return (data as List)
              .map((e) => deserialize<_i5.SessionRecord>(e))
              .toList()
          as T;
    }
    if (t == List<_i7.BreathingMethod>) {
      return (data as List)
              .map((e) => deserialize<_i7.BreathingMethod>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.BreathingMethod => 'BreathingMethod',
      _i3.LockResponse => 'LockResponse',
      _i4.ServerStatus => 'ServerStatus',
      _i5.SessionRecord => 'SessionRecord',
      _i6.SessionsResponse => 'SessionsResponse',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('pranacobol.', '');
    }

    switch (data) {
      case _i2.BreathingMethod():
        return 'BreathingMethod';
      case _i3.LockResponse():
        return 'LockResponse';
      case _i4.ServerStatus():
        return 'ServerStatus';
      case _i5.SessionRecord():
        return 'SessionRecord';
      case _i6.SessionsResponse():
        return 'SessionsResponse';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'BreathingMethod') {
      return deserialize<_i2.BreathingMethod>(data['data']);
    }
    if (dataClassName == 'LockResponse') {
      return deserialize<_i3.LockResponse>(data['data']);
    }
    if (dataClassName == 'ServerStatus') {
      return deserialize<_i4.ServerStatus>(data['data']);
    }
    if (dataClassName == 'SessionRecord') {
      return deserialize<_i5.SessionRecord>(data['data']);
    }
    if (dataClassName == 'SessionsResponse') {
      return deserialize<_i6.SessionsResponse>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
