  import 'dart:async';
  import 'dart:io';
  import 'package:camera/camera.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_application_2/screens/liveness_capture/widgets/face_overlay.dart';
  import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

  enum LivenessStep { lookStraight, turnLeft, turnRight }

  extension LivenessStepUi on LivenessStep {
    String get instruction {
      switch (this) {
        case LivenessStep.lookStraight:
          return "Look straight ahead";
        case LivenessStep.turnLeft:
          return "Turn your head left";
        case LivenessStep.turnRight:
          return "Turn your head right";
      }
    }

    IconData get icon {
      switch (this) {
        case LivenessStep.lookStraight:
          return Icons.face;
        case LivenessStep.turnLeft:
          return Icons.arrow_back;
        case LivenessStep.turnRight:
          return Icons.arrow_forward;
      }
    }
  }

  enum _Phase { checkingCamera, permissionDenied, noFrontCamera, cameraError, challenge, stabilizing, countdown, recording, uploading, done }

  class LivenessCaptureScreen extends StatefulWidget {
    const LivenessCaptureScreen({super.key});

    @override
    State<LivenessCaptureScreen> createState() => _LivenessCaptureScreenState();
  }

  class _LivenessCaptureScreenState extends State<LivenessCaptureScreen> {
    CameraController? _cameraController;
    late FaceDetector _faceDetector;

    _Phase _phase = _Phase.checkingCamera;
    bool _isProcessingFrame = false;
    String? _currentIssue;

    final List<LivenessStep> _steps = const [
      LivenessStep.lookStraight,
      LivenessStep.turnLeft,
      LivenessStep.turnRight,
    ];
    int _currentStepIndex = 0;
    DateTime? _stepStableSince;
    DateTime? _invalidSince;

    Timer? _countdownTimer;
    int _countdown = 3;
    XFile? _recordedVideo;

    // Passive signal only — never blocks progress.
    int _blinkCount = 0;
    bool _eyesOpenBaseline = true;

    // Tuning — generous on purpose. Loosen further if testers get stuck.
    static const double _straightAngleTolerance = 20.0;
    static const double _turnThreshold = 15.0;
    static const double _minFaceAreaRatio = 0.15;
    static const double _maxFaceAreaRatio = 0.60;
    static const Duration _poseHold = Duration(milliseconds: 500);
    static const Duration _stableCaptureHold = Duration(milliseconds: 1000);
    static const Duration _invalidGrace = Duration(seconds: 2);
    static const int _yawSign = 1; // flip to -1 if left/right feel swapped

    LivenessStep get _currentStep => _steps[_currentStepIndex];

    @override
    void initState() {
      super.initState();
      _bootstrap();
    }

    @override
    void dispose() {
      _countdownTimer?.cancel();
      _cameraController?.dispose();
      _faceDetector.close();
      super.dispose();
    }

    Future<void> _bootstrap() async {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
          enableClassification: true,
          enableTracking: true,
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
      setState(() => _phase = _Phase.challenge);
    }

    Future<void> _retry() async {
      setState(() => _phase = _Phase.checkingCamera);
      await _bootstrap();
    }

    Future<void> _processCameraImage(CameraImage image) async {
      if (_isProcessingFrame || _cameraController == null) return;
      if (_phase == _Phase.recording || _phase == _Phase.uploading || _phase == _Phase.done) return;

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
      if (_phase != _Phase.challenge && _phase != _Phase.stabilizing) return;

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
      _trackBlink(face);

      if (_phase == _Phase.challenge) {
        _runChallenge(face);
      } else {
        _runStabilization(face);
      }
    }

    /// Just the essentials: one face, roughly framed, reasonably sized.
    String? _checkBasics(Face face, CameraImage image) {
      final rect = face.boundingBox;
      final imgArea = image.width * image.height;
      final faceAreaRatio = (rect.width * rect.height) / imgArea;

      if (!_isFaceCentered(face)) return "Center your face in the guide";
      if (faceAreaRatio < _minFaceAreaRatio) return "Move a little closer";
      if (faceAreaRatio > _maxFaceAreaRatio) return "Move back slightly";

      return null;
    }

    bool _isFaceCentered(Face face) {
      final rect = face.boundingBox;
      final faceCenter = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);

      final previewWidth = _cameraController!.value.previewSize!.height;
      final previewHeight = _cameraController!.value.previewSize!.width;
      final previewCenter = Offset(previewWidth / 2, previewHeight / 2);

      const tolerance = 110.0; // a bit looser than before
      return (faceCenter.dx - previewCenter.dx).abs() < tolerance &&
          (faceCenter.dy - previewCenter.dy).abs() < tolerance;
    }

    void _flagInvalid(String reason) {
      setState(() => _currentIssue = reason);
      final now = DateTime.now();
      _invalidSince ??= now;
      _stepStableSince = null;

      if (now.difference(_invalidSince!) >= _invalidGrace) {
        _resetPipeline();
      }
    }

    void _resetPipeline() {
      setState(() {
        _phase = _Phase.challenge;
        _currentStepIndex = 0;
      });
      _stepStableSince = null;
      _invalidSince = null;
      _cancelCountdown();
    }

    void _runChallenge(Face face) {
      final yaw = (face.headEulerAngleY ?? 0.0) * _yawSign;
      bool stepMet;
      switch (_currentStep) {
        case LivenessStep.lookStraight:
          stepMet = yaw.abs() < _straightAngleTolerance;
          break;
        case LivenessStep.turnLeft:
          stepMet = yaw > _turnThreshold;
          break;
        case LivenessStep.turnRight:
          stepMet = yaw < -_turnThreshold;
          break;
      }

      if (!stepMet) {
        _stepStableSince = null;
        return;
      }

      final now = DateTime.now();
      _stepStableSince ??= now;

      if (now.difference(_stepStableSince!) >= _poseHold) {
        _stepStableSince = null;
        if (_currentStepIndex + 1 >= _steps.length) {
          setState(() => _phase = _Phase.stabilizing);
        } else {
          setState(() => _currentStepIndex++);
        }
      }
    }

    void _runStabilization(Face face) {
      final yaw = (face.headEulerAngleY ?? 0.0) * _yawSign;
      final centered = yaw.abs() < _straightAngleTolerance;

      if (!centered) {
        _stepStableSince = null;
        return;
      }

      final now = DateTime.now();
      _stepStableSince ??= now;

      if (now.difference(_stepStableSince!) >= _stableCaptureHold) {
        _stepStableSince = null;
        _startCountdown();
      }
    }

    void _trackBlink(Face face) {
      final leftEye = face.leftEyeOpenProbability ?? 1.0;
      final rightEye = face.rightEyeOpenProbability ?? 1.0;
      final avgOpen = (leftEye + rightEye) / 2;

      if (_eyesOpenBaseline && avgOpen < 0.3) {
        _eyesOpenBaseline = false;
      } else if (!_eyesOpenBaseline && avgOpen > 0.6) {
        _eyesOpenBaseline = true;
        _blinkCount++;
      }
    }

    void _startCountdown() {
      setState(() => _phase = _Phase.countdown);
      _countdown = 3;
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!mounted) return;
        setState(() => _countdown--);
        if (_countdown <= 0) {
          timer.cancel();
          await _startRecording();
        }
      });
    }

    void _cancelCountdown() {
      _countdownTimer?.cancel();
      _countdown = 3;
    }

    Future<void> _startRecording() async {
      if (_cameraController == null) return;
      try {
        setState(() => _phase = _Phase.recording);
        await _cameraController!.stopImageStream();
        await _cameraController!.startVideoRecording();

        await Future.delayed(const Duration(seconds: 6));

        final video = await _cameraController!.stopVideoRecording();
        _recordedVideo = video;

        setState(() => _phase = _Phase.uploading);
        await _uploadForVerification(video, {'blinkCount': _blinkCount});

        if (!mounted) return;
        setState(() => _phase = _Phase.done);
        Navigator.pop(context, video);
      } catch (e) {
        debugPrint(e.toString());
        _resetPipeline();
        await _cameraController?.startImageStream(_processCameraImage);
      }
    }

    /// PLACEHOLDER — send me your endpoint/auth details to wire this up.
    Future<void> _uploadForVerification(XFile video, Map<String, dynamic> metadata) async {
      debugPrint("TODO: upload ${video.path} with metadata $metadata");
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
              if (_phase == _Phase.challenge)
                Positioned(top: 20, left: 20, right: 20, child: _buildStepProgress()),
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
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildStepProgress() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_steps.length, (i) {
          final step = _steps[i];
          final done = i < _currentStepIndex;
          final active = i == _currentStepIndex;
          final color = done ? Colors.green : (active ? Colors.orange : Colors.white24);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Icon(done ? Icons.check : step.icon, size: 18, color: Colors.black),
            ),
          );
        }),
      );
    }

    Widget _buildStatusCard() {
      String title;
      IconData icon;
      Color color;

      switch (_phase) {
        case _Phase.recording:
          title = "Recording...";
          icon = Icons.fiber_manual_record;
          color = Colors.redAccent;
          break;
        case _Phase.uploading:
          title = "Verifying...";
          icon = Icons.cloud_upload;
          color = Colors.blueAccent;
          break;
        case _Phase.countdown:
          title = "Recording starts in $_countdown";
          icon = Icons.timer;
          color = Colors.orange;
          break;
        case _Phase.stabilizing:
          title = "Look straight at the camera and stay still...";
          icon = Icons.center_focus_strong;
          color = Colors.greenAccent;
          break;
        default:
          title = _currentIssue ?? _currentStep.instruction;
          icon = _currentIssue == null ? _currentStep.icon : Icons.error_outline;
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