import 'dart:convert';
import 'package:http/http.dart' as http;

class NasaApi {
  static const String _eonetBase = 'https://eonet.gsfc.nasa.gov/api/v3';
  static const String _cmrBase = 'https://cmr.earthdata.nasa.gov/search';

  static const String emitCollectionId = 'C2408758986-POCLOUD';
  static const String emitEnhancementShortName = 'EMITL2BCH4ENH';
  static const String emitPlumeShortName = 'EMITL2BCH4PLM';

  static Future<NasaApiResult> fetchAllEvents({int limit = 50}) async {
    final start = DateTime.now();
    try {
      final uri = Uri.parse('$_eonetBase/events?limit=$limit&status=open');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      if (res.statusCode != 200) {
        return NasaApiResult.error('HTTP ${res.statusCode}');
      }
      final data = json.decode(res.body) as Map<String, dynamic>;
      final events = (data['events'] as List?) ?? [];
      final parsed = events
          .map((e) => NasaEvent.fromJson(e as Map<String, dynamic>))
          .whereType<NasaEvent>()
          .toList();
      return NasaApiResult.success(parsed, elapsed);
    } catch (e) {
      return NasaApiResult.error(e.toString());
    }
  }

  static Future<EmitResult> verifyEmit() async {
    final start = DateTime.now();
    try {
      final uri = Uri.parse(
          '$_cmrBase/granules.json?collection_concept_id=$emitCollectionId&page_size=1');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      if (res.statusCode != 200) {
        return EmitResult.error('HTTP ${res.statusCode}');
      }
      final data = json.decode(res.body) as Map<String, dynamic>;
      final entries = (data['feed']?['entry'] as List?) ?? [];
      return EmitResult.success(
        entries.length > 0,
        elapsed,
        lastEntry: entries.isNotEmpty
            ? (entries.first['title'] as String?) ?? 'EMIT granule'
            : null,
      );
    } catch (e) {
      return EmitResult.error(e.toString());
    }
  }
}

class NasaApiResult {
  final bool ok;
  final List<NasaEvent> events;
  final int elapsedMs;
  final String? error;

  NasaApiResult._({required this.ok, required this.events, required this.elapsedMs, this.error});

  factory NasaApiResult.success(List<NasaEvent> events, int ms) =>
      NasaApiResult._(ok: true, events: events, elapsedMs: ms);

  factory NasaApiResult.error(String e) =>
      NasaApiResult._(ok: false, events: [], elapsedMs: 0, error: e);
}

class EmitResult {
  final bool ok;
  final bool hasData;
  final int elapsedMs;
  final String? lastEntry;
  final String? error;

  EmitResult._({
    required this.ok,
    required this.hasData,
    required this.elapsedMs,
    this.lastEntry,
    this.error,
  });

  factory EmitResult.success(bool has, int ms, {String? lastEntry}) =>
      EmitResult._(ok: true, hasData: has, elapsedMs: ms, lastEntry: lastEntry);

  factory EmitResult.error(String e) =>
      EmitResult._(ok: false, hasData: false, elapsedMs: 0, error: e);
}

class NasaEvent {
  final String id;
  final String title;
  final double? lat;
  final double? lon;
  final String? category;
  final DateTime? date;
  final String? description;

  NasaEvent({
    required this.id,
    required this.title,
    this.lat,
    this.lon,
    this.category,
    this.date,
    this.description,
  });

  static NasaEvent? fromJson(Map<String, dynamic> json) {
    try {
      final geometry = (json['geometry'] as List?)?.firstOrNull;
      if (geometry == null) return null;
      final coords = (geometry['coordinates'] as List?) ?? [];
      if (coords.length < 2) return null;
      final lon = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      final categories = (json['categories'] as List?) ?? [];
      final category = categories.isNotEmpty
          ? (categories.first['title'] as String?)
          : null;
      return NasaEvent(
        id: json['id'] as String,
        title: (json['title'] as String?) ?? 'Unknown event',
        lat: lat,
        lon: lon,
        category: category,
        date: DateTime.tryParse(geometry['date'] as String? ?? ''),
        description: json['description'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}