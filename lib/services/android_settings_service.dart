import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class AndroidSettingsService {
  static const MethodChannel _channel =
      MethodChannel('oleksandrai/settings');

  Future<void> openVoiceAssistantSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('openVoiceAssistantSettings');
    } on MissingPluginException catch (e) {
      print('openVoiceAssistantSettings not implemented: $e');
    }
  }

  Future<void> openOverlaySettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('openOverlaySettings');
    } on MissingPluginException catch (e) {
      print('openOverlaySettings not implemented: $e');
    }
  }

  /// Check and request overlay permission. Returns true if granted.
  static Future<bool> ensureOverlayPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final granted = await FlutterOverlayWindow.isPermissionGranted();
      if (!granted) {
        final result = await FlutterOverlayWindow.requestPermission();
        return result ?? false;
      }
      return true;
    } catch (e) {
      print('ensureOverlayPermission error: $e');
      return false;
    }
  }
}
