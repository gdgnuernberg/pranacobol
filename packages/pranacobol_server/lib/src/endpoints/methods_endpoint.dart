import 'package:serverpod/serverpod.dart';
import '../../prana_database.dart';
import '../generated/protocol.dart';

class MethodsEndpoint extends Endpoint {
  Future<List<BreathingMethod>> getMethods(Session session) async {
    PranaDatabase.instance.incrementRequestCount();
    return [
      BreathingMethod(
        id: 'box',
        name: 'Box Breathing',
        inhale: 4,
        hold: 4,
        exhale: 4,
        holdOut: 4,
        desc: 'Relieves stress, calms the nervous system.',
      ),
      BreathingMethod(
        id: 'sleep',
        name: '4-7-8 Method',
        inhale: 4,
        hold: 7,
        exhale: 8,
        holdOut: 0,
        desc: 'Deep relaxation, helps with falling asleep.',
      ),
      BreathingMethod(
        id: 'resonant',
        name: 'Resonant Coherence',
        inhale: 5,
        hold: 0,
        exhale: 5,
        holdOut: 0,
        desc: 'Balances autonomic nervous system.',
      ),
      BreathingMethod(
        id: 'energy',
        name: 'Energizing Breath',
        inhale: 2,
        hold: 0,
        exhale: 2,
        holdOut: 10,
        desc: 'Rapid cycles followed by retention for energy.',
      ),
      BreathingMethod(
        id: 'wimhof',
        name: 'Wim Hof Method',
        inhale: 2,
        hold: 0,
        exhale: 2,
        holdOut: 60,
        desc: 'Hyperventilation cycles followed by deep breath retention.',
      ),
    ];
  }
}
