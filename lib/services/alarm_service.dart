import 'dart:io';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AlarmService {
  static const MethodChannel _channel =
      MethodChannel('com.example.your_app/alarm');

  // 정확한 알람 권한 확인 메서드
  Future<bool> isExactAlarmAllowed() async {
    if (Platform.isAndroid) {
      try {
        final bool allowed = await _channel.invokeMethod('isExactAlarmAllowed');
        return allowed;
      } on PlatformException catch (e) {
        print("Failed to check exact alarm permission: '${e.message}'.");
        return false;
      }
    }
    return true; // iOS나 기타 플랫폼에서는 true 반환
  }

  // 정확한 알람 권한 요청을 위한 설정 페이지로 이동
  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      const String exactAlarmSettings =
          'android.settings.REQUEST_SCHEDULE_EXACT_ALARM';
      await launchUrl(
        Uri.parse('android.settings.REQUEST_SCHEDULE_EXACT_ALARM'),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
