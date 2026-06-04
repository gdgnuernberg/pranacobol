import 'package:serverpod/serverpod.dart';

class MyRoute extends Route {
  @override
  Set<Method> get methods => {Method.get, Method.post, Method.options};

  @override
  Future<Result> handleCall(Session session, Request request) async {
    return Response.ok(body: Body.fromString('ok'));
  }
}

void main() {
  final route = MyRoute();
  print('MyRoute methods: ${route.methods}');
}
