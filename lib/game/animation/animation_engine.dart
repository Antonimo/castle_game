import 'package:castle_game/game/animation/game_animation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AnimationEngine {
  static var debug = false;

  Offset animationOffset = Offset(0.0, 0.0);
  double animationTime = 0.0;

  GameAnimation? animation;

  void setAnimation(animation) {
    this.animation = animation;
  }

  void clearAnimation() {
    this.animation = null;
  }

  void animate(double dt) {
    animation?.before(this);

    if (animation == null) {
      animationTime = 0.0;
      animationOffset = Offset.zero;
      return;
    }

    // remaining delta time
    double rdt = dt;

    debugPrint('@ Animate() dt: $dt, animationTime: $animationTime');

    int animationCount = 0;

    while (rdt > 0) {
      debugPrint('___ Animating! animationTime: $animationTime, rdt: $rdt');

      // prevent infinite loop
      animationCount++;
      if (animationCount > 10) break;

      // get the current animation step
      double stepTimeProgress = 0;

      final step = animation!.steps.firstWhereOrNull((step) {
        stepTimeProgress += step.duration;

        debugPrint('Get Step: stepTimeProgress:$stepTimeProgress, step.duration: ${step.duration},'
            ' animationTime < stepTimeProgress: ${animationTime < stepTimeProgress}');

        return animationTime < stepTimeProgress;
      });

      if (step == null) {
        // loop animation
        animationTime = animationTime - stepTimeProgress;
        return;
      }

      debugPrint('Animating Step rdt: $rdt');

      // adjusted step animation time
      double at = rdt;

      // include animation time
      if (animationTime + rdt > stepTimeProgress) {
        debugPrint('animationTime:$animationTime + rdt:$rdt > ${stepTimeProgress} !!!');
        //            0.1           0.036        0.1
        at = rdt - (animationTime + rdt - stepTimeProgress);
      }

      debugPrint('Animating Step at: $at');

      step.calc(this, at);

      // if delta time is more than this step, use only the remaining time
      rdt -= at;
      animationTime += at;

      debugPrint('___ Animating! END; Step at: $at, rdt:$rdt, animationTime:$animationTime');
    }
  }

  static debugPrint(String str) {
    if (!debug) return;
    print(str);
  }
}
