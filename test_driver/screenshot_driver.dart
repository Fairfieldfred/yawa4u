import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Saves screenshots taken with `binding.takeScreenshot(name)` to
/// `ai_specs/screenshots/baseline/{name}.png`. Used by the UX-audit
/// text-style sweep to capture before/after baselines.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File('ai_specs/screenshots/current/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
