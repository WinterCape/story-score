#!/bin/bash
# Run this from the project root to complete store readiness setup.
set -e

echo "=== Step 1: Generate app icons ==="
python3 scripts/generate_icons.py

echo ""
echo "=== Step 2: Install dependencies ==="
flutter pub get

echo ""
echo "=== Step 3: Generate launcher icons ==="
dart run flutter_launcher_icons

echo ""
echo "=== Step 4: Generate splash screen ==="
dart run flutter_native_splash:create

echo ""
echo "=== Done! ==="
echo "All store readiness tasks complete."
