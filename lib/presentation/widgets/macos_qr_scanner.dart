import 'dart:typed_data';

import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

/// Full-screen macOS QR scanner.
///
/// macOS isn't supported by `flutter_zxing`'s camera-backed `ReaderWidget`
/// (the `camera` plugin has no macOS implementation), so this feeds frames from
/// `camera_macos` (pure AVFoundation, no GoogleMLKit) into `flutter_zxing`'s
/// FFI decoder. Same surface as `QrScannerView`: [onCode] fires once with the
/// decoded QR string.
class MacosQrScanner extends StatefulWidget {
  const MacosQrScanner({
    super.key,
    required this.promptText,
    required this.onClose,
    required this.onCode,
  });

  final String promptText;
  final VoidCallback onClose;
  final ValueChanged<String> onCode;

  @override
  State<MacosQrScanner> createState() => _MacosQrScannerState();
}

class _MacosQrScannerState extends State<MacosQrScanner> {
  CameraMacOSController? _controller;
  bool _decoding = false;
  bool _handled = false;
  int _frameCount = 0;

  @override
  void dispose() {
    // Fire-and-forget teardown (dispose can't await).
    _controller?.stopImageStream();
    _controller?.destroy();
    super.dispose();
  }

  void _onCameraInitialized(CameraMacOSController controller) {
    _controller = controller;
    controller.startImageStream(_onFrame);
  }

  Future<void> _onFrame(CameraImageData? image) async {
    if (image == null || _handled || _decoding) return;
    // Throttle: only decode roughly every third frame.
    if (_frameCount++ % 3 != 0) return;
    // Guard against a short/garbled buffer.
    if (image.bytes.length < image.bytesPerRow * image.height) return;

    _decoding = true;
    try {
      final luminance = bgraToLuminance(
        image.bytes,
        image.width,
        image.height,
        image.bytesPerRow,
      );
      final code = zx.readBarcode(
        luminance,
        DecodeParams(
          imageFormat: ImageFormat.lum,
          format: Format.qrCode,
          width: image.width,
          height: image.height,
          tryHarder: true,
          tryRotate: true,
        ),
      );
      final text = code.text;
      if (!_handled && code.isValid && text != null && text.isNotEmpty) {
        _handled = true;
        await _controller?.stopImageStream();
        widget.onCode(text);
      }
    } catch (_) {
      // Ignore per-frame decode failures; the next frame will retry.
    } finally {
      _decoding = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CameraMacOSView(
            fit: BoxFit.cover,
            cameraMode: CameraMacOSMode.video,
            enableAudio: false,
            resolution: PictureResolution.low, // 640x480 — light per-frame work
            onCameraInizialized: _onCameraInitialized,
            onCameraLoading: (_) => const ColoredBox(
              color: Colors.black,
              child: Center(child: CircularProgressIndicator()),
            ),
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

/// Convert a `kCVPixelFormatType_32BGRA` buffer (byte layout B, G, R, A) to a
/// tightly-packed luminance buffer (`width * height` bytes) suitable for
/// `flutter_zxing` with [ImageFormat.lum].
///
/// Honors [bytesPerRow] (AVFoundation may pad each row beyond `width * 4`).
Uint8List bgraToLuminance(
  Uint8List src,
  int width,
  int height,
  int bytesPerRow,
) {
  final out = Uint8List(width * height);
  var o = 0;
  for (var y = 0; y < height; y++) {
    final rowStart = y * bytesPerRow;
    for (var x = 0; x < width; x++) {
      final p = rowStart + x * 4;
      final b = src[p];
      final g = src[p + 1];
      final r = src[p + 2];
      // Rec. 601 luma.
      out[o++] = (r * 299 + g * 587 + b * 114) ~/ 1000;
    }
  }
  return out;
}
