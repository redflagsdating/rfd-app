import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// [LoggerProvider]
class LoggerProvider {
  late Logger _logger;
  Logger get logger => _logger;

  static const level = kDebugMode
      ? Level.debug
      : kReleaseMode
          ? Level.error
          : kProfileMode
              ? Level.fatal
              : Level.off;

  LoggerProvider() {
    _logger = Logger(
      level: level,
      printer: PrettyPrinter(),
    );
  }
}
