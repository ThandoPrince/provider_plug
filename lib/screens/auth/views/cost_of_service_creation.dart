import 'dart:io';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/controller/registration/cost_of_service_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/auth/widgets/completed_registration_screen_overlay.dart';
import 'package:flutter_application_2/screens/onboarding/Widgets/back_exit_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UploadServiceCostScreen extends StatefulWidget {
  final String email;
  final int serviceId;

  const UploadServiceCostScreen({
    Key? key,
    required this.email,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<UploadServiceCostScreen> createState() =>
      _UploadServiceCostScreenState();
}

class _UploadServiceCostScreenState extends State<UploadServiceCostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<File> _serviceImages = [];

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    HapticFeedback.vibrate();
    FlushbarHelper.createError(message: message).show(context);
  }

  Future<void> _pickImages() async {
    final remainingSlots = 5 - _serviceImages.length;

    if (remainingSlots <= 0) {
      _showError('You can upload a maximum of 5 images.');
      return;
    }

    final pickedFiles = await _picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1200,
    );

    if (pickedFiles.isEmpty) return;

    final selectedFiles = pickedFiles
        .take(remainingSlots)
        .map((xFile) => File(xFile.path))
        .toList();

    setState(() {
      _serviceImages.addAll(selectedFiles);
    });

    if (pickedFiles.length > remainingSlots) {
      FlushbarHelper.createInformation(
        message: 'Only $remainingSlots image(s) were added. Maximum is 5.',
      ).show(context);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _serviceImages.removeAt(index);
    });
  }

 

  Future<void> _submit() async {
    // 1. Check form validation
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    // 2. Clear any previous errors in controller
    final controller = context.read<CostOfServiceController>();
    controller.clearError();

    final success = await controller.updateServiceCost(
      notes: _notesController.text.trim(),
      email: widget.email,
      serviceId: widget.serviceId,
      cost: double.parse(_priceController.text.trim()),
      images: _serviceImages,
    );

    if (success && mounted) {
      _showSuccessOverlay();
    } else if (mounted) {
      // Show server error via Flushbar
      _showError(controller.errorMessage ?? "An unexpected error occurred.");
    }
  }

  void _showSuccessOverlay() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85), // Darker for better focus
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const RegistrationSuccessOverlay(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(scale: anim1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<CostOfServiceController>();

    return DoubleBackToExit(
      child: Scaffold(
        backgroundColor: Kolors.kPrimary,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Kolors.kOffWhite,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "STEP 2 OF 2",
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Kolors.kOffWhite,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Kolors.kOffWhite.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Final Step",
                                  style: TextStyle(
                                    color: Kolors.kOffWhite,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Set Your Base Rate",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Kolors.kOffWhite,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Enter the standard amount you charge for this service. You can clarify details in the notes and add photos of your work.",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Kolors.kOffWhite.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 32),
      
                          _buildInputLabel("BASE PRICE"),
                          _buildInputContainer(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: const TextStyle(
                                color: Kolors.kDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              decoration: const InputDecoration(
                                hintText: "0.00",
                                prefixText: "R ",
                                prefixStyle: TextStyle(
                                  color: Kolors.kPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Price is required";
                                }
                                if (double.tryParse(value) == null) {
                                  return "Invalid number";
                                }
                                return null;
                              },
                            ),
                          ),
      
                          const SizedBox(height: 24),
      
                          _buildInputLabel("PRICING NOTES (OPTIONAL)"),
                          _buildInputContainer(
                            child: TextFormField(
                              controller: _notesController,
                              maxLines: 4,
                              style: const TextStyle(color: Kolors.kDark),
                              decoration: const InputDecoration(
                                hintText:
                                    "e.g., Price varies based on location or equipment required...",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
      
                          const SizedBox(height: 24),
      
                          _buildInputLabel("SERVICE PHOTOS (MAX 5)"),
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Kolors.kPrimary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _serviceImages.isEmpty
                                          ? "Add photos of the service you provide"
                                          : "${_serviceImages.length}/5 selected",
                                      style: const TextStyle(
                                        color: Kolors.kDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
      
                          const SizedBox(height: 12),
      
                          if (_serviceImages.isNotEmpty)
                            SizedBox(
                              height: 110,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _serviceImages.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final image = _serviceImages[index];
      
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          image,
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
      
                          if (controller.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                controller.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildFooterAction(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterAction(CostOfServiceController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: controller.isLoading ? null : _submit,
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: Kolors.kPrimary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: controller.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Save & Finish",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          label,
          style: const TextStyle(
            color: Kolors.kOffWhite,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      );

  Widget _buildInputContainer({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: child,
      );
}