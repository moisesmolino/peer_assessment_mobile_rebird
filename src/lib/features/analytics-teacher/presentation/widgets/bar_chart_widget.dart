import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BarChartEntry {
  final String label;
  final double value;

  const BarChartEntry({required this.label, required this.value});
}

class BarChartWidget extends StatelessWidget {
  final List<BarChartEntry> entries;
  final Color barColor;
  final double maxValue;

  const BarChartWidget({
    super.key,
    required this.entries,
    this.barColor = const Color(0xFFBB3322),
    this.maxValue = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    const gridLevels = [0.0, 1.25, 2.5, 3.75, 5.0];
    const chartHeight = 140.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Y-axis labels
        SizedBox(
          width: 34,
          height: chartHeight,
          child: Stack(
            children: gridLevels.map((v) {
              final ratio =
                  (v - gridLevels.first) / (gridLevels.last - gridLevels.first);
              final top = chartHeight * (1 - ratio);
              return Positioned(
                top: top - 7,
                right: 6,
                child: Text(
                  v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 2),
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 9),
                ),
              );
            }).toList(),
          ),
        ),
        // Chart + labels
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: chartHeight,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _BarChartPainter(
                    entries: entries,
                    barColor: barColor,
                    maxValue: maxValue,
                    minValue: gridLevels.first,
                    gridLevels: gridLevels,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: entries.map((e) {
                  return Expanded(
                    child: Text(
                      e.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<BarChartEntry> entries;
  final Color barColor;
  final double maxValue;
  final double minValue;
  final List<double> gridLevels;

  _BarChartPainter({
    required this.entries,
    required this.barColor,
    required this.maxValue,
    required this.minValue,
    required this.gridLevels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF3A2016)
      ..strokeWidth = 1;

    final range = gridLevels.last - gridLevels.first;

    for (final level in gridLevels) {
      final y = size.height * (1 - (level - minValue) / range);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (entries.isEmpty) return;

    final barPaint = Paint()..color = barColor;
    final barWidth = (size.width / entries.length) * 0.55;
    final spacing = size.width / entries.length;

    for (int i = 0; i < entries.length; i++) {
      final v = entries[i].value.clamp(minValue, maxValue);
      final barHeight = size.height * (v - minValue) / range;
      final x = spacing * i + spacing / 2;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              x - barWidth / 2, size.height - barHeight, barWidth, barHeight),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.entries != entries || old.barColor != barColor;
}
