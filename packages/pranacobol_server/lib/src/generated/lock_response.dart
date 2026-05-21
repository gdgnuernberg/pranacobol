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

abstract class LockResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  LockResponse._({
    required this.success,
    required this.state,
    this.error,
  });

  factory LockResponse({
    required bool success,
    required String state,
    String? error,
  }) = _LockResponseImpl;

  factory LockResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return LockResponse(
      success: _i1.BoolJsonExtension.fromJson(jsonSerialization['success']),
      state: jsonSerialization['state'] as String,
      error: jsonSerialization['error'] as String?,
    );
  }

  bool success;

  String state;

  String? error;

  /// Returns a shallow copy of this [LockResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  LockResponse copyWith({
    bool? success,
    String? state,
    String? error,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LockResponse',
      'success': success,
      'state': state,
      if (error != null) 'error': error,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LockResponse',
      'success': success,
      'state': state,
      if (error != null) 'error': error,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LockResponseImpl extends LockResponse {
  _LockResponseImpl({
    required bool success,
    required String state,
    String? error,
  }) : super._(
         success: success,
         state: state,
         error: error,
       );

  /// Returns a shallow copy of this [LockResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  LockResponse copyWith({
    bool? success,
    String? state,
    Object? error = _Undefined,
  }) {
    return LockResponse(
      success: success ?? this.success,
      state: state ?? this.state,
      error: error is String? ? error : this.error,
    );
  }
}
