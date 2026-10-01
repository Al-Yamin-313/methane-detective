import 'package:flutter/material.dart';
import '../../theme.dart';
import '../app_data.dart';

class SourcesScreen extends StatefulWidget {
  final String filter;
  final ValueChanged<String> onSelectSource;
  const SourcesScreen({
    super.key,
    required this.filter,
    required this.onSelectSource,
  });

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  String? _hoverId;

  List<MethaneSource> get _filtered {
    if (widget.filter == 'All sources') return AppData.sources;
    return AppData.sources.where((s) => s.category == widget.filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.spaceBlack,
      child: ListView.builder(
        padding: const EdgeInsets.all(32),
        itemCount: _filtered.length,
        itemBuilder: (context, idx) {
          final s = _filtered[idx];
          return _SourceCard(
            source: s,
            hovered: _hoverId == s.id,
            onEnter: () => setState(() => _hoverId = s.id),
            onExit: () => setState(() => _hoverId = null),
            onTap: () => widget.onSelectSource(s.id),
          );
        },
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final MethaneSource source;
  final bool hovered;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onTap;
  const _SourceCard({
    required this.source,
    required this.hovered,
    required this.onEnter,
    required this.onExit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => onEnter(),
        onExit: (_) => onExit(),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: hovered
                  ? AppTheme.panelBg
                  : AppTheme.deepSpaceBlack,
              border: Border.all(
                color: hovered ? AppTheme.methane : AppTheme.panelBorder,
                width: hovered ? 1.2 : 1,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.methane,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(2),
                      bottomLeft: Radius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(source.id, style: monoText(13)),
                                  const SizedBox(width: 10),
                                  _badge(source.status.toUpperCase(),
                                      source.status == 'Under investigation'
                                          ? AppTheme.methane
                                          : AppTheme.accent),
                                  const SizedBox(width: 8),
                                  _badge(source.category.toUpperCase(),
                                      AppTheme.textSecondary),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${source.region}, ${source.country}',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                source.description,
                                style: cinBody(13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _metric('FIRST SEEN', source.firstSeen),
                                  const SizedBox(width: 32),
                                  _metric('LAST SEEN', source.lastSeen),
                                  const SizedBox(width: 32),
                                  _metric('OBSERVATIONS',
                                      source.observations.length.toString()),
                                  const SizedBox(width: 32),
                                  _metric('INTENSITY',
                                      '${(source.intensity * 100).toInt()}%'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: hovered ? AppTheme.methane : AppTheme.textDim, size: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(text, style: monoText(9, c: color)),
      );

  Widget _metric(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: monoText(9, c: AppTheme.textDim)),
          const SizedBox(height: 2),
          Text(value, style: monoText(12, c: AppTheme.textPrimary)),
        ],
      );
}
