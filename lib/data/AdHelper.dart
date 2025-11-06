import 'dart:io';

import 'package:flutter/foundation.dart';

class AdHelper {
  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return kReleaseMode
          ? "ca-app-pub-3940256099942544/1033173712"
          : "ca-app-pub-8663702650471623/4221414017";
      // return "ca-app-pub-3940256099942544/1033173712";
      // return "ca-app-pub-8663702650471623/4221414017";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
