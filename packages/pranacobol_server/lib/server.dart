import 'package:serverpod/serverpod.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';
import 'src/routes/prana_routes.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod with custom ports configuration
  final config = ServerpodConfig(
    apiServer: ServerConfig(
      port: 8082,
      publicHost: 'localhost',
      publicPort: 8082,
      publicScheme: 'http',
    ),
    webServer: ServerConfig(
      port: 8080,
      publicHost: 'localhost',
      publicPort: 8080,
      publicScheme: 'http',
    ),
    insightsServer: ServerConfig(
      port: 8081,
      publicHost: 'localhost',
      publicPort: 8081,
      publicScheme: 'http',
    ),
  );

  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    config: config,
  );

  // Register Web REST routes for backwards compatibility
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(MethodsRoute(), '/api/methods');
  pod.webServer.addRoute(StatusRoute(), '/api/status');
  pod.webServer.addRoute(SessionsRoute(), '/api/sessions');
  pod.webServer.addRoute(LockToggleRoute(), '/api/lock/toggle');
  pod.webServer.addRoute(ResetSessionsRoute(), '/api/sessions/reset');

  // Start the server.
  await pod.start();
}

