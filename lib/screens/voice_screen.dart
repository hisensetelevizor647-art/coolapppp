import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import '../services/api_service.dart';
import '../services/widget_service.dart';
import '../screens/widget_settings_screen.dart';
import '../widgets/orbiting_visualizer.dart';
import '../widgets/assistant_control_panel.dart';
import '../widgets/premium_widgets.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({Key? key}) : super(key: key);

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _text = 'Натисніть на мікрофон...';
  
  bool _showSubtitles = true;
  bool _audioEnabled = true;
  
  final ApiService _apiService = ApiService();
  final WidgetService _widgetService = WidgetService();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _setupTts();
  }

  void _setupTts() async {
    await _flutterTts.setLanguage("uk-UA");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.finalResult) _stopAndProcess(_text);
          }),
        );
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() => setState(() { _isListening = false; _speech.stop(); });
  
  void _stopAndProcess(String recognized) async {
    _stopListening();
    setState(() => _text = 'Thinking...');
    final answer = await _apiService.sendMessage(recognized);
    setState(() => _text = answer);
    if (_audioEnabled) await _flutterTts.speak(answer);
  }

  double _calculateDailyProgress() {
    final health = _widgetService.getHealthData();
    final reminders = _widgetService.getReminders();
    
    double healthProgress = 0;
    const metrics = ['calories', 'water', 'sleep', 'steps'];
    for (var m in metrics) {
       double now = (health[m + 'Now'] ?? 0).toDouble();
       double goal = (health[m + 'Goal'] ?? 1).toDouble();
       healthProgress += (now / goal).clamp(0.0, 1.0);
    }
    double healthAvg = healthProgress / metrics.length;
    
    double taskProgress = reminders.isEmpty ? 1.0 : reminders.where((r) => r['done'] == true).length / reminders.length;
    
    return (healthAvg + taskProgress) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final healthData = _widgetService.getHealthData();
    final dailyProgress = _calculateDailyProgress();
    final int cols = _widgetService.getMobileCols();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar Area
          SliverAppBar(
            backgroundColor: Colors.transparent,
            floating: true,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Image.asset('assets/logo.png', width: 20, height: 20, fit: BoxFit.contain),
                const SizedBox(width: 10),
                const Text("ASSISTANT MODE", style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ],
            ),
            actions: [
               IconButton(
                  icon: const Icon(Icons.dashboard_customize_outlined, color: Colors.blueAccent, size: 24),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WidgetSettingsScreen())).then((_) => setState((){})),
               )
            ],
          ),

          // Big O Area
          SliverToBoxAdapter(
            child: BigOProgress(progress: dailyProgress),
          ),

          // Subtitles Area
          if (_showSubtitles)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12),
                child: Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
                ),
              ),
            ),

          // Dashboard Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildListDelegate([
                if (_widgetService.isWeatherEnabled()) const WeatherWidget(),
                if (_widgetService.isCalendarEnabled()) const CalendarWidget(),
                if (_widgetService.isHealthEnabled()) HealthWidget(data: healthData),
                if (_widgetService.isTimeEnabled()) const TimeTimerWidget(),
              ]),
            ),
          ),

          // Spacing for Bottom Controls
          const SliverToBoxAdapter(child: SizedBox(height: 250)),
        ],
      ),

      // Floating Mic and Control Panel
      bottomSheet: Container(
        color: Colors.black,
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _listen,
              child: OrbitingVisualizer(isListening: _isListening),
            ),
            const SizedBox(height: 20),
            AssistantControlPanel(
              showSubtitles: _showSubtitles,
              audioEnabled: _audioEnabled,
              onToggleSubtitles: () => setState(() => _showSubtitles = !_showSubtitles),
              onToggleAudio: () { setState(() => _audioEnabled = !_audioEnabled); if (!_audioEnabled) _flutterTts.stop(); },
              onClose: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
