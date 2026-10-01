import 'package:flutter/material.dart';
import '../../theme.dart';
import '../app_data.dart';

class TrendScreen extends StatefulWidget {
  final MethaneSource source;
  const TrendScreen({super.key, required this.source});

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _draw;
  int? _hoverIdx;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _draw = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.source;
    final values = s.observations.map((o) => o.value).toList();
    final dates = s.observations.map((o) => o.date).toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final first = values.first;
    final last = values.last;
    final pctChange = ((last - first) / first * 100).toStringAsFixed(1);

    return Container(
      color: AppTheme.spaceBlack,
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [

          Row(
            children: [
              _metric('CURRENT', last.toStringAsFixed(0)),
              const SizedBox(width: 16),
              _metric('CHANGE', '+$pctChange%', color: AppTheme.methane),
              const SizedBox(width: 16),
              _metric('TREND', 'RISING', color: AppTheme.methane),
              const SizedBox(width: 16),
              _metric('OBSERVATIONS', '${values.length}'),
              const SizedBox(width: 16),
              _metric('PERIOD', '${dates.first} → ${dates.last}'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.panelBorder),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text('DEMO DATA', style: monoText(9, c: AppTheme.textDim)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            height: 480,
            decoration: BoxDecoration(
              color: AppTheme.deepSpaceBlack,
              border: Border.all(color: AppTheme.panelBorder),
              borderRadius: BorderRadius.circular(2),
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, color: AppTheme.accent, size: 16),
                    const SizedBox(width: 8),
                    Text('OBSERVATION TREND', style: monoText(10)),
                    const Spacer(),
                    Text('${s.id}', style: monoText(10, c: AppTheme.methane)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Methane index across observation dates',
                  style: cinBody(12, c: AppTheme.textDim),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _draw,
                    builder: (context, _) {
                      return LayoutBuilder(builder: (context, c) {
                        return MouseRegion(
                          onHover: (e) {
                            final padL = padLConst;
                            final padR = 40.0;
                            final w = c.maxWidth - padL - padR;
                            final idx = ((e.localPosition.dx - padL) / w * (values.length - 1)).round();
                            final clamped = idx.clamp(0, values.length - 1);
                            if (clamped != _hoverIdx) {
                              setState(() => _hoverIdx = clamped);
                            }
                          },
                          onExit: (_) => setState(() => _hoverIdx = null),
                          child: CustomPaint(
                            size: Size(c.maxWidth, c.maxHeight),
                            painter: _TrendChartPainter(
                              values: values,
                              dates: dates,
                              progress: _draw.value,
                              hoverIdx: _hoverIdx,
                              maxVal: maxVal,
                              minVal: minVal,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.deepSpaceBlack,
              border: Border.all(color: AppTheme.panelBorder),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: AppTheme.warning, size: 16),
                    const SizedBox(width: 8),
                    Text('EVIDENCE SUMMARY', style: monoText(10)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Repeated observations indicate a sustained emission pattern over the observation period. '
                  'The source shows a $pctChange% change between first detection and latest measurement.',
                  style: cinBody(14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _evidenceChip('OBSERVATION', AppTheme.accent),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward,
                          color: AppTheme.textDim, size: 14),
                    ),
                    _evidenceChip('TREND', AppTheme.methane),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward,
                          color: AppTheme.textDim, size: 14),
                    ),
                    _evidenceChip('EVIDENCE', AppTheme.warning),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _evidenceChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(label, style: monoText(10, c: color)),
      );

  Widget _metric(String label, String value, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.deepSpaceBlack,
          border: Border.all(color: AppTheme.panelBorder),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: monoText(9, c: AppTheme.textDim)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                  color: color ?? AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                )),
          ],
        ),
      ),
    );
  }
}

const double padLConst = 60.0;

class _TrendChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> dates;
  final double progress;
  final int? hoverIdx;
  final double maxVal;
  final double minVal;
  _TrendChartPainter({
    required this.values,
    required this.dates,
    required this.progress,
    required this.hoverIdx,
    required this.maxVal,
    required this.minVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padL = padLConst;
    const padR = 40.0;
    const padT = 20.0;
    const padB = 40.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;

    final maxV = maxVal * 1.15;
    final minV = minVal * 0.85;

    final gridPaint = Paint()
      ..color = AppTheme.subtleBlue.withOpacity(0.4)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 5; i++) {
      final y = padT + (h / 5) * i;
      canvas.drawLine(Offset(padL, y), Offset(padL + w, y), gridPaint);
      final v = maxV - (maxV - minV) / 5 * i;
      final tp = TextPainter(
        text: TextSpan(
          text: v.toStringAsFixed(0),
          style: TextStyle(color: AppTheme.textDim, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(padL - tp.width - 8, y - 5));
    }

    final axisPaint = Paint()
      ..color = AppTheme.subtleBlue
      ..strokeWidth = 1;
    canvas.drawLine(Offset(padL, padT), Offset(padL, padT + h), axisPaint);
    canvas.drawLine(
        Offset(padL, padT + h), Offset(padL + w, padT + h), axisPaint);

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = padL + (w / (values.length - 1)) * i;
      final y = padT + h - ((values[i] - minV) / (maxV - minV)) * h;
      points.add(Offset(x, y));
    }

    for (int i = 0; i < dates.length; i++) {
      final x = points[i].dx;
      final tp = TextPainter(
        text: TextSpan(
          text: dates[i],
          style: TextStyle(color: AppTheme.textDim, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, padT + h + 10));
    }

    final drawUpTo = (values.length * progress).clamp(1, values.length).toInt();

    final fillPath = Path();
    fillPath.moveTo(points.first.dx, padT + h);
    for (int i = 0; i < drawUpTo; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points[drawUpTo - 1].dx, padT + h);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.methane.withOpacity(0.3),
            AppTheme.methane.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(padL, padT, w, h)),
    );

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < drawUpTo; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final cx = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6)
        ..color = AppTheme.methane.withOpacity(0.4),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppTheme.methane
        ..strokeCap = StrokeCap.round,
    );

    for (int i = 0; i < drawUpTo; i++) {
      final p = points[i];
      final isHover = i == hoverIdx;
      canvas.drawCircle(p, isHover ? 7 : 4, Paint()..color = AppTheme.methane);
      canvas.drawCircle(
        p,
        isHover ? 11 : 7,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHover ? 1.5 : 1
          ..color = AppTheme.textPrimary,
      );
    }

    if (hoverIdx != null && hoverIdx! < drawUpTo) {
      final p = points[hoverIdx!];
      final v = values[hoverIdx!];
      final d = dates[hoverIdx!];
      final tp1 = TextPainter(
        text: TextSpan(
          text: v.toStringAsFixed(0),
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final tp2 = TextPainter(
        text: TextSpan(text: d, style: monoText(10)),
        textDirection: TextDirection.ltr,
      )..layout();
      final tipW = tp1.width + 16;
      final tipH = 40.0;
      final tipX = (p.dx - tipW / 2).clamp(padL, padL + w - tipW);
      final tipY = p.dy - tipH - 12;
      final tipRect = Rect.fromLTWH(tipX, tipY, tipW, tipH);
      canvas.drawRRect(
        RRect.fromRectAndRadius(tipRect, const Radius.circular(2)),
        Paint()..color = AppTheme.panelBg,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tipRect, const Radius.circular(2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = AppTheme.methane,
      );
      tp1.paint(canvas, Offset(tipX + 8, tipY + 6));
      tp2.paint(canvas, Offset(tipX + 8, tipY + 22));

      canvas.drawLine(
        Offset(p.dx, tipY + tipH),
        Offset(p.dx, p.dy - 8),
        Paint()
          ..color = AppTheme.methane
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) => true;
}
