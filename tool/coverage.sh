#!/bin/bash
# Generate a filtered code-coverage HTML report.
#
# Usage:
#   bash tool/coverage.sh          # run tests + open report
#   bash tool/coverage.sh --skip   # skip test run, regenerate report from existing lcov.info
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

if [[ "$1" != "--skip" ]]; then
  echo "Running tests with coverage..."
  flutter test --coverage
fi

if ! command -v lcov &>/dev/null; then
  echo "lcov not found. Install with: brew install lcov"
  exit 1
fi

echo "Filtering generated files from coverage..."
lcov --remove coverage/lcov.info \
  '*.g.dart' \
  '*.freezed.dart' \
  'lib/firebase_options.dart' \
  -o coverage/lcov_filtered.info \
  --ignore-errors source,unused

echo "Generating HTML report..."
genhtml coverage/lcov_filtered.info \
  -o coverage/html \
  --ignore-errors source

echo ""
echo "Coverage report: coverage/html/index.html"

# Open in browser (macOS)
if command -v open &>/dev/null; then
  open coverage/html/index.html
fi
