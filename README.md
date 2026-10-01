# Methane Detective

**NASA Space Apps Challenge · 2026**

> Unmasking Earth's Invisible Polluters

> **Status: PROTOTYPE** — This is a frontend demonstration prototype built for the NASA Space Apps Challenge 2026. Source markers, observation values, and trend curves use a curated demonstration dataset. The application showcases the analysis-layer workflow (observation → source case file → trend evidence) rather than running real hyperspectral retrievals on raw satellite imagery.

Methane Detective is an interactive investigation platform that turns satellite-derived methane-plume observations into a traceable evidence trail. The prototype demonstrates how individual sources can be selected, followed across time, and turned into trend-based evidence that is accessible to non-scientists.

The application was built in response to the **Earth System Trend Detective** challenge of the NASA Space Apps 2026.

---

## Features

- **Interactive Bangladesh map** with detected methane sources and region highlighting (Sylhet, Dhaka, Chittagong, Rangpur)
- **Filterable source index** by category: gas infrastructure, rice agriculture, urban / landfill
- **Source case files** showing location, satellite sources (TROPOMI Sentinel-5P, EMIT ISS), and full observation history
- **Trend analysis** with animated observation-to-trend morphing, hover-tooltips, and statistical summary
- **Live NASA API status panel** in the top bar showing real-time connection state for EMIT methane products and EONET events
- **Full evidence trail UI**: Observation → Trend → Evidence
- **Scientifically credible language**: "detected source", "observed plume", "evidence under investigation" — never claims confirmed attribution

---

## NASA API Integration

The application includes a backend layer (`lib/app/nasa_api.dart`) that calls:

- **NASA EONET v3** — `https://eonet.gsfc.nasa.gov/api/v3/events` (open natural-event tracking)
- **NASA CMR (Common Metadata Repository)** — `https://cmr.earthdata.nasa.gov/search/granules.json` for the EMIT methane products:
  - `EMITL2BCH4ENH` — EMIT L2B Methane Enhancement
  - `EMITL2BCH4PLM` — EMIT L2B Estimated Methane Plume Complexes
  - Collection concept ID: `C2408758986-POCLOUD`

All endpoints are public. A status panel in the top-right of every screen reflects the current connection state for each NASA data source and offers a RE-PING control. If a request fails, the application gracefully falls back to the curated demonstration dataset so the prototype always works.

---

## Project Structure

```
lib/
├── main.dart                     # MaterialApp entry point
├── theme.dart                    # NASA Earth-observation palette + Orbitron/Inter/Share Tech Mono fonts
└── app/
        ├── app_data.dart         # Simulated methane sources (5 BD sources with full observation history)
        ├── nasa_api.dart         # EONET + CMR (EMIT) integration with offline fallback
        ├── app_shell.dart        # Sidebar + topbar + screen router + floating NASA status panel
        └── screens/
            ├── screen_map.dart           # Interactive Bangladesh map
            ├── screen_sources.dart       # Source list / detail cards
            ├── screen_casefile.dart       # Per-source investigation page
            ├── screen_trend.dart         # Animated trend analysis
            └── screen_about.dart         # Project overview & disclaimer
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.12+ (`flutter --version`)
- Dart 3.0+

### Install & Run

```bash
flutter pub get
flutter run -d chrome
```

### Build for Web

```bash
flutter build web --release
```

The compiled web app is in `build/web/` — drop the folder onto Netlify, Surge, GitHub Pages, or any static host.

### Run the live demo locally

```bash
cd build/web
python -m http.server 8000
```

Then open <http://localhost:8000/> in your browser.

---

## Tech Stack

- **Flutter** (Dart) — single-codebase web target
- **http** package — REST client
- **google_fonts** — Orbitron (display), Inter (body), Share Tech Mono (labels)

---

## Disclaimer

This is a **frontend prototype**. Source markers, observation values, and trend curves use a curated demonstration dataset. Real satellite analysis requires downloading and processing raw hyperspectral imagery (TROPOMI / EMIT / GHGSat) using source-specific retrieval algorithms.

The contribution of this prototype is the **analysis layer** that organizes plume observations into source histories and trends.

---

## Team

Built for **NASA Space Apps Challenge 2026**.

---

## License

MIT — feel free to fork and extend.
