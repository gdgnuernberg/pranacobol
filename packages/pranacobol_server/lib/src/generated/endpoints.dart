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
import '../endpoints/lock_endpoint.dart' as _i2;
import '../endpoints/methods_endpoint.dart' as _i3;
import '../endpoints/sessions_endpoint.dart' as _i4;
import '../endpoints/status_endpoint.dart' as _i5;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'lock': _i2.LockEndpoint()
        ..initialize(
          server,
          'lock',
          null,
        ),
      'methods': _i3.MethodsEndpoint()
        ..initialize(
          server,
          'methods',
          null,
        ),
      'sessions': _i4.SessionsEndpoint()
        ..initialize(
          server,
          'sessions',
          null,
        ),
      'status': _i5.StatusEndpoint()
        ..initialize(
          server,
          'status',
          null,
        ),
    };
    connectors['lock'] = _i1.EndpointConnector(
      name: 'lock',
      endpoint: endpoints['lock']!,
      methodConnectors: {
        'toggleLock': _i1.MethodConnector(
          name: 'toggleLock',
          params: {
            'pin': _i1.ParameterDescription(
              name: 'pin',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lock'] as _i2.LockEndpoint).toggleLock(
                session,
                params['pin'],
              ),
        ),
      },
    );
    connectors['methods'] = _i1.EndpointConnector(
      name: 'methods',
      endpoint: endpoints['methods']!,
      methodConnectors: {
        'getMethods': _i1.MethodConnector(
          name: 'getMethods',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['methods'] as _i3.MethodsEndpoint)
                  .getMethods(session),
        ),
      },
    );
    connectors['sessions'] = _i1.EndpointConnector(
      name: 'sessions',
      endpoint: endpoints['sessions']!,
      methodConnectors: {
        'getSessions': _i1.MethodConnector(
          name: 'getSessions',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sessions'] as _i4.SessionsEndpoint)
                  .getSessions(session),
        ),
        'addSession': _i1.MethodConnector(
          name: 'addSession',
          params: {
            'method': _i1.ParameterDescription(
              name: 'method',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'duration': _i1.ParameterDescription(
              name: 'duration',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'notes': _i1.ParameterDescription(
              name: 'notes',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sessions'] as _i4.SessionsEndpoint).addSession(
                    session,
                    params['method'],
                    params['duration'],
                    params['notes'],
                  ),
        ),
        'resetSessions': _i1.MethodConnector(
          name: 'resetSessions',
          params: {
            'pin': _i1.ParameterDescription(
              name: 'pin',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sessions'] as _i4.SessionsEndpoint).resetSessions(
                    session,
                    params['pin'],
                  ),
        ),
      },
    );
    connectors['status'] = _i1.EndpointConnector(
      name: 'status',
      endpoint: endpoints['status']!,
      methodConnectors: {
        'getStatus': _i1.MethodConnector(
          name: 'getStatus',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['status'] as _i5.StatusEndpoint).getStatus(
                session,
              ),
        ),
      },
    );
  }
}
