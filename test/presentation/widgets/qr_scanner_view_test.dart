import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/presentation/widgets/macos_qr_scanner.dart';
import 'package:yawa4u/presentation/widgets/qr_scanner_view.dart';

void main() {
  group('canScanQrWithCamera', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('is true on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(canScanQrWithCamera, isTrue);
    });

    test('is true on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(canScanQrWithCamera, isTrue);
    });

    test('is true on macOS (camera_macos-backed scanner)', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(canScanQrWithCamera, isTrue);
    });

    test('is false on Windows (paste fallback only)', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(canScanQrWithCamera, isFalse);
    });
  });

  group('bgraToLuminance', () {
    test('extracts R/G/B from BGRA and computes Rec.601 luma', () {
      // 1x1 pixel, pure red in BGRA byte order [B, G, R, A].
      final src = Uint8List.fromList([0, 0, 255, 255]);
      final lum = bgraToLuminance(src, 1, 1, 4);
      expect(lum, hasLength(1));
      expect(lum[0], (255 * 299) ~/ 1000); // 76
    });

    test('honors row stride padding (bytesPerRow > width*4)', () {
      // 2x2 white image with 4 bytes of row padding per row.
      const width = 2, height = 2, bytesPerRow = 12; // 2*4 + 4 pad
      final src = Uint8List(bytesPerRow * height);
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          final p = y * bytesPerRow + x * 4;
          src[p] = 255; // B
          src[p + 1] = 255; // G
          src[p + 2] = 255; // R
          src[p + 3] = 255; // A
        }
        // bytes [8..11] are padding (left 0) and must be skipped.
      }
      final lum = bgraToLuminance(src, width, height, bytesPerRow);
      expect(lum, hasLength(width * height));
      // White → luma 255 for every pixel; padding must not leak in.
      expect(lum.every((v) => v == 255), isTrue);
    });
  });

  group('showPasteConnectionCodeDialog', () {
    testWidgets('confirm yields the trimmed payload', (tester) async {
      String? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  captured = await showPasteConnectionCodeDialog(
                    context,
                    title: 'Enter code',
                    hint: 'Paste here',
                    confirmLabel: 'Connect',
                    cancelLabel: 'Cancel',
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  payload  ');
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();
      expect(captured, 'payload');
    });

    testWidgets('cancel yields null', (tester) async {
      String? captured = 'sentinel';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  captured = await showPasteConnectionCodeDialog(
                    context,
                    title: 'Enter code',
                    hint: 'Paste here',
                    confirmLabel: 'Connect',
                    cancelLabel: 'Cancel',
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(captured, isNull);
    });
  });
}
