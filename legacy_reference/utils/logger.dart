import 'package:logging/logging.dart' as logging;

class AppLogger {
  static final _logger = logging.Logger('BehaviorMind');
  
  static void init() {
    logging.Logger.root.level = logging.Level.ALL;
    logging.Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  static void info(String msg) => _logger.info(msg);
  static void warning(String msg) => _logger.warning(msg);
  static void error(String msg) => _logger.severe(msg);
} 