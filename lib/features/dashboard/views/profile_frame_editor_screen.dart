import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

/// Full-screen face-in-frame editor.
///
/// Flow:
///  1. User's photo bytes are passed in.
///  2. ML Kit detects the face → auto-positions it inside the transparent
///     cutout of the LabourSampark frame template.
///  3. User can drag / pinch-to-scale to fine-tune.
///  4. Tap "Use Photo" → composites layers at 3× resolution → returns PNG.
class ProfileFrameEditorScreen extends StatefulWidget {
  final Uint8List userPhotoBytes;

  const ProfileFrameEditorScreen({super.key, required this.userPhotoBytes});

  static Future<Uint8List?> show(BuildContext context, Uint8List photoBytes) =>
      Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) =>
              ProfileFrameEditorScreen(userPhotoBytes: photoBytes),
        ),
      );

  @override
  State<ProfileFrameEditorScreen> createState() =>
      _ProfileFrameEditorScreenState();
}

class _ProfileFrameEditorScreenState
    extends State<ProfileFrameEditorScreen> {
  ui.Image? _userImage;
  ui.Image? _processedFrame; // Frame with white cutout made transparent
  bool _loading = true;
  bool _exporting = false;
  String? _loadError;

  // Drag / scale state
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _scaleStartFocal = Offset.zero;
  Offset _scaleStartOffset = Offset.zero;
  double _scaleStartScale = 1.0;

  // ML Kit result (in image-pixel coordinates)
  Rect? _faceBounds;
  bool _autoPositionApplied = false;

  final GlobalKey _repaintKey = GlobalKey();

  // ── Hole constants (fraction of displayed frame size) ─────────────────────
  // These describe the centre and radius of the face cutout in the template.
  static const double _holeCxFrac = 0.500; // horizontal centre
  static const double _holeCyFrac = 0.370; // vertical centre (below hat brim)
  static const double _holeRFrac  = 0.210; // radius as fraction of width

  // ── Init ──────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      // 1. Decode user photo
      final userCodec =
          await ui.instantiateImageCodec(widget.userPhotoBytes);
      final userImg = (await userCodec.getNextFrame()).image;

      // 2. Detect face (best-effort; falls back to manual positioning)
      final faceRect = await _detectFace(widget.userPhotoBytes);

      // 3. Load frame asset → convert white cutout to transparent
      ui.Image? processedFrame;
      try {
        final assetData =
            await rootBundle.load('assets/images/profile_frame.jpg');
        final rawCodec = await ui
            .instantiateImageCodec(assetData.buffer.asUint8List());
        final rawFrame = (await rawCodec.getNextFrame()).image;
        processedFrame = await _makeTransparentFrame(rawFrame);
      } catch (_) {
        // Frame asset unavailable — editor still works without it
      }

      if (mounted) {
        setState(() {
          _userImage = userImg;
          _processedFrame = processedFrame;
          _faceBounds = faceRect;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  // ── ML Kit face detection ─────────────────────────────────────────────────

  Future<Rect?> _detectFace(Uint8List bytes) async {
    File? tempFile;
    FaceDetector? detector;
    try {
      final dir = await getTemporaryDirectory();
      tempFile = File(
          '${dir.path}/ls_face_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(bytes);

      detector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
        ),
      );

      final faces = await detector
          .processImage(InputImage.fromFilePath(tempFile.path));

      if (faces.isEmpty) return null;

      // Pick the largest face (most prominent)
      faces.sort((a, b) =>
          (b.boundingBox.width * b.boundingBox.height)
              .compareTo(a.boundingBox.width * a.boundingBox.height));
      return faces.first.boundingBox;
    } catch (_) {
      return null;
    } finally {
      try { await detector?.close(); } catch (_) {}
      try { await tempFile?.delete(); } catch (_) {}
    }
  }

  // ── White-to-transparent frame processing ─────────────────────────────────

  Future<ui.Image> _makeTransparentFrame(ui.Image frame) async {
    final byteData =
        await frame.toByteData(format: ui.ImageByteFormat.rawRgba);
    final pixels = Uint8List.fromList(byteData!.buffer.asUint8List());

    for (int i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      // Average brightness — only convert near-white pixels from the cutout
      final brightness = (r + g + b) ~/ 3;

      if (r > 200 && g > 200 && b > 200 && brightness > 210) {
        // Pure white → fully transparent (the face cutout area)
        pixels[i + 3] = 0;
      } else if (r > 170 && g > 170 && b > 170 && brightness > 180) {
        // Soft edge → partial transparency for smooth anti-aliasing
        final t = (brightness - 180) / (210 - 180);
        pixels[i + 3] = ((1.0 - t) * 255).round().clamp(0, 255);
      }
    }

    final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: frame.width,
      height: frame.height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    return (await codec.getNextFrame()).image;
  }

  // ── Auto-position face into hole ──────────────────────────────────────────

  void _applyAutoPosition(Rect face, double frameW, double frameH) {
    final imgW = _userImage!.width.toDouble();
    final imgH = _userImage!.height.toDouble();

    // Scale at which RawImage (BoxFit.cover) maps image pixels to screen
    final coverScale = math.max(frameW / imgW, frameH / imgH);

    // Face centre in screen-space at default (scale=1, offset=0)
    final faceCx = face.center.dx * coverScale +
        (frameW - imgW * coverScale) / 2;
    final faceCy = face.center.dy * coverScale +
        (frameH - imgH * coverScale) / 2;

    // Hole centre & radius in frame display coordinates
    final holeCx = frameW * _holeCxFrac;
    final holeCy = frameH * _holeCyFrac;
    final holeR = frameW * _holeRFrac;

    // Scale so face height ≈ hole diameter × 1.3 (includes forehead/chin)
    final faceHOnScreen = face.height * coverScale;
    final autoScale =
        ((holeR * 2.6) / faceHOnScreen).clamp(0.5, 6.0);

    // After Transform.scale(autoScale) from frame centre, face centre lands at:
    final scaledFaceCx =
        (faceCx - frameW / 2) * autoScale + frameW / 2;
    final scaledFaceCy =
        (faceCy - frameH / 2) * autoScale + frameH / 2;

    // Offset to move scaled face centre onto hole centre
    setState(() {
      _scale = autoScale;
      _offset = Offset(holeCx - scaledFaceCx, holeCy - scaledFaceCy);
    });
  }

  // ── Gesture handlers ──────────────────────────────────────────────────────

  void _onScaleStart(ScaleStartDetails d) {
    _scaleStartFocal = d.focalPoint;
    _scaleStartOffset = _offset;
    _scaleStartScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _scale = (_scaleStartScale * d.scale).clamp(0.3, 8.0);
      _offset = _scaleStartOffset + (d.focalPoint - _scaleStartFocal);
    });
  }

  // ── Export ────────────────────────────────────────────────────────────────

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      if (mounted) Navigator.of(context).pop(bytes);
    } catch (_) {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        title: const Text(
          'Position Your Face',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17),
        ),
        actions: [
          if (!_loading)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _exporting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : FilledButton(
                      onPressed: _export,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      child: const Text('Use Photo'),
                    ),
            ),
        ],
      ),
      body: _loading
          ? _buildLoading()
          : _loadError != null
              ? _buildError()
              : _buildEditor(),
    );
  }

  Widget _buildLoading() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Detecting face…',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14),
            ),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load image.\n$_loadError',
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      );

  Widget _buildEditor() {
    return Column(
      children: [
        Expanded(child: Center(child: _buildFrameArea())),
        _buildHint(),
      ],
    );
  }

  Widget _buildFrameArea() {
    return LayoutBuilder(builder: (context, constraints) {
      final maxW = constraints.maxWidth;
      final maxH = constraints.maxHeight;

      // Match frame's natural aspect ratio (3:4 portrait default)
      final frameAspect = _processedFrame != null
          ? _processedFrame!.width / _processedFrame!.height
          : 3.0 / 4.0;

      double frameW = maxW;
      double frameH = frameW / frameAspect;
      if (frameH > maxH) {
        frameH = maxH;
        frameW = frameH * frameAspect;
      }

      // Auto-position once after the first layout is complete
      if (_faceBounds != null && !_autoPositionApplied) {
        _autoPositionApplied = true;
        Future.microtask(() {
          if (mounted) _applyAutoPosition(_faceBounds!, frameW, frameH);
        });
      }

      final holeCx = frameW * _holeCxFrac;
      final holeCy = frameH * _holeCyFrac;
      final holeR = frameW * _holeRFrac;

      return SizedBox(
        width: frameW,
        height: frameH,
        child: GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Exported composite (RepaintBoundary) ───────────────
              RepaintBoundary(
                key: _repaintKey,
                child: ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Black background
                      Container(color: Colors.black),

                      // 2. User photo — draggable / scalable
                      Transform.translate(
                        offset: _offset,
                        child: Transform.scale(
                          scale: _scale,
                          child: _userImage != null
                              ? SizedBox.expand(
                                  child: RawImage(
                                    image: _userImage,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ),

                      // 3. Frame overlay (transparent where face goes)
                      if (_processedFrame != null)
                        CustomPaint(
                          painter: _FramePainter(
                              frame: _processedFrame!),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Guide circle (screen only — NOT exported) ──────────
              IgnorePointer(
                child: CustomPaint(
                  painter: _HoleGuidePainter(
                    center: Offset(holeCx, holeCy),
                    radius: holeR,
                    hasFace: _faceBounds != null,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHint() {
    final faceFound = _faceBounds != null;
    return Container(
      color: Colors.black,
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, MediaQuery.of(context).padding.bottom + 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            faceFound
                ? Icons.face_retouching_natural
                : Icons.touch_app_rounded,
            size: 16,
            color: faceFound
                ? const Color(0xFF34D399)
                : Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            faceFound
                ? 'Face auto-detected — drag to fine-tune'
                : 'Drag & pinch to position your face in the circle',
            style: TextStyle(
              fontSize: 13,
              color: faceFound
                  ? const Color(0xFF34D399)
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

/// Draws the processed frame (white cutout is now transparent alpha).
class _FramePainter extends CustomPainter {
  final ui.Image frame;
  const _FramePainter({required this.frame});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      frame,
      Rect.fromLTWH(
          0, 0, frame.width.toDouble(), frame.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.frame != frame;
}

/// Dashed circle guide — shown on screen only, NOT inside the RepaintBoundary
/// used for export, so it does NOT appear in the saved photo.
class _HoleGuidePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final bool hasFace;

  const _HoleGuidePainter({
    required this.center,
    required this.radius,
    required this.hasFace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = hasFace
          ? const Color(0xFF34D399).withValues(alpha: 0.85)
          : Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const segments = 28;
    const gapFrac = 0.35;
    const fullAngle = 2 * math.pi;

    for (int i = 0; i < segments; i++) {
      final start = i * fullAngle / segments;
      final sweep = (fullAngle / segments) * (1.0 - gapFrac);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HoleGuidePainter old) =>
      old.center != center ||
      old.radius != radius ||
      old.hasFace != hasFace;
}
