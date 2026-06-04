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
import 'package:serverpod/protocol.dart' as _i2;
import 'breathing_method.dart' as _i3;
import 'lock_response.dart' as _i4;
import 'server_status.dart' as _i5;
import 'session_record.dart' as _i6;
import 'sessions_response.dart' as _i7;
import 'package:pranacobol_server/src/generated/breathing_method.dart' as _i8;
export 'breathing_method.dart';
export 'lock_response.dart';
export 'server_status.dart';
export 'session_record.dart';
export 'sessions_response.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    ..._i2.Protocol.targetTableDefinitions,
  ];

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

    if (t == _i3.BreathingMethod) {
      return _i3.BreathingMethod.fromJson(data) as T;
    }
    if (t == _i4.LockResponse) {
      return _i4.LockResponse.fromJson(data) as T;
    }
    if (t == _i5.ServerStatus) {
      return _i5.ServerStatus.fromJson(data) as T;
    }
    if (t == _i6.SessionRecord) {
      return _i6.SessionRecord.fromJson(data) as T;
    }
    if (t == _i7.SessionsResponse) {
      return _i7.SessionsResponse.fromJson(data) as T;
    }
    if (t == _i1.getType<_i3.BreathingMethod?>()) {
      return (data != null ? _i3.BreathingMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.LockResponse?>()) {
      return (data != null ? _i4.LockResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ServerStatus?>()) {
      return (data != null ? _i5.ServerStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.SessionRecord?>()) {
      return (data != null ? _i6.SessionRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.SessionsResponse?>()) {
      return (data != null ? _i7.SessionsResponse.fromJson(data) : null) as T;
    }
    if (t == List<_i6.SessionRecord>) {
      return (data as List)
              .map((e) => deserialize<_i6.SessionRecord>(e))
              .toList()
          as T;
    }
    if (t == List<_i8.BreathingMethod>) {
      return (data as List)
              .map((e) => deserialize<_i8.BreathingMethod>(e))
              .toList()
          as T;
    }
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i3.BreathingMethod => 'BreathingMethod',
      _i4.LockResponse => 'LockResponse',
      _i5.ServerStatus => 'ServerStatus',
      _i6.SessionRecord => 'SessionRecord',
      _i7.SessionsResponse => 'SessionsResponse',
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
      case _i3.BreathingMethod():
        return 'BreathingMethod';
      case _i4.LockResponse():
        return 'LockResponse';
      case _i5.ServerStatus():
        return 'ServerStatus';
      case _i6.SessionRecord():
        return 'SessionRecord';
      case _i7.SessionsResponse():
        return 'SessionsResponse';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
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
      return deserialize<_i3.BreathingMethod>(data['data']);
    }
    if (dataClassName == 'LockResponse') {
      return deserialize<_i4.LockResponse>(data['data']);
    }
    if (dataClassName == 'ServerStatus') {
      return deserialize<_i5.ServerStatus>(data['data']);
    }
    if (dataClassName == 'SessionRecord') {
      return deserialize<_i6.SessionRecord>(data['data']);
    }
    if (dataClassName == 'SessionsResponse') {
      return deserialize<_i7.SessionsResponse>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'pranacobol';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i2.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
