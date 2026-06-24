import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

/// Full-screen QR scanner used by the WiFi sync / template-share / skin-share
/// screens.
///
/// Wraps `flutter_zxing`'s [ReaderWidget] (zxing-cpp, no GoogleMLKit) with a
/// close button and a prompt label. [onCode] fires exactly once with the
/// decoded QR string; the camera lifecycle is managed by [ReaderWidget].
class QrScannerView extends StatefulWidget {
  const QrScannerView({
    super.key,
    required this.promptText,
    required this.onClose,
    required this.onCode,
  });

  /// Instructional text shown along the bottom of the scanner.
  final String promptText;

  /// Invoked when the user dismisses the scanner via the close button.
  final VoidCallback onClose;

  /// Invoked once with the decoded QR payload (a raw string).
  final ValueChanged<String> onCode;

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  bool _handled = false;

  void _onScan(Code code) {
    if (_handled) return;
    final text = code.text;
    if (text == null || text.isEmpty) return;
    _handled = true;
    widget.onCode(text);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ReaderWidget(
            codeFormat: Format.qrCode,
            showScannerOverlay: true,
            showFlashlight: false,
            showToggleCamera: false,
            showGallery: false,
            lensDirection: CameraLensDirection.back,
            onScan: _onScan,
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
          ),
        ),
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Text(
            widget.promptText,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// Whether the current platform can scan QR codes via the device camera.
///
/// `flutter_zxing` (and the underlying `camera` plugin) support live camera
/// scanning on iOS and Android only. On desktop/web the caller should offer the
/// manual paste fallback ([showPasteConnectionCodeDialog]) instead.
bool get canScanQrWithCamera =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);

/// Prompts the user to paste a connection code (the JSON the host device
/// shows). Returns the trimmed input, or `null` if cancelled or empty.
///
/// This is the camera-free entry point for receiving on desktop/web (and the
/// iOS simulator, which has no camera).
Future<String?> showPasteConnectionCodeDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required String confirmLabel,
  required String cancelLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _PasteCodeDialog(
      title: title,
      hint: hint,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );
}

/// Stateful dialog body so the [TextEditingController] is owned and disposed
/// with the widget lifecycle (avoids "used after disposed" during the close
/// animation).
class _PasteCodeDialog extends StatefulWidget {
  const _PasteCodeDialog({
    required this.title,
    required this.hint,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String hint;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<_PasteCodeDialog> createState() => _PasteCodeDialogState();
}

class _PasteCodeDialogState extends State<_PasteCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = _controller.text.trim();
    Navigator.of(context).pop(value.isEmpty ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        minLines: 1,
        onSubmitted: (_) => _confirm(),
        decoration: InputDecoration(
          hintText: widget.hint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: _confirm,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
