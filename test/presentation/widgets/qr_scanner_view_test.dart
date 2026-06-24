import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    test('is false on macOS (desktop falls back to paste)', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(canScanQrWithCamera, isFalse);
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
