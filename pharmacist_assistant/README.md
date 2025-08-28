# Pharmacist Assistant App

A Flutter app to browse and search the Daman Drug Formulary with advanced filters, tiering visualization, and price/savings insights.

## Project Structure

- `lib/` — Flutter source (models, providers, screens, widgets, theme)
- `assets/` — JSON database generated from the Excel file
- `scripts/` — Data conversion utilities
- `pubspec.yaml` — Dependencies and assets

## Prerequisites

- Flutter SDK
- Python 3.11+ (for data conversion)

## Data: Convert Excel to JSON

1. Create virtualenv and install deps (script does this if you followed earlier steps):

```bash
. .venv/bin/activate  # if you have it
```

2. Run the converter:

```bash
python pharmacist_assistant/scripts/xlsx_to_json.py       # full dataset
python pharmacist_assistant/scripts/xlsx_to_json.py 500   # first 500 rows only
```

This writes `assets/drugs.json`.

## Run the App

```bash
flutter pub get
flutter run
```

## Notes

- The conversion script auto-detects header rows and normalizes fields.
- Savings fields `savingsDifference` and `savingsPercent` are computed from public vs pharmacy prices.