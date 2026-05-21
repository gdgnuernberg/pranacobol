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

abstract class BreathingMethod implements _i1.SerializableModel {
  BreathingMethod._({
    required this.id,
    required this.name,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.holdOut,
    required this.desc,
  });

  factory BreathingMethod({
    required String id,
    required String name,
    required int inhale,
    required int hold,
    required int exhale,
    required int holdOut,
    required String desc,
  }) = _BreathingMethodImpl;

  factory BreathingMethod.fromJson(Map<String, dynamic> jsonSerialization) {
    return BreathingMethod(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      inhale: jsonSerialization['inhale'] as int,
      hold: jsonSerialization['hold'] as int,
      exhale: jsonSerialization['exhale'] as int,
      holdOut: jsonSerialization['holdOut'] as int,
      desc: jsonSerialization['desc'] as String,
    );
  }

  String id;

  String name;

  int inhale;

  int hold;

  int exhale;

  int holdOut;

  String desc;

  /// Returns a shallow copy of this [BreathingMethod]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BreathingMethod copyWith({
    String? id,
    String? name,
    int? inhale,
    int? hold,
    int? exhale,
    int? holdOut,
    String? desc,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BreathingMethod',
      'id': id,
      'name': name,
      'inhale': inhale,
      'hold': hold,
      'exhale': exhale,
      'holdOut': holdOut,
      'desc': desc,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _BreathingMethodImpl extends BreathingMethod {
  _BreathingMethodImpl({
    required String id,
    required String name,
    required int inhale,
    required int hold,
    required int exhale,
    required int holdOut,
    required String desc,
  }) : super._(
         id: id,
         name: name,
         inhale: inhale,
         hold: hold,
         exhale: exhale,
         holdOut: holdOut,
         desc: desc,
       );

  /// Returns a shallow copy of this [BreathingMethod]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BreathingMethod copyWith({
    String? id,
    String? name,
    int? inhale,
    int? hold,
    int? exhale,
    int? holdOut,
    String? desc,
  }) {
    return BreathingMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      inhale: inhale ?? this.inhale,
      hold: hold ?? this.hold,
      exhale: exhale ?? this.exhale,
      holdOut: holdOut ?? this.holdOut,
      desc: desc ?? this.desc,
    );
  }
}
