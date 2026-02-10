# Beer Scanner - iOS App

An iOS application that identifies beers by scanning their labels using the device camera. Point your camera at any beer can or bottle, and get comprehensive information including manufacturer details, alcohol content (ABV & promille), flavor profiles, ingredients, and food pairings.

## Features

- **Camera Scanning** - Take a photo or choose from your library to identify a beer
- **Text Recognition** - Uses Apple Vision framework (OCR) to read text from beer labels
- **Barcode Detection** - Also detects barcodes on beer packaging
- **Beer Database** - Built-in database of 20 popular beers from around the world
- **Detailed Information** - For each beer, displays:
  - Alcohol by Volume (ABV)
  - Alcohol content in promille
  - Estimated BAC (Blood Alcohol Content) per serving
  - Manufacturer and country of origin
  - Beer style and IBU (bitterness)
  - Calories per serving
  - Volume
  - Serving temperature
  - Full ingredient list
  - Flavor profile (sweetness, bitterness, body, hoppy, malty)
  - Food pairing suggestions
- **Scan History** - Keeps a log of all previously scanned beers
- **Beer Browser** - Browse and search the full beer database

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Physical device recommended (camera features)

## Architecture

```
BeerScanner/
├── BeerScannerApp.swift              # App entry point
├── Info.plist                         # Camera/Photo permissions
├── Assets.xcassets/                   # App icons and colors
├── Models/
│   ├── Beer.swift                     # Beer data model with ABV/promille/BAC calculations
│   ├── BeerDatabase.swift             # 20-beer database with fuzzy text matching
│   └── ScanHistoryStore.swift         # Persistent scan history (UserDefaults)
├── Services/
│   ├── CameraService.swift            # UIImagePickerController wrapper + permissions
│   ├── ImageRecognitionService.swift   # Vision framework OCR + barcode detection
│   └── BeerLookupService.swift        # Orchestrates recognition → database matching
├── Views/
│   ├── ContentView.swift              # Main tab view (Scan, Beers, History)
│   ├── CameraView.swift               # Live camera with AVCaptureSession
│   ├── ScanResultView.swift           # Scan results with confidence score
│   ├── BeerDetailView.swift           # Full beer detail page
│   ├── HistoryView.swift              # Scan history list
│   └── Components/
│       ├── BeerInfoCard.swift         # Reusable beer info card
│       └── StatBadge.swift            # Stat display badge
└── Extensions/
    └── Color+Theme.swift              # App theme colors (beer gold/amber)
```

## How It Works

1. **Capture** - User takes a photo or selects one from their library
2. **Recognize** - Vision framework extracts text and barcodes from the image
3. **Match** - Recognized text is matched against the beer database using weighted scoring:
   - Brand name match: 50 points
   - Beer name words: 20 points each
   - Manufacturer words: 15 points each
   - ABV match: 15 points
   - Style match: 10 points
   - Country match: 5 points
4. **Display** - Matched beer details are shown with a confidence percentage

## Beers in Database

| Beer | Style | ABV | Promille | Country |
|------|-------|-----|----------|---------|
| Heineken Lager | Pale Lager | 5.0% | 50‰ | Netherlands |
| Guinness Draught | Irish Dry Stout | 4.2% | 42‰ | Ireland |
| Corona Extra | Pale Lager | 4.5% | 45‰ | Mexico |
| Budweiser | American Lager | 5.0% | 50‰ | United States |
| Stella Artois | Belgian Pilsner | 5.2% | 52‰ | Belgium |
| Carlsberg Pilsner | Pilsner | 5.0% | 50‰ | Denmark |
| BrewDog Punk IPA | IPA | 5.4% | 54‰ | Scotland |
| Weihenstephaner | Hefeweizen | 5.4% | 54‰ | Germany |
| Pilsner Urquell | Czech Pilsner | 4.4% | 44‰ | Czech Republic |
| Sapporo Premium | Japanese Rice Lager | 4.9% | 49‰ | Japan |
| Chimay Blue | Belgian Strong Dark | 9.0% | 90‰ | Belgium |
| Peroni Nastro Azzurro | Italian Pilsner | 5.1% | 51‰ | Italy |
| Duvel | Belgian Strong Golden | 8.5% | 85‰ | Belgium |
| Asahi Super Dry | Japanese Dry Lager | 5.0% | 50‰ | Japan |
| Leffe Blonde | Belgian Blonde | 6.6% | 66‰ | Belgium |
| Sierra Nevada Pale Ale | American Pale Ale | 5.6% | 56‰ | United States |
| Hoegaarden White | Witbier | 4.9% | 49‰ | Belgium |
| Erdinger Weissbier | Hefeweizen | 5.3% | 53‰ | Germany |
| Tiger Beer | Pale Lager | 5.0% | 50‰ | Singapore |
| Paulaner Salvator | Doppelbock | 7.9% | 79‰ | Germany |

## Screenshots

Open the HTML files in `Screenshots/` folder in any browser to see realistic iPhone mockups:

- `01_home_screen.html` - Main scanner screen with camera/library buttons
- `02_scan_result.html` - Scan result showing identified Heineken with all stats
- `03_beer_detail.html` - Full beer detail page for Guinness Draught
- `04_beer_list.html` - Searchable beer database browser
- `05_scan_history.html` - History of previously scanned beers

## Building

1. Open `BeerScanner.xcodeproj` in Xcode 15+
2. Select your development team for code signing
3. Build and run on a physical iOS device (camera required for scanning)

## Extending the Database

To add more beers, edit `BeerDatabase.swift` and add new `Beer` entries to the `beers` array. Each beer requires: name, brand, manufacturer, country, style, ABV, IBU, volume, calories, ingredients, description, flavor profile, serving temperature, and food pairings.
