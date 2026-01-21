import 'package:logger/logger.dart';


import 'package:flutter/foundation.dart';

final logger = Logger(
  printer: PrettyPrinter(),
  level: kReleaseMode ? Level.off : Level.debug,
);