import 'package:flutter/material.dart';
import '../../theme.dart';
import '../app_data.dart';
import 'screen_map.dart' show projectLatLng;

class CaseFileScreen extends StatefulWidget {
  final MethaneSource source;
  final VoidCallback onViewTrend;
  const CaseFileScreen({
    super.key,
    required this.source,
    required this.onViewTrend,
  });

  @override
  State<CaseFileScreen> createState() => _CaseFileScreenState();
}

class _CaseFileScreenState extends State<CaseFileScreen> {
  bool _trendHover = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.source;
    return Container(
      color: AppTheme.spaceBlack,
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.deepSpaceBlack,
                    border: Border.all(color: AppTheme.panelBorder),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: AppTheme.panelBorder)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.satellite_alt_outlined,
                                color: AppTheme.accent, size: 16),
                            const SizedBox(width: 8),
                            Text('CASE FILE', style: monoText(10)),
                            const Spacer(),
                            Text('DEMO', style: monoText(9, c: AppTheme.textDim)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SOURCE ID', style: monoText(10, c: AppTheme.textDim)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(s.id,
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 44,
                                      fontWeight: FontWeight.w200,
                                      letterSpacing: 2,
                                    )),
                                const SizedBox(width: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.methane.withOpacity(0.12),
                                    border: Border.all(
                                        color: AppTheme.methane.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.methane,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(s.status.toUpperCase(),
                                          style: monoText(9, c: AppTheme.methane)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text('${s.region}, ${s.country}',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                )),
                            const SizedBox(height: 4),
                            Text(
                                '${s.lat.toStringAsFixed(2)}°N · ${s.lon.toStringAsFixed(2)}°E',
                                style: monoText(11, c: AppTheme.textDim)),
                            const SizedBox(height: 24),
                            Text(s.description, style: cinBody(14)),
                            const SizedBox(height: 24),
                            Container(
                              height: 1,
                              color: AppTheme.panelBorder,
                            ),
                            const SizedBox(height: 24),
                            _detailRow('Category', s.category),
                            _detailRow('First observed', s.firstSeen),
                            _detailRow('Last observed', s.lastSeen),
                            _detailRow('Observations', '${s.observations.length}'),
                            _detailRow('Intensity',
                                '${(s.intensity * 100).toInt()}%'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: AppTheme.deepSpaceBlack,
                        border: Border.all(color: AppTheme.panelBorder),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _SourceMiniMapPainter(s),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Icon(Icons.public,
                                    color: AppTheme.accent, size: 14),
                                const SizedBox(width: 6),
                                Text('SOURCE LOCATION',
                                    style: monoText(10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _trendHover = true),
                      onExit: (_) => setState(() => _trendHover = false),
                      child: GestureDetector(
                        onTap: widget.onViewTrend,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: _trendHover
                                ? AppTheme.methane.withOpacity(0.12)
                                : AppTheme.panelBg,
                            border: Border.all(
                              color: _trendHover
                                  ? AppTheme.methane
                                  : AppTheme.panelBorder,
                              width: _trendHover ? 1.2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.show_chart,
                                  color: _trendHover
                                      ? AppTheme.methane
                                      : AppTheme.accent,
                                  size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('VIEW TREND ANALYSIS',
                                        style: monoText(11)),
                                    const SizedBox(height: 2),
                                    Text('Examine the evidence trail',
                                        style: cinBody(11,
                                            c: AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward,
                                  color: _trendHover
                                      ? AppTheme.methane
                                      : AppTheme.textDim,
                                  size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.deepSpaceBlack,
                        border: Border.all(color: AppTheme.panelBorder),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SATELLITES', style: monoText(9, c: AppTheme.textDim)),
                          const SizedBox(height: 10),
                          _satRow('TROPOMI', 'Sentinel-5P'),
                          const SizedBox(height: 6),
                          _satRow('EMIT', 'ISS'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.deepSpaceBlack,
              border: Border.all(color: AppTheme.panelBorder),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AppTheme.panelBorder)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: AppTheme.accent, size: 16),
                      const SizedBox(width: 8),
                      Text('OBSERVATION HISTORY',
                          style: monoText(10)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 18),
                  child: Row(
                    children: List.generate(s.observations.length, (i) {
                      final o = s.observations[i];
                      return Expanded(
                        child: _ObsCell(
                          date: o.date,
                          value: o.value.toStringAsFixed(0),
                          satellite: o.satellite,
                          isLast: i == s.observations.length - 1,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _satRow(String name, String platform) => Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 8),
          Text(name, style: monoText(11)),
          const SizedBox(width: 8),
          Text('· $platform', style: cinBody(11, c: AppTheme.textDim)),
        ],
      );

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(label, style: monoText(10, c: AppTheme.textDim)),
            ),
            Text(value, style: cinBody(14, c: AppTheme.textPrimary)),
          ],
        ),
      );
}

class _SourceMiniMapPainter extends CustomPainter {
  final MethaneSource source;
  _SourceMiniMapPainter(this.source);

  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFF122038), Color(0xFF0A1525)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), landPaint);

    const minLat = 20.5, maxLat = 26.5;
    const minLon = 87.5, maxLon = 93.0;
    final pts = [
      [22.0, 92.0], [23.5, 92.5], [24.8, 92.3], [25.4, 91.5],
      [26.0, 90.5], [25.7, 89.5], [25.0, 89.0], [24.5, 88.5],
      [23.7, 89.0], [22.8, 89.5], [22.0, 90.5], [21.5, 91.5],
    ];
    final path = Path();
    final first = Offset(
      ((pts[0][1] - minLon) / (maxLon - minLon)) * size.width,
      ((maxLat - pts[0][0]) / (maxLat - minLat)) * size.height,
    );
    path.moveTo(first.dx, first.dy);
    for (final p in pts.skip(1)) {
      final pt = Offset(
        ((p[1] - minLon) / (maxLon - minLon)) * size.width,
        ((maxLat - p[0]) / (maxLat - minLat)) * size.height,
      );
      path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1A2845).withOpacity(0.6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.accent.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final pt = projectLatLng(source.lat, source.lon, size);

    canvas.drawCircle(
      pt,
      50,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.methane.withOpacity(0.4),
            AppTheme.methane.withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(center: pt, radius: 50)),
    );

    final crossPaint = Paint()
      ..color = AppTheme.textPrimary
      ..strokeWidth = 1;
    canvas.drawLine(pt + Offset(-30, 0), pt + Offset(-12, 0), crossPaint);
    canvas.drawLine(pt + Offset(12, 0), pt + Offset(30, 0), crossPaint);
    canvas.drawLine(pt + Offset(0, -30), pt + Offset(0, -12), crossPaint);
    canvas.drawLine(pt + Offset(0, 12), pt + Offset(0, 30), crossPaint);
    canvas.drawCircle(pt, 4, Paint()..color = AppTheme.methane);
  }

  @override
  bool shouldRepaint(covariant _SourceMiniMapPainter oldDelegate) => false;
}

class _ObsCell extends StatelessWidget {
  final String date;
  final String value;
  final String satellite;
  final bool isLast;
  const _ObsCell({
    required this.date,
    required this.value,
    required this.satellite,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.methane,
                  boxShadow: [
                    BoxShadow(color: AppTheme.methane.withOpacity(0.5), blurRadius: 8),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: AppTheme.subtleBlue,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: monoText(11)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(height: 2),
                  Text(satellite, style: monoText(9, c: AppTheme.textDim)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
