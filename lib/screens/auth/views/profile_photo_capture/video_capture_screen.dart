import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// NOTE: add `video_player` to pubspec.yaml if it isn't already there —
// it's used only for the in-flow "review your clip" step below.
import 'package:video_player/video_player.dart';

enum _Stage {
  initializing,
  cameraError,
  ready,
  countdown,
  recording,
  reviewing,
  saving,
}

class LivenessCaptureScreen extends StatefulWidget {
  /// How long the actual liveness clip should be.
  final Duration maxDuration;

  /// How long the "get ready" countdown runs before recording starts.
  final Duration countdownDuration;

  const LivenessCaptureScreen({
    super.key,
    this.maxDuration = const Duration(seconds: 10),
    this.countdownDuration = const Duration(seconds: 3),
  });

  @override
  State<LivenessCaptureScreen> createState() => _LivenessCaptureScreenState();
}

class _LivenessCaptureScreenState extends State<LivenessCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  _Stage _stage = _Stage.initializing;
  String? _errorMessage;

  int _countdownLeft = 0;
  int _secondsLeft = 0;
  Timer? _timer;

  XFile? _capturedFile;
  VideoPlayerController? _reviewController;

  // Simple rotating guidance shown during recording. This is purely a UX
  // cue to get a natural, well-lit, forward-facing clip — the actual
  // liveness/anti-spoof check happens server-side once uploaded.
  static const List<String> _guidanceSteps = [
    "Look straight at the camera",
    "Keep your whole face in the oval",
    "Blink naturally",
    "Almost done, stay still",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _countdownLeft = widget.countdownDuration.inSeconds;
    _secondsLeft = widget.maxDuration.inSeconds;
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Bail out safely if the app is backgrounded mid-capture.
      if (_stage == _Stage.recording || _stage == _Stage.countdown) {
        _abortToReady("Recording cancelled — app was interrupted.");
      }
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _stage = _Stage.initializing;
      _errorMessage = null;
    });

    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _stage = _Stage.cameraError;
          _errorMessage = "No camera was found on this device.";
        });
        return;
      }

      final front = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _controller = controller;
        _stage = _Stage.ready;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.cameraError;
        _errorMessage = _friendlyCameraError(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.cameraError;
        _errorMessage = "Something went wrong opening the camera.";
      });
    }
  }

  String _friendlyCameraError(CameraException e) {
    switch (e.code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
        return "Camera access is needed for identity verification. "
            "Please allow camera & microphone access in your device "
            "settings, then try again.";
      case 'AudioAccessDenied':
        return "Microphone access is needed to record the liveness video. "
            "Please allow microphone access in your device settings.";
      default:
        return "Couldn't start the camera. Please try again.";
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller?.dispose();
    _reviewController?.dispose();
    super.dispose();
  }

  void _abortToReady(String message) {
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _stage = _Stage.ready;
      _secondsLeft = widget.maxDuration.inSeconds;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- Countdown -> Recording flow ---

  void _beginCountdown() {
    HapticFeedback.lightImpact();
    setState(() {
      _stage = _Stage.countdown;
      _countdownLeft = widget.countdownDuration.inSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownLeft <= 1) {
        timer.cancel();
        _startRecording();
      } else {
        HapticFeedback.selectionClick();
        setState(() => _countdownLeft--);
      }
    });
  }

  Future<void> _startRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      _abortToReady("Camera isn't ready yet. Please try again.");
      return;
    }

    try {
      setState(() {
        _stage = _Stage.recording;
        _secondsLeft = widget.maxDuration.inSeconds;
      });

      await controller.startVideoRecording();
      HapticFeedback.mediumImpact();

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsLeft > 1) {
          setState(() => _secondsLeft--);
        } else {
          timer.cancel();
          await _finishRecording();
        }
      });
    } catch (e) {
      debugPrint("Video recording failed: $e");
      _abortToReady("Recording failed. Please try again.");
    }
  }

  Future<void> _finishRecording() async {
    final controller = _controller;
    if (controller == null) return;

    try {
      final file = await controller.stopVideoRecording();
      HapticFeedback.heavyImpact();

      if (!mounted) return;

      final reviewController = VideoPlayerController.file(File(file.path));
      await reviewController.initialize();
      await reviewController.setLooping(true);
      await reviewController.play();

      if (!mounted) {
        reviewController.dispose();
        return;
      }

      setState(() {
        _capturedFile = file;
        _reviewController = reviewController;
        _stage = _Stage.reviewing;
      });
    } catch (e) {
      debugPrint("Failed to stop recording: $e");
      _abortToReady("Something went wrong saving the video. Please retry.");
    }
  }

  Future<void> _retake() async {
    HapticFeedback.selectionClick();
    await _reviewController?.pause();
    await _reviewController?.dispose();
    if (!mounted) return;
    setState(() {
      _reviewController = null;
      _capturedFile = null;
      _stage = _Stage.ready;
      _secondsLeft = widget.maxDuration.inSeconds;
    });
  }

  Future<void> _confirmAndSubmit() async {
    if (_capturedFile == null) return;
    setState(() => _stage = _Stage.saving);
    HapticFeedback.mediumImpact();
    // Nothing else to process here — the file is handed back as-is and
    // the backend takes care of verification once it's uploaded.
    if (!mounted) return;
    Navigator.pop(context, _capturedFile);
  }

  bool get _canPop =>
      _stage != _Stage.recording && _stage != _Stage.countdown;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please wait for the recording to finish."),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_stage) {
      case _Stage.initializing:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      case _Stage.cameraError:
        return _buildErrorState();
      case _Stage.reviewing:
        return _buildReviewState();
      case _Stage.saving:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      case _Stage.ready:
      case _Stage.countdown:
      case _Stage.recording:
        return _buildCameraState();
    }
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, color: Colors.white54, size: 56),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? "Something went wrong.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text("Try Again"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraState() {
    final controller = _controller;
    final progress = _stage == _Stage.recording
        ? 1 - (_secondsLeft / widget.maxDuration.inSeconds)
        : 0.0;
    final guidanceIndex = _stage == _Stage.recording
        ? (((1 - (_secondsLeft / widget.maxDuration.inSeconds)) *
                    _guidanceSteps.length)
                .floor())
            .clamp(0, _guidanceSteps.length - 1)
        : 0;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null && controller.value.isInitialized)
          Center(child: CameraPreview(controller))
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),

        // Dim + oval cut-out to guide face position.
        _FaceOvalOverlay(active: _stage != _Stage.countdown),

        // Top instructions.
        Positioned(
          top: 16,
          left: 24,
          right: 24,
          child: Column(
            children: [
              IconButton(
                alignment: Alignment.centerLeft,
                onPressed: _canPop ? () => Navigator.pop(context, null) : null,
                icon: Icon(
                  Icons.close,
                  color: _canPop ? Colors.white : Colors.white24,
                ),
              ),
              Text(
                _stage == _Stage.recording
                    ? _guidanceSteps[guidanceIndex]
                    : "Fit your face inside the oval,\nthen tap Start when ready",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Countdown overlay.
        if (_stage == _Stage.countdown)
          Center(
            child: Text(
              "$_countdownLeft",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 96,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Bottom controls.
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Column(
            children: [
              if (_stage == _Stage.recording)
                _RecordingTimerRing(
                  progress: progress,
                  secondsLeft: _secondsLeft,
                )
              else if (_stage == _Stage.ready)
                ElevatedButton(
                  onPressed: _beginCountdown,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Start Recording",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 12),
              if (_stage == _Stage.ready)
                const Text(
                  "This is a private, secure recording used only\nto verify your identity.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewState() {
    final reviewController = _reviewController;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            "Review your video",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Make sure your face is clearly visible and well lit.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: reviewController != null && reviewController.value.isInitialized
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: reviewController.value.aspectRatio,
                      child: VideoPlayer(reviewController),
                    ),
                  )
                : const CircularProgressIndicator(color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _retake,
                  icon: const Icon(Icons.replay, color: Colors.white70),
                  label: const Text(
                    "Retake",
                    style: TextStyle(color: Colors.white70),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _confirmAndSubmit,
                  icon: const Icon(Icons.check, color: Colors.black),
                  label: const Text(
                    "Use This Video",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dims the surrounding area and cuts an oval "face here" guide out of it.
class _FaceOvalOverlay extends StatelessWidget {
  final bool active;
  const _FaceOvalOverlay({required this.active});

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: _OvalOverlayPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _OvalOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: size.width * 0.7,
      height: size.width * 0.95,
    );

    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()..addOval(ovalRect);
    final overlayPath = Path.combine(PathOperation.difference, backgroundPath, ovalPath);

    canvas.drawPath(overlayPath, Paint()..color = Colors.black.withOpacity(0.55));
    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Circular countdown ring shown while recording, with seconds remaining.
class _RecordingTimerRing extends StatelessWidget {
  final double progress;
  final int secondsLeft;

  const _RecordingTimerRing({
    required this.progress,
    required this.secondsLeft,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 4,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.redAccent),
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            bottom: -22,
            child: Text(
              "${secondsLeft}s",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}