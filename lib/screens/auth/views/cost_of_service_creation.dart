import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/controller/registration/cost_of_service_controller.dart';
import 'package:flutter_application_2/common/controller/registration/provider_qualification_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/screens/auth/widgets/completed_registration_screen_overlay.dart';
import 'package:flutter_application_2/screens/onboarding/Widgets/back_exit_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// One document the provider has attached in this session — tracks its
/// own upload lifecycle independently so one failure doesn't block others.
class _QualificationDraft {
  final File file;
  final String fileName;
  String title;
  String documentType;
  String issuingBody;
  DateTime? issueDate;
  DateTime? expiryDate;

  _QualificationUploadStatus status;
  String? errorMessage;

  _QualificationDraft({
    required this.file,
    required this.fileName,
    required this.title,
    required this.documentType,
    this.issuingBody = "",
    this.issueDate,
    this.expiryDate,
    this.status = _QualificationUploadStatus.pending,
    this.errorMessage,
  });
}

enum _QualificationUploadStatus { pending, uploading, uploaded, failed }

const List<Map<String, String>> _kDocumentTypes = [
  {"value": "CERTIFICATE", "label": "Certificate"},
  {"value": "LICENSE", "label": "License"},
  {"value": "INSURANCE", "label": "Insurance"},
  {"value": "REFERENCE", "label": "Reference Letter"},
  {"value": "OTHER", "label": "Other"},
];

class UploadServiceCostScreen extends StatefulWidget {
 
  final int serviceId;
 

  const UploadServiceCostScreen({
    Key? key,

    
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

  final List<_QualificationDraft> _qualifications = [];

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    HapticFeedback.vibrate();

    FlushbarService.error(
      context,
      message,
      duration: const Duration(seconds: 4),
    );
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
      FlushbarService.error(
        context,
        'Only $remainingSlots image(s) were added. Maximum is 5.',
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _serviceImages.removeAt(index);
    });
  }

  // =========================================================
  // Professional documents / references
  // =========================================================

  Future<void> _pickQualificationDocument() async {
    if (_qualifications.length >= 5) {
      _showError('You can attach a maximum of 5 documents.');
      return;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    if (!mounted) return;

    final details = await _showQualificationDetailsSheet(fileName: fileName);
    if (details == null) return; // user cancelled

    final draft = _QualificationDraft(
      file: file,
      fileName: fileName,
      title: details['title'] as String,
      documentType: details['documentType'] as String,
      issuingBody: details['issuingBody'] as String,
      issueDate: details['issueDate'] as DateTime?,
      expiryDate: details['expiryDate'] as DateTime?,
    );

    setState(() => _qualifications.add(draft));
    _uploadQualification(draft);
  }

  Future<Map<String, dynamic>?> _showQualificationDetailsSheet({
    required String fileName,
  }) {
    final titleController = TextEditingController();
    final issuingBodyController = TextEditingController();
    String documentType = _kDocumentTypes.first['value']!;
    DateTime? issueDate;
    DateTime? expiryDate;

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> pickDate({required bool isIssueDate}) async {
              final picked = await showDatePicker(
                context: sheetContext,
                initialDate: DateTime.now(),
                firstDate: DateTime(1990),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setSheetState(() {
                  if (isIssueDate) {
                    issueDate = picked;
                  } else {
                    expiryDate = picked;
                  }
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            color: Kolors.kPrimary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              fileName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sheetLabel("TITLE"),
                      TextField(
                        controller: titleController,
                        decoration: _sheetInputDecoration(
                          "e.g. Electrical Trade Certificate",
                        ),
                      ),
                      const SizedBox(height: 16),
                      _sheetLabel("DOCUMENT TYPE"),
                      DropdownButtonFormField<String>(
                        value: documentType,
                        decoration: _sheetInputDecoration(null),
                        items: _kDocumentTypes
                            .map(
                              (t) => DropdownMenuItem(
                                value: t['value'],
                                child: Text(t['label']!),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setSheetState(() => documentType = v);
                        },
                      ),
                      const SizedBox(height: 16),
                      _sheetLabel("ISSUING BODY (OPTIONAL)"),
                      TextField(
                        controller: issuingBodyController,
                        decoration: _sheetInputDecoration(
                          "e.g. Dept. of Labour",
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _datePickerField(
                              label: "ISSUE DATE",
                              value: issueDate,
                              onTap: () => pickDate(isIssueDate: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _datePickerField(
                              label: "EXPIRY DATE",
                              value: expiryDate,
                              onTap: () => pickDate(isIssueDate: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Kolors.kPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            if (titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(
                                  content: Text("Title is required."),
                                ),
                              );
                              return;
                            }
                            Navigator.pop(sheetContext, {
                              'title': titleController.text.trim(),
                              'documentType': documentType,
                              'issuingBody': issuingBodyController.text.trim(),
                              'issueDate': issueDate,
                              'expiryDate': expiryDate,
                            });
                          },
                          child: const Text(
                            "Add Document",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 2),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
        letterSpacing: 0.6,
      ),
    ),
  );

  InputDecoration _sheetInputDecoration(String? hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey.shade100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  Widget _datePickerField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Colors.black45,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == null
                    ? label
                    : "${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}",
                style: TextStyle(
                  fontSize: 12,
                  color: value == null ? Colors.black45 : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadQualification(_QualificationDraft draft) async {
    setState(() => draft.status = _QualificationUploadStatus.uploading);

    final controller = context.read<ProviderQualificationController>();

    final success = await controller.uploadQualification(
      providerServiceId: widget.serviceId,
      document: draft.file,
      documentType: draft.documentType,
      title: draft.title,
      issuingBody: draft.issuingBody,
      issueDate: draft.issueDate,
      expiryDate: draft.expiryDate,
    );

    if (!mounted) return;

    setState(() {
      if (success) {
        draft.status = _QualificationUploadStatus.uploaded;
      } else {
        draft.status = _QualificationUploadStatus.failed;
        draft.errorMessage = controller.errorMessage ?? "Upload failed.";
      }
    });
  }

  void _removeQualification(int index) {
    setState(() => _qualifications.removeAt(index));
    // Note: this only removes the item locally. If it already uploaded
    // successfully server-side, deleting it there would need a separate
    // delete endpoint — not wired up here since one wasn't provided.
  }

  // =========================================================

  Future<void> _submit() async {
    // 1. Check form validation
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    // Block submit while a document is actively uploading so the user
    // doesn't navigate away mid-upload.
    if (_qualifications.any(
      (q) => q.status == _QualificationUploadStatus.uploading,
    )) {
      _showError("Please wait for document uploads to finish.");
      return;
    }

    // 2. Clear any previous errors in controller
    final controller = context.read<CostOfServiceController>();
    controller.clearError();

    final success = await controller.updateServiceCost(
      notes: _notesController.text.trim(),
     
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
      pageBuilder: (context, anim1, anim2) =>
          const RegistrationSuccessOverlay(),
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
                              ),
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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

                          const SizedBox(height: 28),

                          // --- Professional Documents / References ---
                          _buildInputLabel(
                            "PROFESSIONAL DOCUMENTS & REFERENCES (OPTIONAL)",
                          ),
                          Text(
                            "Add certificates, licenses, insurance, or reference letters to strengthen your profile.",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Kolors.kOffWhite.withOpacity(0.65),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _pickQualificationDocument,
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
                                    Icons.upload_file_outlined,
                                    color: Kolors.kPrimary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _qualifications.isEmpty
                                          ? "Add a certificate, license, or reference"
                                          : "${_qualifications.length}/5 documents added",
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

                          if (_qualifications.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ..._qualifications.asMap().entries.map((entry) {
                              final index = entry.key;
                              final q = entry.value;
                              return _buildQualificationTile(index, q);
                            }),
                          ],

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

  Widget _buildQualificationTile(int index, _QualificationDraft q) {
    Widget statusIcon;
    switch (q.status) {
      case _QualificationUploadStatus.uploading:
        statusIcon = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Kolors.kPrimary,
          ),
        );
        break;
      case _QualificationUploadStatus.uploaded:
        statusIcon = const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
          size: 20,
        );
        break;
      case _QualificationUploadStatus.failed:
        statusIcon = const Icon(
          Icons.error_rounded,
          color: Colors.redAccent,
          size: 20,
        );
        break;
      case _QualificationUploadStatus.pending:
        statusIcon = const Icon(
          Icons.schedule_rounded,
          color: Colors.grey,
          size: 20,
        );
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            color: Kolors.kPrimary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  q.status == _QualificationUploadStatus.failed
                      ? (q.errorMessage ?? "Upload failed")
                      : q.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: q.status == _QualificationUploadStatus.failed
                        ? Colors.redAccent
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          statusIcon,
          if (q.status == _QualificationUploadStatus.failed)
            IconButton(
              icon: const Icon(Icons.refresh, size: 18, color: Kolors.kPrimary),
              onPressed: () => _uploadQualification(q),
              tooltip: "Retry",
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: () => _removeQualification(index),
            tooltip: "Remove",
          ),
        ],
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
        ),
      ],
    ),
    child: child,
  );
}
