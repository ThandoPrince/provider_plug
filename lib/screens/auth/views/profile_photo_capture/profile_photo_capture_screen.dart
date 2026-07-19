import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/liveness_capture/widgets/face_overlay.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum _Phase {
  checkingCamera,
  permissionDenied,
  noFrontCamera,
  cameraError,
  detecting,
  stabilizing,
  capturing,
  done,
}

/// Live front-camera capture for the profile photo. Gallery selection is
/// intentionally not offered — auto-captures only once a single, centered,
/// reasonably-sized face is held steady, mirroring the anti-spoofing intent
/// of LivenessCaptureScreen (just without the turn-left/right challenge,
/// since a profile photo doesn't need pose variation — only a genuine
/// live face in frame).
class ProfilePhotoCaptureScreen extends StatefulWidget {
  const ProfilePhotoCaptureScreen({super.key});

  @override
  State<ProfilePhotoCaptureScreen> createState() => _ProfilePhotoCaptureScreenState();
}

class _ProfilePhotoCaptureScreenState extends State<ProfilePhotoCaptureScreen> {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;

  _Phase _phase = _Phase.checkingCamera;
  bool _isProcessingFrame = false;
  String? _currentIssue;

  DateTime? _stableSince;
  DateTime? _invalidSince;

  // Same tuning philosophy as liveness: generous, loosen if testers get stuck.
  static const double _straightAngleTolerance = 20.0;
  static const double _minFaceAreaRatio = 0.15;
  static const double _maxFaceAreaRatio = 0.60;
  static const Duration _stableCaptureHold = Duration(milliseconds: 1200);
  static const Duration _invalidGrace = Duration(seconds: 2);
  static const int _yawSign = 1; // match liveness screen's convention

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableClassification: false,
        enableTracking: false,
      ),
    );

    List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } catch (_) {
      setState(() => _phase = _Phase.cameraError);
      return;
    }

    final frontCamera = cameras.where((c) => c.lensDirection == CameraLensDirection.front);
    if (frontCamera.isEmpty) {
      setState(() => _phase = _Phase.noFrontCamera);
      return;
    }

    _cameraController = CameraController(
      frontCamera.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _cameraController!.initialize();
    } on CameraException catch (e) {
      setState(() => _phase = e.code.contains('Denied') ? _Phase.permissionDenied : _Phase.cameraError);
      return;
    } catch (_) {
      setState(() => _phase = _Phase.cameraError);
      return;
    }

    await _cameraController!.startImageStream(_processCameraImage);
    if (!mounted) return;
    setState(() => _phase = _Phase.detecting);
  }

  Future<void> _retry() async {
    setState(() => _phase = _Phase.checkingCamera);
    await _bootstrap();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame || _cameraController == null) return;
    if (_phase == _Phase.capturing || _phase == _Phase.done) return;

    _isProcessingFrame = true;
    try {
      final inputImage = _convertCameraImage(image, _cameraController!);
      if (inputImage == null) {
        _isProcessingFrame = false;
        return;
      }
      final faces = await _faceDetector.processImage(inputImage);
      if (!mounted) {
        _isProcessingFrame = false;
        return;
      }
      _handleFrame(faces, image);
    } catch (e) {
      debugPrint(e.toString());
    }
    _isProcessingFrame = false;
  }

  InputImage? _convertCameraImage(CameraImage image, CameraController controller) {
    try {
      final camera = controller.description;
      final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.rotation0deg;
      final format = Platform.isAndroid
          ? InputImageFormat.nv21
          : InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.bgra8888;

      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      debugPrint("Error converting camera image: $e");
      return null;
    }
  }

  void _handleFrame(List<Face> faces, CameraImage image) {
    if (_phase != _Phase.detecting && _phase != _Phase.stabilizing) return;

    if (faces.length != 1) {
      _flagInvalid(faces.isEmpty ? "Place your face inside the frame" : "Only one person at a time");
      return;
    }

    final face = faces.first;
    final issue = _checkBasics(face, image);
    if (issue != null) {
      _flagInvalid(issue);
      return;
    }

    _invalidSince = null;
    if (_currentIssue != null) setState(() => _currentIssue = null);

    _runStabilization(face);
  }

  String? _checkBasics(Face face, CameraImage image) {
    final rect = face.boundingBox;
    final imgArea = image.width * image.height;
    final faceAreaRatio = (rect.width * rect.height) / imgArea;
    final yaw = (face.headEulerAngleY ?? 0.0) * _yawSign;

    if (!_isFaceCentered(face)) return "Center your face in the guide";
    if (faceAreaRatio < _minFaceAreaRatio) return "Move a little closer";
    if (faceAreaRatio > _maxFaceAreaRatio) return "Move back slightly";
    if (yaw.abs() >= _straightAngleTolerance) return "Look straight at the camera";

    return null;
  }

  bool _isFaceCentered(Face face) {
    final rect = face.boundingBox;
    final faceCenter = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);

    final previewWidth = _cameraController!.value.previewSize!.height;
    final previewHeight = _cameraController!.value.previewSize!.width;
    final previewCenter = Offset(previewWidth / 2, previewHeight / 2);

    const tolerance = 110.0;
    return (faceCenter.dx - previewCenter.dx).abs() < tolerance &&
        (faceCenter.dy - previewCenter.dy).abs() < tolerance;
  }

  void _flagInvalid(String reason) {
    setState(() {
      _currentIssue = reason;
      _phase = _Phase.detecting;
    });
    final now = DateTime.now();
    _invalidSince ??= now;
    _stableSince = null;

    if (now.difference(_invalidSince!) >= _invalidGrace) {
      _invalidSince = null;
    }
  }

  void _runStabilization(Face face) {
    setState(() => _phase = _Phase.stabilizing);

    final now = DateTime.now();
    _stableSince ??= now;

    if (now.difference(_stableSince!) >= _stableCaptureHold) {
      _stableSince = null;
      _captureStill();
    }
  }

  Future<void> _captureStill() async {
    if (_cameraController == null) return;
    setState(() => _phase = _Phase.capturing);

    try {
      // Stop the stream before taking a still — some platforms don't
      // reliably support takePicture() while an image stream is active.
      await _cameraController!.stopImageStream();
      final XFile photo = await _cameraController!.takePicture();

      if (!mounted) return;
      setState(() => _phase = _Phase.done);
      Navigator.pop(context, File(photo.path));
    } catch (e) {
      debugPrint("Capture failed: $e");
      if (!mounted) return;
      setState(() => _phase = _Phase.detecting);
      await _cameraController?.startImageStream(_processCameraImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _Phase.checkingCamera) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }
    if (_phase == _Phase.permissionDenied) {
      return _buildBlockingMessage("Camera permission is required to continue.", "Try again", _retry);
    }
    if (_phase == _Phase.noFrontCamera) {
      return _buildBlockingMessage("No front-facing camera was found on this device.", null, null);
    }
    if (_phase == _Phase.cameraError) {
      return _buildBlockingMessage("Couldn't start the camera. Please try again.", "Retry", _retry);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_cameraController != null && _cameraController!.value.isInitialized)
              Positioned.fill(child: CameraPreview(_cameraController!)),
            Positioned.fill(child: FaceOverlay(faceDetected: _currentIssue == null)),
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(bottom: 40, left: 20, right: 20, child: _buildStatusCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockingMessage(String message, String? actionLabel, VoidCallback? onAction) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    String title;
    IconData icon;
    Color color;

    switch (_phase) {
      case _Phase.capturing:
        title = "Capturing...";
        icon = Icons.camera_alt;
        color = Colors.blueAccent;
        break;
      case _Phase.stabilizing:
        title = "Hold still...";
        icon = Icons.center_focus_strong;
        color = Colors.greenAccent;
        break;
      default:
        title = _currentIssue ?? "Center your face in the frame";
        icon = _currentIssue == null ? Icons.face : Icons.error_outline;
        color = _currentIssue == null ? Colors.greenAccent : Colors.amber;
    }

    return Card(
      color: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16))),
          ],
        ),
      ),
    );
  }
}