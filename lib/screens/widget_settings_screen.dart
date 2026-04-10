import 'package:flutter/material.dart';

import '../services/android_settings_service.dart';
import '../services/widget_service.dart';

class WidgetSettingsScreen extends StatefulWidget {
  const WidgetSettingsScreen({Key? key}) : super(key: key);

  @override
  State<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends State<WidgetSettingsScreen> {
  final WidgetService _widgetService = WidgetService();
  final AndroidSettingsService _androidSettings = AndroidSettingsService();
  final TextEditingController _reminderController = TextEditingController();

  @override
  void dispose() {
    _reminderController.dispose();
    super.dispose();
  }

  Future<void> _toggleOverlay(bool enabled) async {
    if (enabled) {
      await AndroidSettingsService.ensureOverlayPermission();
    }
    await _widgetService.setAssistantOverlayEnabled(enabled);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final healthData = _widgetService.getHealthData();
    final reminders = _widgetService.getReminders();
    final assistantMode = _widgetService.getAssistantMode();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text(
          'Налаштування',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionHeader('РЕЖИМ АСИСТЕНТА', Icons.assistant),
            _buildAssistantModeCard(
              assistantMode,
              AssistantMode.classicChat,
              'Класичний чат',
              'Асистент працює тільки всередині застосунку.',
            ),
            _buildAssistantModeCard(
              assistantMode,
              AssistantMode.overlayLive,
              'Live-оверлей',
              'Плаваюча панель поверх інших додатків.',
            ),
            _buildAssistantModeCard(
              assistantMode,
              AssistantMode.defaultAssistant,
              'Системний асистент',
              'Виклик через кнопку Home / системний жест.',
            ),
            _buildToggle(
              'Поверх інших додатків',
              _widgetService.isAssistantOverlayEnabled(),
              _toggleOverlay,
            ),
            _buildToggle(
              'Аналіз екрана',
              _widgetService.isAssistantScreenAnalysisEnabled(),
              (v) async {
                await _widgetService.setAssistantScreenAnalysisEnabled(v);
                setState(() {});
              },
            ),
            ListTile(
              title: const Text(
                'Відкрити системні налаштування асистента',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              trailing: const Icon(Icons.open_in_new, color: Colors.blueAccent),
              onTap: () => _androidSettings.openVoiceAssistantSettings(),
            ),
            ListTile(
              title: const Text(
                'Дозвіл: поверх інших додатків',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              trailing: const Icon(Icons.open_in_new, color: Colors.blueAccent),
              onTap: () => _androidSettings.openOverlaySettings(),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('WIDGET TOGGLES', Icons.grid_view),
            _buildToggle('Weather', _widgetService.isWeatherEnabled(),
                (v) => _setToggle(() => _widgetService.setWeatherEnabled(v))),
            _buildToggle('Calendar', _widgetService.isCalendarEnabled(),
                (v) => _setToggle(() => _widgetService.setCalendarEnabled(v))),
            _buildToggle('Health', _widgetService.isHealthEnabled(),
                (v) => _setToggle(() => _widgetService.setHealthEnabled(v))),
            _buildToggle('Time & Timer', _widgetService.isTimeEnabled(),
                (v) => _setToggle(() => _widgetService.setTimeEnabled(v))),
            const SizedBox(height: 24),
            _buildSectionHeader('HEALTH GOALS', Icons.favorite_border),
            _buildHealthInput('Calories', 'caloriesGoal', healthData['caloriesGoal']),
            _buildHealthInput('Water (ml)', 'waterGoal', healthData['waterGoal']),
            _buildHealthInput('Steps', 'stepsGoal', healthData['stepsGoal']),
            const SizedBox(height: 24),
            _buildSectionHeader('REMINDERS', Icons.list),
            _buildReminderInput(),
            ...reminders.asMap().entries.map((e) => _buildReminderTile(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Future<void> _setToggle(Future<void> Function() setter) async {
    await setter();
    setState(() {});
  }

  Widget _buildAssistantModeCard(
    AssistantMode selected,
    AssistantMode value,
    String title,
    String subtitle,
  ) {
    final isSelected = selected == value;
    return Card(
      color: isSelected ? const Color(0xFF1D2A44) : const Color(0xFF171717),
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<AssistantMode>(
        value: value,
        groupValue: selected,
        activeColor: Colors.blueAccent,
        onChanged: (newValue) async {
          if (newValue == null) return;
          await _widgetService.setAssistantMode(newValue);
          if (newValue == AssistantMode.overlayLive &&
              _widgetService.isAssistantOverlayEnabled()) {
            await AndroidSettingsService.ensureOverlayPermission();
          }
          if (!mounted) return;
          setState(() {});
        },
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blueAccent,
      dense: true,
    );
  }

  Widget _buildHealthInput(String label, String key, int value) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: value.toString(),
            hintStyle: const TextStyle(color: Colors.white30),
            border: InputBorder.none,
          ),
          onSubmitted: (v) {
            final newVal = int.tryParse(v);
            if (newVal != null) {
              _widgetService.updateHealthMetric(key, newVal);
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildReminderInput() {
    return ListTile(
      title: TextField(
        controller: _reminderController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Add Task...',
          hintStyle: TextStyle(color: Colors.white24),
          border: InputBorder.none,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add, color: Colors.blueAccent),
        onPressed: () {
          if (_reminderController.text.isNotEmpty) {
            final list = _widgetService.getReminders();
            list.add({'text': _reminderController.text, 'done': false});
            _widgetService.setReminders(list);
            _reminderController.clear();
            setState(() {});
          }
        },
      ),
    );
  }

  Widget _buildReminderTile(int index, Map<String, dynamic> item) {
    return ListTile(
      leading: Checkbox(
        value: item['done'] as bool? ?? false,
        onChanged: (v) {
          final list = _widgetService.getReminders();
          list[index]['done'] = v ?? false;
          _widgetService.setReminders(list);
          setState(() {});
        },
        activeColor: Colors.blueAccent,
      ),
      title: Text(
        item['text']?.toString() ?? '',
        style: TextStyle(
          color: (item['done'] as bool? ?? false) ? Colors.white24 : Colors.white70,
          decoration:
              (item['done'] as bool? ?? false) ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.white24, size: 16),
        onPressed: () {
          final list = _widgetService.getReminders();
          list.removeAt(index);
          _widgetService.setReminders(list);
          setState(() {});
        },
      ),
    );
  }
}
