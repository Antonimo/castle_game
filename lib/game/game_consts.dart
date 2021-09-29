class GameConsts {
  static const CALCULATIONS_PER_SECOND = 40;
  static const PLAYING_GAME_STATE_EMITS_PER_SECOND = 40;
  // static const PLAYING_GAME_STATE_EMITS_PER_SECOND = 1;

  // Sizes
  static const BASE_SIZE = 30.0;
  static const UNIT_SIZE = 8.0;
  static const PENDING_UNIT_MARKER_SIZE = 15.0;

  // Stats
  static const BASE_MAX_HP = 300.0;
  static const UNIT_MAX_HP = 60.0;

  static const UNIT_SPEED = 30.0; // pixels per second

  // Mechanics
  static const DRAW_DISTANCE_MAX = 1300.0;

  // Game logic
  static const INITIAL_NEXT_UNIT_COOLDOWN = 3.0;
  static const NEXT_UNIT_COOLDOWN = 5.0;
  static const UNIT_ENGAGED_COOLDOWN = 3.0;
  static const UNIT_ENGAGE_DISTANCE = 17.0; // size * 2 + 1
  static const UNIT_ENGAGE_BASE_DISTANCE = 32.0; // base size + 2
}
