import 'dart:io';

import 'package:flutter/services.dart';
import 'package:watertracker/constant/constant.dart';

class PlatformMessenger {
  PlatformMessenger._();

  static const _platformChannel = MethodChannel(Constant.platformChannelName);

  static Future<void> invokeMethod(String method, [dynamic arguments]) async {
    if (Platform.isAndroid) {
      await _platformChannel.invokeMethod<void>(method, arguments);
    }
  }

  static void setMethodCallHandler(
      Future<dynamic> Function(MethodCall) handler) {
    if (Platform.isAndroid) {
      _platformChannel.setMethodCallHandler(handler);
    }
  }
}
