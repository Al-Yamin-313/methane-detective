import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'app_data.dart';
import 'nasa_api.dart';
import 'screens/screen_map.dart';
import 'screens/screen_sources.dart';
import 'screens/screen_casefile.dart';
import 'screens/screen_trend.dart';
import 'screens/screen_about.dart';

enum AppScreen { map, sources, caseFile, trend, about }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppScreen _current = AppScreen.map;
  String? _selectedSourceId;
  String _filter = 'All sources';
  bool _hoverSource = false;

  bool _nasaLoading = false;
  bool _nasaExpanded = false;
  NasaApiResult? _nasaResult;
  EmitResult? _nasaEmit;
  DateTime? _nasaLastFetched;

  bool get _nasaApiOnline =>
      _nasaResult?.ok == true && (_nasaResult?.events.isNotEmpty ?? false);
  int get _nasaEventCount => _nasaResult?.events.length ?? 0;

  @override
  void initState() {
    super.initState();
    _nasaRefresh();
  }

  Future<void> _nasaRefresh() async {
    if (_nasaLoading) return;
    setState(() => _nasaLoading = true);
    final results = await Future.wait([
      NasaApi.fetchAllEvents(),
      NasaApi.verifyEmit(),
    ]);
    if (!mounted) return;
    setState(() {
      _nasaLoading = false;
      _nasaResult = results[0] as NasaApiResult;
      _nasaEmit = results[1] as EmitResult;
      _nasaLastFetched = DateTime.now();
    });
  }

  void _toggleNasaPanel() {
    setState(() => _nasaExpanded = !_nasaExpanded);
  }

  void _closeNasaPanel() {
    setState(() => _nasaExpanded = false);
  }

  MethaneSource? get _selectedSource {
    if (_selectedSourceId == null) return null;
    try {
      return AppData.sources.firstWhere((s) => s.id == _selectedSourceId);
    } catch (_) {
      return null;
    }
  }

  void _selectSource(String id) {
    setState(() {
      _selectedSourceId = id;
      _current = AppScreen.caseFile;
    });
  }

  void _go(AppScreen s) {
    setState(() {
      _current = s;
      if (s != AppScreen.caseFile) _selectedSourceId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.spaceBlack,
      body: Stack(
        children: [
          Row(
            children: [
              _Sidebar(
                current: _current,
                onNavigate: _go,
              ),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(
                      current: _current,
                      onFilterChanged: (f) => setState(() => _filter = f),
                      filter: _filter,
                      loading: _nasaLoading,
                      apiOnline: _nasaApiOnline,
                      eventCount: _nasaEventCount,
                      expanded: _nasaExpanded,
                      onNasaToggle: _toggleNasaPanel,
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.02),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: _buildScreen(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_nasaExpanded)
            Positioned(
              top: 90,
              right: 24,
              child: Material(
                color: Colors.transparent,
                elevation: 32,
                shadowColor: Colors.black,
                child: _StatusPanel(
                  result: _nasaResult,
                  emit: _nasaEmit,
                  loading: _nasaLoading,
                  lastFetched: _nasaLastFetched,
                  onRefresh: _nasaRefresh,
                  onClose: _closeNasaPanel,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    switch (_current) {
      case AppScreen.map:
        return MapScreen(
          key: const ValueKey('map'),
          filter: _filter,
          onSelectSource: _selectSource,
          onFilterChanged: (f) => setState(() => _filter = f),
        );
      case AppScreen.sources:
        return SourcesScreen(
          key: const ValueKey('sources'),
          filter: _filter,
          onSelectSource: _selectSource,
        );
      case AppScreen.caseFile:
        final s = _selectedSource;
        if (s == null) {
          return const _KeyedPlaceholder('No source selected');
        }
        return CaseFileScreen(
          key: ValueKey('case-${s.id}'),
          source: s,
          onViewTrend: () => setState(() => _current = AppScreen.trend),
        );
      case AppScreen.trend:
        final s = _selectedSource;
        if (s == null) {
          return const _KeyedPlaceholder('Select a source to view trend');
        }
        return TrendScreen(
          key: ValueKey('trend-${s.id}'),
          source: s,
        );
      case AppScreen.about:
        return const AboutScreen(key: ValueKey('about'));
    }
  }
}

class _KeyedPlaceholder extends StatelessWidget {
  final String text;
  const _KeyedPlaceholder(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('placeholder'),
      color: AppTheme.deepSpaceBlack,
      alignment: Alignment.center,
      child: Text(text, style: cinBody(16)),
    );
  }
}

class _Sidebar extends StatefulWidget {
  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;
  const _Sidebar({required this.current, required this.onNavigate});

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  int? _hovered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF060A14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.methane, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.methane.withOpacity(0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.methane,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'METHANE',
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: Text(
                    'DETECTIVE',
                    style: GoogleFonts.inter(
                      color: AppTheme.textDim,
                      fontSize: 11,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: Text(
                    'SPACE APPS  ·  2026',
                    style: GoogleFonts.shareTechMono(
                      color: AppTheme.methane,
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ],
            ),
          ),
          Container(
            height: 1,
            color: AppTheme.panelBorder,
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              'INVESTIGATION',
              style: monoText(10, c: AppTheme.textDim),
            ),
          ),
          _navItem(0, AppScreen.map, Icons.public_outlined, 'Map'),
          _navItem(1, AppScreen.sources, Icons.list_alt_outlined, 'Sources'),
          _navItem(2, AppScreen.caseFile, Icons.folder_outlined, 'Case File'),
          _navItem(3, AppScreen.trend, Icons.show_chart, 'Trend'),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              'ABOUT',
              style: monoText(10, c: AppTheme.textDim),
            ),
          ),
          _navItem(4, AppScreen.about, Icons.info_outline, 'Project'),
          const Spacer(),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.panelBorder)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 8),
                Text('SYSTEM ONLINE', style: monoText(9, c: AppTheme.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int idx, AppScreen screen, IconData icon, String label) {
    final active = widget.current == screen;
    final hovered = _hovered == idx;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = idx),
      onExit: (_) => setState(() => _hovered = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onNavigate(screen),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.methane.withOpacity(0.08)
                : hovered
                        ? Colors.white.withOpacity(0.03)
                        : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: active ? AppTheme.methane : Colors.transparent,
                width: 2,
              ),
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: active
                    ? AppTheme.methane
                    : hovered
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: active
                      ? AppTheme.textPrimary
                      : hovered
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final AppScreen current;
  final String filter;
  final ValueChanged<String> onFilterChanged;
  final bool loading;
  final bool apiOnline;
  final int eventCount;
  final bool expanded;
  final VoidCallback onNasaToggle;
  const _TopBar({
    required this.current,
    required this.filter,
    required this.onFilterChanged,
    required this.loading,
    required this.apiOnline,
    required this.eventCount,
    required this.expanded,
    required this.onNasaToggle,
  });

  String get _title {
    switch (current) {
      case AppScreen.map:
        return 'INVESTIGATE METHANE SOURCES';
      case AppScreen.sources:
        return 'SOURCE INDEX';
      case AppScreen.caseFile:
        return 'SOURCE CASE FILE';
      case AppScreen.trend:
        return 'TREND ANALYSIS';
      case AppScreen.about:
        return 'PROJECT OVERVIEW';
    }
  }

  String get _subtitle {
    switch (current) {
      case AppScreen.map:
        return 'Explore detected emission sources and their observed history.';
      case AppScreen.sources:
        return 'Complete list of detected methane sources in the region.';
      case AppScreen.caseFile:
        return 'Detailed evidence trail for the selected methane source.';
      case AppScreen.trend:
        return 'Temporal observation analysis and trend detection.';
      case AppScreen.about:
        return 'About the Methane Detective project and team.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final showFilter = current == AppScreen.map || current == AppScreen.sources;
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
      decoration: BoxDecoration(
        color: AppTheme.deepSpaceBlack,
        border: Border(
          bottom: BorderSide(color: AppTheme.panelBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: cinTitle(22),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle,
                  style: cinBody(13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (showFilter)
            _FilterChipBar(
              filter: filter,
              onFilterChanged: onFilterChanged,
            ),
          const SizedBox(width: 12),
          _liveIndicator(),
          const SizedBox(width: 12),
          _searchBox(),
        ],
      ),
    );
  }

  Widget _liveIndicator() {
    final color = loading
        ? AppTheme.warning
        : (apiOnline ? AppTheme.success : AppTheme.textDim);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onNasaToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.6), width: 1.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: [
              if (loading)
                SizedBox(
                  width: 11,
                  height: 11,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                )
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.6), blurRadius: 6),
                    ],
                  ),
                ),
              const SizedBox(width: 10),
              Text(
                'NASA',
                style: monoText(11, c: AppTheme.textPrimary),
              ),
              const SizedBox(width: 8),
              Text(
                loading ? 'PINGING...' : (apiOnline ? 'LIVE' : 'OFFLINE'),
                style: monoText(10, c: color),
              ),
              if (apiOnline) ...[
                const SizedBox(width: 6),
                Text('· $eventCount',
                    style: monoText(10, c: AppTheme.textDim)),
              ],
              const SizedBox(width: 8),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                size: 14,
                color: AppTheme.textDim,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      width: 240,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.panelBg,
        border: Border.all(color: AppTheme.panelBorder),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 14, color: AppTheme.textDim),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search source ID',
              style: cinBody(12, c: AppTheme.textDim),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.panelBorder),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text('⌘ K', style: monoText(9, c: AppTheme.textDim)),
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final NasaApiResult? result;
  final EmitResult? emit;
  final bool loading;
  final DateTime? lastFetched;
  final VoidCallback onRefresh;
  final VoidCallback onClose;
  const _StatusPanel({
    required this.result,
    required this.emit,
    required this.loading,
    required this.lastFetched,
    required this.onRefresh,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: AppTheme.deepSpaceBlack,
        border: Border.all(color: AppTheme.panelBorder),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.panelBorder)),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_done_outlined, color: AppTheme.accent, size: 14),
                const SizedBox(width: 8),
                Text('NASA DATA STATUS', style: monoText(10)),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, size: 14, color: AppTheme.textDim),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(
                  label: 'EMIT Methane Enhancement',
                  endpoint: 'CMR · ' + NasaApi.emitEnhancementShortName,
                  online: emit?.ok == true && emit?.hasData == true,
                  detail: emit?.lastEntry,
                  elapsed: emit?.elapsedMs,
                ),
                const SizedBox(height: 10),
                _row(
                  label: 'EMIT Plume Complexes',
                  endpoint: 'CMR · ' + NasaApi.emitPlumeShortName,
                  online: emit?.ok == true,
                  detail: emit?.ok == true ? 'collection indexed' : null,
                  elapsed: emit?.elapsedMs,
                ),
                const SizedBox(height: 10),
                _row(
                  label: 'NASA EONET Events',
                  endpoint: 'eonet.gsfc.nasa.gov/v3',
                  online: result?.ok == true,
                  detail: result?.ok == true
                      ? '${result!.events.length} open events'
                      : result?.error,
                  elapsed: result?.elapsedMs,
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: AppTheme.panelBorder,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (lastFetched != null)
                      Expanded(
                        child: Text(
                          'Last ping: ${_fmt(lastFetched!)}',
                          style: monoText(9, c: AppTheme.textDim),
                        ),
                      ),
                    GestureDetector(
                      onTap: loading ? null : onRefresh,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: loading
                              ? AppTheme.textDim.withOpacity(0.1)
                              : AppTheme.accent.withOpacity(0.15),
                          border: Border.all(
                            color: loading ? AppTheme.textDim : AppTheme.accent,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (loading)
                              SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor:
                                      AlwaysStoppedAnimation(AppTheme.textDim),
                                ),
                              )
                            else
                              Icon(Icons.refresh, size: 12, color: AppTheme.accent),
                            const SizedBox(width: 6),
                            Text('RE-PING', style: monoText(9, c: AppTheme.accent)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row({
    required String label,
    required String endpoint,
    required bool online,
    String? detail,
    int? elapsed,
  }) {
    final color = online ? AppTheme.success : AppTheme.textDim;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: online
                ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)]
                : [],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: monoText(11, c: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(endpoint, style: monoText(9, c: AppTheme.textDim)),
              if (detail != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(detail,
                      style: monoText(9, c: color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
            ],
          ),
        ),
        if (elapsed != null && elapsed > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 8),
            child: Text('${elapsed}ms',
                style: monoText(9, c: AppTheme.textDim)),
          ),
      ],
    );
  }

  String _fmt(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _FilterChipBar extends StatelessWidget {
  final String filter;
  final ValueChanged<String> onFilterChanged;
  const _FilterChipBar({required this.filter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppData.categoryFilters.map((f) {
        final selected = f == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onFilterChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.accent.withOpacity(0.15)
                      : AppTheme.panelBg,
                  border: Border.all(
                    color: selected ? AppTheme.accent : AppTheme.panelBorder,
                    width: selected ? 1.2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  children: [
                    if (selected) ...[
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      f.toUpperCase(),
                      style: monoText(10,
                                  c: selected ? AppTheme.textPrimary : AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
