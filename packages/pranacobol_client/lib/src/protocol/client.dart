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
import 'dart:async' as _i2;
import 'package:pranacobol_client/src/protocol/lock_response.dart' as _i3;
import 'package:pranacobol_client/src/protocol/breathing_method.dart' as _i4;
import 'package:pranacobol_client/src/protocol/sessions_response.dart' as _i5;
import 'package:pranacobol_client/src/protocol/server_status.dart' as _i6;
import 'protocol.dart' as _i7;

/// {@category Endpoint}
class EndpointLock extends _i1.EndpointRef {
  EndpointLock(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'lock';

  _i2.Future<_i3.LockResponse> toggleLock(String? pin) =>
      caller.callServerEndpoint<_i3.LockResponse>(
        'lock',
        'toggleLock',
        {'pin': pin},
      );
}

/// {@category Endpoint}
class EndpointMethods extends _i1.EndpointRef {
  EndpointMethods(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'methods';

  _i2.Future<List<_i4.BreathingMethod>> getMethods() =>
      caller.callServerEndpoint<List<_i4.BreathingMethod>>(
        'methods',
        'getMethods',
        {},
      );
}

/// {@category Endpoint}
class EndpointSessions extends _i1.EndpointRef {
  EndpointSessions(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'sessions';

  _i2.Future<_i5.SessionsResponse> getSessions() =>
      caller.callServerEndpoint<_i5.SessionsResponse>(
        'sessions',
        'getSessions',
        {},
      );

  _i2.Future<bool> addSession(
    String method,
    int duration,
    String notes,
  ) => caller.callServerEndpoint<bool>(
    'sessions',
    'addSession',
    {
      'method': method,
      'duration': duration,
      'notes': notes,
    },
  );

  _i2.Future<bool> resetSessions(String pin) => caller.callServerEndpoint<bool>(
    'sessions',
    'resetSessions',
    {'pin': pin},
  );
}

/// {@category Endpoint}
class EndpointStatus extends _i1.EndpointRef {
  EndpointStatus(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'status';

  _i2.Future<_i6.ServerStatus> getStatus() =>
      caller.callServerEndpoint<_i6.ServerStatus>(
        'status',
        'getStatus',
        {},
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i7.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    lock = EndpointLock(this);
    methods = EndpointMethods(this);
    sessions = EndpointSessions(this);
    status = EndpointStatus(this);
  }

  late final EndpointLock lock;

  late final EndpointMethods methods;

  late final EndpointSessions sessions;

  late final EndpointStatus status;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'lock': lock,
    'methods': methods,
    'sessions': sessions,
    'status': status,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
