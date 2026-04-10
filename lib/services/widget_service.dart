import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum AssistantMode {
  classicChat,
  overlayLive,
  defaultAssistant,
}

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  SharedPreferences? _prefs;

  // Widget Toggles
  static const String _kWeatherEnabled = 'widget_weather_enabled';
  static const String _kCalendarEnabled = 'widget_calendar_enabled';
  static const String _kHealthEnabled = 'widget_health_enabled';
  static const String _kTimeEnabled = 'widget_time_enabled';
  static const String _kProductivityEnabled = 'widget_productivity_enabled';

  // Metrics
  static const String _kHealthData = 'widget_health_data';
  static const String _kReminders = 'widget_reminders';
  static const String _kMobileCols = 'widget_mobile_cols';
  static const String _kTimerMinutes = 'widget_timer_minutes';
  static const String _kTimerMode = 'widget_timer_mode';
  static const String _kAssistantMode = 'assistant_mode';
  static const String _kAssistantOverlayEnabled = 'assistant_overlay_enabled';
  static const String _kAssistantScreenAnalysisEnabled =
      'assistant_screen_analysis_enabled';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Toggles
  bool isWeatherEnabled() => _prefs?.getBool(_kWeatherEnabled) ?? true;
  bool isCalendarEnabled() => _prefs?.getBool(_kCalendarEnabled) ?? true;
  bool isHealthEnabled() => _prefs?.getBool(_kHealthEnabled) ?? true;
  bool isTimeEnabled() => _prefs?.getBool(_kTimeEnabled) ?? true;
  bool isProductivityEnabled() => _prefs?.getBool(_kProductivityEnabled) ?? true;

  Future<void> setWeatherEnabled(bool v) async => await _prefs?.setBool(_kWeatherEnabled, v);
  Future<void> setCalendarEnabled(bool v) async => await _prefs?.setBool(_kCalendarEnabled, v);
  Future<void> setHealthEnabled(bool v) async => await _prefs?.setBool(_kHealthEnabled, v);
  Future<void> setTimeEnabled(bool v) async => await _prefs?.setBool(_kTimeEnabled, v);
  Future<void> setProductivityEnabled(bool v) async => await _prefs?.setBool(_kProductivityEnabled, v);

  // Layout
  int getMobileCols() => _prefs?.getInt(_kMobileCols) ?? 2;
  Future<void> setMobileCols(int cols) async => await _prefs?.setInt(_kMobileCols, cols);

  // Timer
  int getTimerMinutes() => _prefs?.getInt(_kTimerMinutes) ?? 5;
  bool isTimerMode() => _prefs?.getBool(_kTimerMode) ?? false;
  Future<void> setTimerMinutes(int m) async => await _prefs?.setInt(_kTimerMinutes, m);
  Future<void> setTimerMode(bool m) async => await _prefs?.setBool(_kTimerMode, m);

  AssistantMode getAssistantMode() {
    final raw = _prefs?.getString(_kAssistantMode);
    return AssistantMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => AssistantMode.overlayLive,
    );
  }

  Future<void> setAssistantMode(AssistantMode mode) async {
    await _prefs?.setString(_kAssistantMode, mode.name);
  }

  bool isAssistantOverlayEnabled() =>
      _prefs?.getBool(_kAssistantOverlayEnabled) ?? true;

  Future<void> setAssistantOverlayEnabled(bool value) async {
    await _prefs?.setBool(_kAssistantOverlayEnabled, value);
  }

  bool isAssistantScreenAnalysisEnabled() =>
      _prefs?.getBool(_kAssistantScreenAnalysisEnabled) ?? true;

  Future<void> setAssistantScreenAnalysisEnabled(bool value) async {
    await _prefs?.setBool(_kAssistantScreenAnalysisEnabled, value);
  }

  // Health Metrics (Calories, Water, Sleep, Steps)
  Map<String, dynamic> getHealthData() {
    String? raw = _prefs?.getString(_kHealthData);
    if (raw == null) {
      return {
        'caloriesGoal': 2000, 'caloriesNow': 1500,
        'waterGoal': 2000, 'waterNow': 1200,
        'sleepGoal': 8, 'sleepNow': 7,
        'stepsGoal': 10000, 'stepsNow': 6500,
      };
    }
    return jsonDecode(raw);
  }

  Future<void> updateHealthMetric(String key, int value) async {
    Map<String, dynamic> data = getHealthData();
    data[key] = value;
    await _prefs?.setString(_kHealthData, jsonEncode(data));
  }

  // Reminders
  List<Map<String, dynamic>> getReminders() {
    String? raw = _prefs?.getString(_kReminders);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  Future<void> setReminders(List<Map<String, dynamic>> list) async {
    await _prefs?.setString(_kReminders, jsonEncode(list));
  }
}
