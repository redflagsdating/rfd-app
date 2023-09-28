import 'package:flutter/foundation.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
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

    _logger.d("Flavor profile: ${FlavorConfig.instance.variables["longName"]}");
  }
}
