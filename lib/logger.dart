import 'dart:developer' as dev;

class Log {
  static void log(String level, String tag, Object object) {
    print('$level/$tag: $object');
  }

  static var d = Log.debug;

  static void debug(String tag, Object object) {
    dev.log('D/$tag: $object');
  }

  static var i = Log.info;

  static void info(String tag, Object object) {
    log('I', tag, object);
  }

  static var e = Log.error;

  static void error(String tag, Object object) {
    log('E', tag, object);
  }
}
