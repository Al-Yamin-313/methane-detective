import 'package:flutter/material.dart';
import '../../theme.dart';
import '../app_data.dart';
import '../nasa_api.dart';

class MapScreen extends StatefulWidget {
  final String filter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSelectSource;
  const MapScreen({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.onSelectSource,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  String? _hoveredSourceId;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  List<MethaneSource> get _filteredSources {
    if (widget.filter == 'All sources') return AppData.sources;
    return AppData.sources.where((s) => s.category == widget.filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.spaceBlack,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: LayoutBuilder(builder: (context, c) {
              final size = Size(c.maxWidth, c.maxHeight);
              return MouseRegion(
                onHover: (e) {
                  final hit = _hitTest(e.localPosition, size);
                  if (hit != _hoveredSourceId) {
                    setState(() => _hoveredSourceId = hit);
                  }
                },
                onExit: (_) => setState(() => _hoveredSourceId = null),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _InteractiveMapPainter(
                              sources: _filteredSources,
                              pulse: _pulse.value,
                              hoveredId: _hoveredSourceId,
                              selectedId: null,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 24,
                      child: _Legend(),
                    ),
                    Positioned(
                      right: 24,
                      top: 24,
                      child: _RegionStats(filtered: _filteredSources.length),
                    ),
                    Positioned(
                      right: 24,
                      bottom: 24,
                      child: _Disclaimer(),
                    ),
                  ],
                ),
              );
            }),
          ),
          Container(
            width: 1,
            color: AppTheme.panelBorder,
          ),
          SizedBox(
            width: 320,
            child: _SourceList(
              sources: _filteredSources,
              onSelectSource: widget.onSelectSource,
              onFilterChanged: widget.onFilterChanged,
              currentFilter: widget.filter,
            ),
          ),
        ],
      ),
    );
  }

  String? _hitTest(Offset local, Size size) {
    const minLat = 20.5, maxLat = 26.5;
    const minLon = 87.5, maxLon = 93.0;
    for (final s in _filteredSources) {
      final x = ((s.lon - minLon) / (maxLon - minLon)) * size.width;
      final y = ((maxLat - s.lat) / (maxLat - minLat)) * size.height;
      final d = (local - Offset(x, y)).distance;
      if (d < 30) return s.id;
    }
    return null;
  }
}

Offset projectLatLng(double lat, double lon, Size size) {
  const minLat = 20.5, maxLat = 26.5;
  const minLon = 87.5, maxLon = 93.0;
  final x = ((lon - minLon) / (maxLon - minLon)) * size.width;
  final y = ((maxLat - lat) / (maxLat - minLat)) * size.height;
  return Offset(x, y);
}

class _InteractiveMapPainter extends CustomPainter {
  final List<MethaneSource> sources;
  final double pulse;
  final String? hoveredId;
  final String? selectedId;
  _InteractiveMapPainter({
    required this.sources,
    required this.pulse,
    required this.hoveredId,
    required this.selectedId,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final gridPaint = Paint()
      ..color = AppTheme.subtleBlue.withOpacity(0.18)
      ..strokeWidth = 0.5;
    for (double i = 50; i < size.width; i += 60) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 50; i < size.height; i += 60) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    final tickPaint = Paint()
      ..color = AppTheme.textDim.withOpacity(0.4)
      ..strokeWidth = 0.5;
    for (double lat = 21.0; lat < 26.5; lat += 1.0) {
      final y = ((26.5 - lat) / 6.0) * size.height;
      canvas.drawLine(Offset(0, y), Offset(6, y), tickPaint);
      final tp = TextPainter(
        text: TextSpan(
          text: '${lat.toStringAsFixed(0)}°N',
          style: TextStyle(color: AppTheme.textDim, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(8, y - 5));
    }
    for (double lon = 88.0; lon < 93.0; lon += 1.0) {
      final x = ((lon - 87.5) / 5.5) * size.width;
      canvas.drawLine(Offset(x, size.height), Offset(x, size.height - 6), tickPaint);
      final tp = TextPainter(
        text: TextSpan(
          text: '${lon.toStringAsFixed(0)}°E',
          style: TextStyle(color: AppTheme.textDim, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - 10, size.height - 18));
    }

    final landPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F1A2E).withOpacity(0.9),
          Color(0xFF0A1322).withOpacity(0.9),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppTheme.accent.withOpacity(0.5);

    final path = Path();
    final ptsList = [
      [22.0, 92.0], [23.5, 92.5], [24.8, 92.3], [25.4, 91.5],
      [26.0, 90.5], [25.7, 89.5], [25.0, 89.0], [24.5, 88.5],
      [23.7, 89.0], [22.8, 89.5], [22.0, 90.5], [21.5, 91.5],
    ];
    final first = projectLatLng(ptsList[0][0], ptsList[0][1], size);
    path.moveTo(first.dx, first.dy);
    for (final p in ptsList.skip(1)) {
      final pt = projectLatLng(p[0], p[1], size);
      path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, borderPaint);

    final sylhet = projectLatLng(24.9, 91.9, size);
    final sylhetGlow = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30)
      ..color = AppTheme.accent.withOpacity(0.18);
    canvas.drawCircle(sylhet, 180, sylhetGlow);

    final regions = [
      (projectLatLng(24.9, 91.9, size), 'SYLHET'),
      (projectLatLng(23.81, 90.41, size), 'DHAKA'),
      (projectLatLng(22.33, 91.83, size), 'CHITTAGONG'),
      (projectLatLng(25.74, 89.27, size), 'RANGPUR'),
    ];
    for (final r in regions) {
      final tp = TextPainter(
        text: TextSpan(
          text: r.$2,
          style: TextStyle(
            color: AppTheme.textDim,
            fontSize: 9,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, r.$1 + Offset(10, -14));
      canvas.drawLine(
        r.$1 + Offset(0, -8),
        r.$1 + Offset(0, -2),
        Paint()
          ..color = AppTheme.textDim.withOpacity(0.4)
          ..strokeWidth = 0.5,
      );
    }

    for (final s in sources) {
      final pt = projectLatLng(s.lat, s.lon, size);
      final isHovered = s.id == hoveredId;
      final isPrimary = s.intensity > 0.85;

      final plumeR = 40.0 + s.intensity * 30;
      final plumePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.methane.withOpacity(0.35 * s.intensity),
            AppTheme.methane.withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(center: pt, radius: plumeR));
      canvas.drawCircle(pt, plumeR, plumePaint);

      if (isHovered) {
        canvas.drawCircle(
          pt,
          22 + (pulse * 8),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = AppTheme.methane,
        );
      }

      if (isPrimary) {
        final ringR = 30 + pulse * 25;
        canvas.drawCircle(
          pt,
          ringR,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = AppTheme.methane.withOpacity((1 - pulse) * 0.5),
        );
      }

      canvas.drawCircle(
        pt,
        isPrimary ? 5 : 3.5,
        Paint()..color = AppTheme.methane,
      );

      canvas.drawCircle(
        pt,
        isPrimary ? 5 : 3.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = AppTheme.textPrimary,
      );

      if (isHovered) {
        final tp = TextPainter(
          text: TextSpan(
            text: s.id,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final pillRect = Rect.fromCenter(
          center: pt + Offset(tp.width / 2 + 18, -12),
          width: tp.width + 16,
          height: 20,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(pillRect, const Radius.circular(2)),
          Paint()..color = AppTheme.methane,
        );
        tp.paint(canvas, pt + Offset(26, -19));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveMapPainter oldDelegate) => true;
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.deepSpaceBlack.withOpacity(0.85),
        border: Border.all(color: AppTheme.panelBorder),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(AppTheme.methane, 6, true),
          const SizedBox(width: 6),
          Text('Methane source', style: monoText(10)),
          const SizedBox(width: 16),
          _dot(AppTheme.methane, 4, false),
          const SizedBox(width: 6),
          Text('Observed plume', style: monoText(10)),
        ],
      ),
    );
  }

  Widget _dot(Color c, double size, bool glow) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c,
          boxShadow: glow
              ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 8)]
              : [],
        ),
      );
}

class _RegionStats extends StatelessWidget {
  final int filtered;
  const _RegionStats({required this.filtered});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.deepSpaceBlack.withOpacity(0.9),
        border: Border.all(color: AppTheme.panelBorder),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('VIEW', style: monoText(9, c: AppTheme.textDim)),
          const SizedBox(height: 4),
          Text('BANGLADESH', style: monoText(11)),
          const SizedBox(height: 2),
          Text('${filtered.toString().padLeft(2, '0')} sources shown',
              style: cinBody(11, c: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.panelBorder),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text('PROTOTYPE — DEMONSTRATION DATA', style: monoText(9, c: AppTheme.textDim)),
    );
  }
}

class _SourceList extends StatelessWidget {
  final List<MethaneSource> sources;
  final ValueChanged<String> onSelectSource;
  final ValueChanged<String> onFilterChanged;
  final String currentFilter;
  const _SourceList({
    required this.sources,
    required this.onSelectSource,
    required this.onFilterChanged,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.deepSpaceBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DETECTED SOURCES', style: monoText(10, c: AppTheme.textDim)),
                Text('${sources.length} TOTAL', style: monoText(10, c: AppTheme.textDim)),
              ],
            ),
          ),
          Container(
            height: 1,
            color: AppTheme.panelBorder,
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sources.length,
              separatorBuilder: (_, __) => Container(
                height: 1,
                color: AppTheme.panelBorder.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              itemBuilder: (context, idx) {
                final s = sources[idx];
                return _SourceListItem(
                  source: s,
                  onTap: () => onSelectSource(s.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceListItem extends StatefulWidget {
  final MethaneSource source;
  final VoidCallback onTap;
  const _SourceListItem({required this.source, required this.onTap});

  @override
  State<_SourceListItem> createState() => _SourceListItemState();
}

class _SourceListItemState extends State<_SourceListItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: _hover ? Colors.white.withOpacity(0.03) : Colors.transparent,
          child: Row(
            children: [

              SizedBox(
                width: 4,
                height: 36,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.methane,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(widget.source.id, style: monoText(11)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.panelBorder),
                            borderRadius: BorderRadius.circular(1),
                          ),
                          child: Text(
                            widget.source.status.toUpperCase(),
                            style: monoText(8,
                                        c: widget.source.status == 'Under investigation'
                                            ? AppTheme.methane
                                            : AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.source.region} · ${widget.source.country}',
                      style: cinBody(11, c: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(widget.source.category, style: monoText(9, c: AppTheme.textDim)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textDim, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
