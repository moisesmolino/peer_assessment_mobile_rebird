//import 'dart:math' as math;
import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';

class RadarChartWidget extends StatelessWidget {
  final double punctuality;
  final double contributions;
  final double commitment;
  final double attitude;
  final double maxValue;

  const RadarChartWidget({
    super.key,
    required this.punctuality,
    required this.contributions,
    required this.commitment,
    required this.attitude,
    this.maxValue = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _RadarPainter(
          values: [punctuality, contributions, commitment, attitude],
          maxValue: maxValue,
        ),
        child: _AxisLabels(),
      ),
    );
  }
}

class _AxisLabels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Color(0xFFFF8C60),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    return Stack(
      children: [
        // Top - Punc
        const Positioned(
          top: 4,
          left: 0,
          right: 0,
          child: Text('Punc', textAlign: TextAlign.center, style: style),
        ),
        // Right - Cont
        const Positioned(
          right: 4,
          top: 0,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Cont', style: style)],
          ),
        ),
        // Bottom - Comm
        const Positioned(
          bottom: 4,
          left: 0,
          right: 0,
          child: Text('Comm', textAlign: TextAlign.center, style: style),
        ),
        // Left - Atti
        const Positioned(
          left: 4,
          top: 0,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Atti', style: style)],
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<double> values;
  final double maxValue;

  _RadarPainter({required this.values, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Leave 30px for labels on each side
    final radius = (size.width / 2) - 30;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF3A2016)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 5; level++) {
      final r = radius * level / 5;
      final path = _diamondPath(center, r);
      canvas.drawPath(path, gridPaint);
    }

    // Axis lines
    final axisPaint = Paint()
      ..color = const Color(0xFF3A2016)
      ..strokeWidth = 1;

    final axisPoints = _axisPoints(center, radius);
    for (final pt in axisPoints) {
      canvas.drawLine(center, pt, axisPaint);
    }

    // Filled area
    final fillPaint = Paint()
      ..color = const Color(0xFF9E9E9E).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dataPath = _dataPath(center, radius);
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);
  }

  // Axes: top, right, bottom, left (clockwise, matching values order: punc, cont, comm, atti)
  List<Offset> _axisPoints(Offset center, double radius) {
    return [
      Offset(center.dx, center.dy - radius), // top
      Offset(center.dx + radius, center.dy), // right
      Offset(center.dx, center.dy + radius), // bottom
      Offset(center.dx - radius, center.dy), // left
    ];
  }

  Path _diamondPath(Offset center, double r) {
    final path = Path();
    path.moveTo(center.dx, center.dy - r);
    path.lineTo(center.dx + r, center.dy);
    path.lineTo(center.dx, center.dy + r);
    path.lineTo(center.dx - r, center.dy);
    path.close();
    return path;
  }

  Path _dataPath(Offset center, double radius) {
    final axisPoints = _axisPoints(center, radius);
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final ratio = (values[i] / maxValue).clamp(0.0, 1.0);
      final pt = Offset(
        center.dx + (axisPoints[i].dx - center.dx) * ratio,
        center.dy + (axisPoints[i].dy - center.dy) * ratio,
      );
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.values != values || old.maxValue != maxValue;
}
