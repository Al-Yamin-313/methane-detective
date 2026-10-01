import 'package:flutter/material.dart';

class SourceObservation {
  final String date;
  final double value;
  final String note;
  final String satellite;
  SourceObservation(this.date, this.value, this.note, this.satellite);
}

class MethaneSource {
  final String id;
  final String region;
  final String country;
  final double lat;
  final double lon;
  final String category;
  final String status;
  final double intensity;
  final String firstSeen;
  final String lastSeen;
  final List<SourceObservation> observations;
  final String description;

  MethaneSource({
    required this.id,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
    required this.category,
    required this.status,
    required this.intensity,
    required this.firstSeen,
    required this.lastSeen,
    required this.observations,
    required this.description,
  });
}

class AppData {
  static final List<MethaneSource> sources = [
    MethaneSource(
      id: 'BD-SYL-014',
      region: 'Sylhet',
      country: 'Bangladesh',
      lat: 24.90,
      lon: 91.87,
      category: 'Gas infrastructure',
      status: 'Under investigation',
      intensity: 1.0,
      firstSeen: 'JAN 2025',
      lastSeen: 'JUN 2026',
      description:
          'Detected methane plume over a suspected gas infrastructure cluster in northeastern Bangladesh. Multiple repeat observations indicate a sustained emission signature.',
      observations: [
        SourceObservation('JAN 2025', 42, 'First detection', 'TROPOMI'),
        SourceObservation('APR 2025', 48, 'Follow-up scan', 'TROPOMI'),
        SourceObservation('JUL 2025', 61, 'Plume signature', 'EMIT'),
        SourceObservation('OCT 2025', 73, 'Continued increase', 'EMIT'),
        SourceObservation('JAN 2026', 85, 'Rising trend', 'TROPOMI'),
        SourceObservation('APR 2026', 96, 'Consistent pattern', 'EMIT'),
        SourceObservation('JUN 2026', 108, 'Latest observation', 'TROPOMI'),
      ],
    ),
    MethaneSource(
      id: 'BD-SYL-007',
      region: 'Sylhet',
      country: 'Bangladesh',
      lat: 24.71,
      lon: 91.45,
      category: 'Rice agriculture',
      status: 'Observed',
      intensity: 0.7,
      firstSeen: 'MAR 2024',
      lastSeen: 'MAY 2026',
      description:
          'Rice paddy region with seasonal methane signatures correlated to agricultural cycles.',
      observations: [
        SourceObservation('MAR 2024', 30, 'Seasonal baseline', 'TROPOMI'),
        SourceObservation('JUL 2024', 55, 'Mid-season peak', 'TROPOMI'),
        SourceObservation('NOV 2024', 38, 'Post-harvest drop', 'EMIT'),
        SourceObservation('MAR 2025', 32, 'New cycle', 'TROPOMI'),
        SourceObservation('JUL 2025', 58, 'Seasonal peak', 'EMIT'),
        SourceObservation('MAY 2026', 45, 'Current', 'TROPOMI'),
      ],
    ),
    MethaneSource(
      id: 'BD-DHK-022',
      region: 'Dhaka',
      country: 'Bangladesh',
      lat: 23.81,
      lon: 90.41,
      category: 'Urban / Landfill',
      status: 'Observed',
      intensity: 0.55,
      firstSeen: 'FEB 2024',
      lastSeen: 'JUN 2026',
      description:
          'Urban methane signature likely associated with landfill emissions and dense infrastructure.',
      observations: [
        SourceObservation('FEB 2024', 50, 'Initial detection', 'TROPOMI'),
        SourceObservation('AUG 2024', 62, 'Stable signature', 'EMIT'),
        SourceObservation('FEB 2025', 68, 'Slight rise', 'TROPOMI'),
        SourceObservation('AUG 2025', 72, 'Continued', 'EMIT'),
        SourceObservation('FEB 2026', 78, 'Repeating pattern', 'TROPOMI'),
        SourceObservation('JUN 2026', 81, 'Latest', 'EMIT'),
      ],
    ),
    MethaneSource(
      id: 'BD-CHT-009',
      region: 'Chittagong',
      country: 'Bangladesh',
      lat: 22.33,
      lon: 91.83,
      category: 'Gas infrastructure',
      status: 'Under review',
      intensity: 0.45,
      firstSeen: 'MAY 2024',
      lastSeen: 'MAY 2026',
      description:
          'Coastal plume signature detected near port infrastructure. Requires further analysis.',
      observations: [
        SourceObservation('MAY 2024', 35, 'First detection', 'TROPOMI'),
        SourceObservation('NOV 2024', 42, 'Stable', 'EMIT'),
        SourceObservation('MAY 2025', 50, 'Slight increase', 'TROPOMI'),
        SourceObservation('NOV 2025', 53, 'Stable', 'TROPOMI'),
        SourceObservation('MAY 2026', 58, 'Current', 'EMIT'),
      ],
    ),
    MethaneSource(
      id: 'BD-RNG-031',
      region: 'Rangpur',
      country: 'Bangladesh',
      lat: 25.74,
      lon: 89.27,
      category: 'Rice agriculture',
      status: 'Observed',
      intensity: 0.5,
      firstSeen: 'APR 2024',
      lastSeen: 'JUN 2026',
      description:
          'Northern rice belt methane signature — seasonal pattern tied to monsoon cycles.',
      observations: [
        SourceObservation('APR 2024', 28, 'Pre-monsoon', 'TROPOMI'),
        SourceObservation('AUG 2024', 60, 'Monsoon peak', 'EMIT'),
        SourceObservation('DEC 2024', 40, 'Post-monsoon', 'TROPOMI'),
        SourceObservation('APR 2025', 32, 'New cycle', 'TROPOMI'),
        SourceObservation('AUG 2025', 65, 'Peak', 'EMIT'),
        SourceObservation('JUN 2026', 48, 'Current', 'TROPOMI'),
      ],
    ),
  ];

  static const List<String> categoryFilters = [
    'All sources',
    'Gas infrastructure',
    'Rice agriculture',
    'Urban / Landfill',
  ];
}
