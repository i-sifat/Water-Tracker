import 'package:flutter/services.dart';
import 'package:watertracker/core/constants/app_constants.dart';

class PlatformService {
  const PlatformService._();

  static const _platformChannel =
      MethodChannel(AppConstants.platformChannelName);

  static Future<void> invokeMethod(String method, [dynamic arguments]) async {
    await _platformChannel.invokeMethod<void>(method, arguments);
  }

  static void setMethodCallHandler(
    Future<dynamic> Function(MethodCall) handler,
  ) {
    _platformChannel.setMethodCallHandler(handler);
  }
}
