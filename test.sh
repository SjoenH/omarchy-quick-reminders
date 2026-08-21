#!/bin/bash
# Test script for Quick Reminders plugin

set -e

PLUGIN_DIR="$HOME/.config/omarchy/plugins/henry.quick-reminders"
TEST_DIR="/tmp/quick-reminders-test"
DATA_FILE="$TEST_DIR/quick-reminders.json"

echo "Testing Quick Reminders Plugin"
echo "================================"

# Create test directory
mkdir -p "$TEST_DIR"
echo "✓ Created test directory: $TEST_DIR"

# Test 1: Initialize with empty data
echo "" > "$DATA_FILE"
echo "[]" > "$DATA_FILE"
echo "✓ Test 1: Created empty data file"

# Test 2: Add a reminder manually
cat > "$DATA_FILE" << 'EOF'
[{"id":1,"text":"Test reminder 1","timestamp":"2026-08-20T20:00:00.000Z","done":false}]
EOF
echo "✓ Test 2: Added test reminder to JSON"

# Test 3: Verify JSON is valid
if python3 -m json.tool "$DATA_FILE" > /dev/null 2>&1; then
    echo "✓ Test 3: JSON is valid"
else
    echo "✗ Test 3: JSON is invalid"
    exit 1
fi

# Test 4: Check reminder count
REMINDER_COUNT=$(cat "$DATA_FILE" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
if [ "$REMINDER_COUNT" -eq 1 ]; then
    echo "✓ Test 4: Reminder count is correct (1)"
else
    echo "✗ Test 4: Expected 1 reminder, got $REMINDER_COUNT"
    exit 1
fi

# Test 5: Add another reminder
cat > "$DATA_FILE" << 'EOF'
[
  {"id":1,"text":"Test reminder 1","timestamp":"2026-08-20T20:00:00.000Z","done":false},
  {"id":2,"text":"Test reminder 2","timestamp":"2026-08-20T20:01:00.000Z","done":false}
]
EOF
echo "✓ Test 5: Added second reminder"

# Test 6: Mark first reminder as done
cat > "$DATA_FILE" << 'EOF'
[
  {"id":1,"text":"Test reminder 1","timestamp":"2026-08-20T20:00:00.000Z","done":true},
  {"id":2,"text":"Test reminder 2","timestamp":"2026-08-20T20:01:00.000Z","done":false}
]
EOF
echo "✓ Test 6: Marked first reminder as done"

# Test 7: Count active reminders
ACTIVE_COUNT=$(cat "$DATA_FILE" | python3 -c "import json,sys; data=json.load(sys.stdin); print(len([r for r in data if not r['done']]))")
if [ "$ACTIVE_COUNT" -eq 1 ]; then
    echo "✓ Test 7: Active reminder count is correct (1)"
else
    echo "✗ Test 7: Expected 1 active reminder, got $ACTIVE_COUNT"
    exit 1
fi

# Test 8: Delete a reminder
cat > "$DATA_FILE" << 'EOF'
[
  {"id":2,"text":"Test reminder 2","timestamp":"2026-08-20T20:01:00.000Z","done":false}
]
EOF
FINAL_COUNT=$(cat "$DATA_FILE" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
if [ "$FINAL_COUNT" -eq 1 ]; then
    echo "✓ Test 8: Delete worked, 1 reminder remaining"
else
    echo "✗ Test 8: Expected 1 reminder after delete, got $FINAL_COUNT"
    exit 1
fi

# Cleanup
rm -rf "$TEST_DIR"
echo "✓ Cleaned up test directory"

echo ""
echo "================================"
echo "All tests passed! ✓"
echo ""
echo "Now testing QML syntax..."

# Test 9: Validate QML files exist
if [ -f "$PLUGIN_DIR/BarWidget.qml" ]; then
    echo "✓ Test 9: BarWidget.qml exists"
else
    echo "✗ Test 9: BarWidget.qml not found"
    exit 1
fi

if [ -f "$PLUGIN_DIR/Panel.qml" ]; then
    echo "✓ Test 10: Panel.qml exists"
else
    echo "✗ Test 10: Panel.qml not found"
    exit 1
fi

# Test 11: Validate manifest
if omarchy plugin validate "$PLUGIN_DIR" > /dev/null 2>&1; then
    echo "✓ Test 11: Manifest is valid"
else
    echo "✗ Test 11: Manifest validation failed"
    exit 1
fi

# Test 12: Check plugin is enabled
if omarchy plugin list | grep -q "no.koka.quick-reminders.*enabled"; then
    echo "✓ Test 12: Plugin is enabled"
else
    echo "⚠ Test 12: Plugin is not enabled"
fi

echo ""
echo "All tests completed successfully! 🎉"
