import 'package:castle_game/game/animation/animation_engine.dart';
import 'package:castle_game/game/animation/animation_step.dart';

abstract class GameAnimation {
  List<AnimationStep> steps = [];

  before(AnimationEngine animationEngine) {}
}
