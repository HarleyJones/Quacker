import 'package:fritter/catcher/exceptions.dart';

class Catcher {
  static void reportSyntheticException(SyntheticException error) {
    print(error);
  }

  static void reportException(Object? e, [Object? stackTrace]) {
    print(stackTrace);
  }
}
