import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class BigOProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const BigOProgress({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 140, height: 140,
            child: CustomPaint(
              painter: _BigOPainter(progress: progress),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const Text(
                "ПРОГРЕС",
                style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigOPainter extends CustomPainter {
  final double progress;
  _BigOPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paintBg = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    
    final paintValue = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paintBg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paintValue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradient;
  final VoidCallback onTap;

  const PremiumCard({Key? key, required this.child, required this.gradient, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: gradient.first.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      gradient: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 20),
          const Spacer(),
          const Text("18°C", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Ясно", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          const Text("📍 Київ", style: TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return PremiumCard(
      gradient: [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 20),
          const Spacer(),
          Text(DateFormat('dd').format(now), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          Text(DateFormat('EEEE').format(now).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(DateFormat('MMMM').format(now).toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}

class HealthWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const HealthWidget({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      gradient: [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ЗДОРОВ'Я", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          const Spacer(),
          _buildHealthRow(Icons.local_fire_department, "Кал", "${data['caloriesNow']}/${data['caloriesGoal']}"),
          _buildHealthRow(Icons.water_drop, "Вода", "${data['waterNow']}/${data['waterGoal']}"),
          _buildHealthRow(Icons.bedtime, "Сон", "${data['sleepNow']}/${data['sleepGoal']}"),
          _buildHealthRow(Icons.directions_run, "Кроки", "${data['stepsNow']}/${data['stepsGoal']}"),
        ],
      ),
    );
  }

  Widget _buildHealthRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 10),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8)),
          const Spacer(),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class TimeTimerWidget extends StatefulWidget {
  const TimeTimerWidget({Key? key}) : super(key: key);
  @override
  State<TimeTimerWidget> createState() => _TimeTimerWidgetState();
}

class _TimeTimerWidgetState extends State<TimeTimerWidget> {
  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      gradient: [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, _) {
               return Text(DateFormat('HH:mm:ss').format(DateTime.now()), 
                 style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1));
            }
          ),
          const SizedBox(height: 4),
          Text(DateFormat('E, d MMM').format(DateTime.now()).toUpperCase(), 
            style: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
