import 'package:flutter/material.dart';
import '../../theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.spaceBlack,
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.deepSpaceBlack,
              border: Border.all(color: AppTheme.panelBorder),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('THE PROJECT', style: monoText(10, c: AppTheme.textDim)),
                const SizedBox(height: 16),
                Text(
                  'Methane Detective',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 42,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unmasking Earth’s Invisible Polluters',
                  style: TextStyle(
                    color: AppTheme.methane,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Methane is a short-lived but powerful greenhouse gas. '
                  'Detecting individual methane sources from space is the first step '
                  'toward accountability and effective climate action. Methane Detective '
                  'transforms satellite observations into a clear, traceable evidence trail.',
                  style: cinBody(15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _panel(
                  title: 'WHAT IT DOES',
                  bullets: const [
                    'Detects methane plumes from satellite imagery',
                    'Tracks individual sources across time',
                    'Builds evidence trail through repeat observations',
                    'Makes scientific data accessible to the public',
                  ],
                  icon: Icons.rocket_launch_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _panel(
                  title: 'HOW IT WORKS',
                  bullets: const [
                    '1. Satellites capture hyperspectral imagery',
                    '2. Algorithms flag methane enhancement',
                    '3. Sources are stored with metadata',
                    '4. Trends are computed over time',
                    '5. Evidence is presented visually',
                  ],
                  icon: Icons.science_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _panel(
                  title: 'WHY BANGLADESH',
                  bullets: const [
                    'High source diversity: gas + agriculture',
                    'Strong existing environmental research',
                    'Important methane sources globally',
                    'Region well-covered by satellite passes',
                  ],
                  icon: Icons.public_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.deepSpaceBlack,
              border: Border.all(color: AppTheme.panelBorder),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_outlined, color: AppTheme.success, size: 18),
                const SizedBox(width: 10),
                Text('DATA DISCLAIMER', style: monoText(10)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'This is a frontend concept prototype. Numbers, coordinates, and observations are illustrative '
                    'to communicate the concept. Real satellite analysis requires actual EMIT/TROPOMI processing.',
                    style: cinBody(13, c: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.panelBorder),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                _stat('71', 'SOURCES IN BD'),
                _stat('8', 'OBSERVATIONS AVG'),
                _stat('4', 'CATEGORIES'),
                _stat('2', 'SATELLITES'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String v, String label) => Expanded(
        child: Column(
          children: [
            Text(v,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w200,
                )),
            const SizedBox(height: 4),
            Text(label, style: monoText(10, c: AppTheme.textDim)),
          ],
        ),
      );

  Widget _panel({
    required String title,
    required List<String> bullets,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(icon, color: AppTheme.accent, size: 16),
              const SizedBox(width: 8),
              Text(title, style: monoText(10)),
            ],
          ),
          const SizedBox(height: 14),
          ...bullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.methane,
                        ),
                      ),
                    ),
                    Expanded(child: Text(b, style: cinBody(13))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
