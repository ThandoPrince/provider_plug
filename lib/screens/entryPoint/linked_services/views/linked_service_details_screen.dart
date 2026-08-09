import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/get_provider_for_service_controller.dart';
import 'package:flutter_application_2/common/controller/registration/provider_qualification_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/deactivate_provider_service_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/delete_cost_of_service_image_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/delete_provider_qualification_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/get_cost_of_service_images_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/get_provider_qualification_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/update_cost_of_a_service_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/upload_cost_of_service_images_controller.dart';
import 'package:flutter_application_2/common/models/models/provider_for_service_model.dart';

import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_confirmation_dialog.dart';
import 'package:flutter_application_2/common/widgets/app_style.dart';
import 'package:flutter_application_2/common/widgets/custom_app_bar.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/common/widgets/shimmers/qualifications_skeleton.dart';
import 'package:flutter_application_2/common/widgets/shimmers/service_gallery_skeleton.dart';
import 'package:flutter_application_2/screens/entryPoint/linked_services/upload_affidavit/views/upload_affidavit_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/linked_services/widgets/view_qualification_helper.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';


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

class _UploadQualificationSheet extends StatefulWidget {
  final int providerServiceId;

  const _UploadQualificationSheet({required this.providerServiceId});

  @override
  State<_UploadQualificationSheet> createState() =>
      _UploadQualificationSheetState();
}

class _UploadQualificationSheetState extends State<_UploadQualificationSheet> {
  final List<_QualificationDraft> _drafts = [];
  bool _isSubmitting = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null) return;

    setState(() {
      for (final path in result.paths.whereType<String>()) {
        final file = File(path);
        final rawName = path.split('/').last;
        final nameWithoutExt = rawName.contains('.')
            ? rawName.substring(0, rawName.lastIndexOf('.'))
            : rawName;

        _drafts.add(
          _QualificationDraft(
            file: file,
            fileName: rawName,
            title: nameWithoutExt,
            documentType: _kDocumentTypes.first["value"]!,
          ),
        );
      }
    });
  }

  void _removeDraft(_QualificationDraft draft) {
    setState(() => _drafts.remove(draft));
  }

  Future<void> _pickDate({
    required _QualificationDraft draft,
    required bool isIssueDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (isIssueDate) {
        draft.issueDate = picked;
      } else {
        draft.expiryDate = picked;
      }
    });
  }

  bool _isDraftValid(_QualificationDraft draft) {
    return draft.title.trim().isNotEmpty;
  }

    

  Future<void> _uploadDraft(_QualificationDraft draft) async {
    if (!_isDraftValid(draft)) {
      setState(() {
        draft.status = _QualificationUploadStatus.failed;
        draft.errorMessage = "Title is required.";
      });
      return;
    }

    setState(() {
      draft.status = _QualificationUploadStatus.uploading;
      draft.errorMessage = null;
    });

    try {
      final controller = context.read<ProviderQualificationController>();

      final success = await controller.uploadQualification(
        providerServiceId: widget.providerServiceId,
        document: draft.file,
        title: draft.title.trim(),
        documentType: draft.documentType,
        issuingBody: draft.issuingBody.trim(),
        issueDate: draft.issueDate,
        expiryDate: draft.expiryDate,
      );

      if (!mounted) return;

      setState(() {
        draft.status = success
            ? _QualificationUploadStatus.uploaded
            : _QualificationUploadStatus.failed;
        draft.errorMessage = success
            ? null
            : (controller.errorMessage ?? "Upload failed.");
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        draft.status = _QualificationUploadStatus.failed;
        draft.errorMessage = "Something went wrong. Please try again.";
      });
    }
  }

  Future<void> _uploadAll() async {
    final pending = _drafts.where(
      (d) =>
          d.status == _QualificationUploadStatus.pending ||
          d.status == _QualificationUploadStatus.failed,
    );

    if (pending.isEmpty) return;

    setState(() => _isSubmitting = true);

    for (final draft in pending.toList()) {
      await _uploadDraft(draft);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final allUploaded = _drafts.every(
      (d) => d.status == _QualificationUploadStatus.uploaded,
    );

    if (allUploaded && _drafts.isNotEmpty) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFailures = _drafts.any(
      (d) => d.status == _QualificationUploadStatus.failed,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Add Qualifications",
                      style: appStyle(18, Colors.white, FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                "Upload certificates, licenses, or other documents that support this service.",
                style: appStyle(13, Colors.white54, FontWeight.w500),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSubmitting ? null : _pickFiles,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Choose files"),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _drafts.isEmpty
                    ? Center(
                        child: Text(
                          "No files selected yet.",
                          style: appStyle(14, Colors.white38, FontWeight.w500),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: _drafts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, index) {
                          return _draftCard(_drafts[index]);
                        },
                      ),
              ),

              const SizedBox(height: 16),

              if (hasFailures)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Some files failed to upload. Tap 'Upload' again to retry just those.",
                          style: appStyle(12, Colors.orange, FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Kolors.kPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Kolors.kPrimary.withOpacity(0.5),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (_drafts.isEmpty || _isSubmitting)
                      ? null
                      : _uploadAll,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          hasFailures ? "Retry Failed Uploads" : "Upload",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _draftCard(_QualificationDraft draft) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: draft.status == _QualificationUploadStatus.failed
              ? Colors.red.withOpacity(.4)
              : Colors.white.withOpacity(.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                draft.fileName.toLowerCase().endsWith('.pdf')
                    ? Icons.picture_as_pdf_outlined
                    : Icons.image_outlined,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  draft.fileName,
                  overflow: TextOverflow.ellipsis,
                  style: appStyle(13, Colors.white70, FontWeight.w600),
                ),
              ),
              _statusBadge(draft.status),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                onPressed: draft.status == _QualificationUploadStatus.uploading
                    ? null
                    : () => _removeDraft(draft),
              ),
            ],
          ),

          const SizedBox(height: 10),

          TextFormField(
            initialValue: draft.title,
            enabled: draft.status != _QualificationUploadStatus.uploading,
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDecoration("Title *"),
            onChanged: (v) => draft.title = v,
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: draft.documentType,
            dropdownColor: const Color(0xFF2A2A2A),
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDecoration("Document Type"),
            items: _kDocumentTypes
                .map(
                  (t) => DropdownMenuItem(
                    value: t["value"],
                    child: Text(t["label"]!),
                  ),
                )
                .toList(),
            onChanged: draft.status == _QualificationUploadStatus.uploading
                ? null
                : (v) => setState(() => draft.documentType = v!),
          ),

          const SizedBox(height: 10),

          TextFormField(
            initialValue: draft.issuingBody,
            enabled: draft.status != _QualificationUploadStatus.uploading,
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDecoration("Issuing Body (optional)"),
            onChanged: (v) => draft.issuingBody = v,
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _dateChip(
                  label: "Issue date",
                  date: draft.issueDate,
                  onTap: draft.status == _QualificationUploadStatus.uploading
                      ? null
                      : () => _pickDate(draft: draft, isIssueDate: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dateChip(
                  label: "Expiry date",
                  date: draft.expiryDate,
                  onTap: draft.status == _QualificationUploadStatus.uploading
                      ? null
                      : () => _pickDate(draft: draft, isIssueDate: false),
                ),
              ),
            ],
          ),

          if (draft.status == _QualificationUploadStatus.failed &&
              draft.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              draft.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      filled: true,
      fillColor: Colors.white10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _dateChip({
    required String label,
    required DateTime? date,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? DateFormat("dd MMM yyyy").format(date) : label,
                style: TextStyle(
                  color: date != null ? Colors.white : Colors.white54,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(_QualificationUploadStatus status) {
    switch (status) {
      case _QualificationUploadStatus.uploading:
        return const Padding(
          padding: EdgeInsets.only(right: 4),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case _QualificationUploadStatus.uploaded:
        return const Icon(Icons.check_circle, color: Colors.green, size: 18);
      case _QualificationUploadStatus.failed:
        return const Icon(Icons.error, color: Colors.red, size: 18);
      case _QualificationUploadStatus.pending:
        return const SizedBox.shrink();
    }
  }
}

enum _QualificationUploadStatus { pending, uploading, uploaded, failed }

const List<Map<String, String>> _kDocumentTypes = [
  {"value": "CERTIFICATE", "label": "Certificate"},
  {"value": "LICENSE", "label": "License"},
  {"value": "INSURANCE", "label": "Insurance"},
  {"value": "REFERENCE", "label": "Reference Letter"},
  {"value": "OTHER", "label": "Other"},
];

class ProviderServiceDetailsScreen extends StatefulWidget {
  final ProviderServiceModel service;

  const ProviderServiceDetailsScreen({super.key, required this.service});

  @override
  State<ProviderServiceDetailsScreen> createState() =>
      _ProviderServiceDetailsScreenState();
}

class _ProviderServiceDetailsScreenState
    extends State<ProviderServiceDetailsScreen> {
  late ProviderServiceModel service;

  @override
  void initState() {
    super.initState();

    service = widget.service;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceId = service.id;
      final costId = service.costOfService?.id;

      if (serviceId != null) {
        context.read<GetProviderQualificationController>().fetchQualification(
          serviceId,
        );
      }

      if (costId != null) {
        context.read<GetCostOfServiceImagesController>().fetchImages(costId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cost = service.costOfService;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomScreenAppBar(title: "Service Details"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Kolors.kPrimary.withOpacity(.15),
                      child: Icon(
                        service.isPrimary == true
                            ? Icons.star
                            : Icons.handyman_rounded,
                        size: 42,
                        color: service.isPrimary == true
                            ? Colors.amber
                            : Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      service.service?.serviceName ?? "Unknown Service",
                      textAlign: TextAlign.center,
                      style: appStyle(22, Colors.white, FontWeight.bold),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      service.service?.serviceGroup?.name ?? "-",
                      style: appStyle(14, Colors.white70, FontWeight.w500),
                    ),

                    const SizedBox(height: 18),

                    Wrap(
                      spacing: 10,
                      children: [
                        _statusChip("ACTIVE", Colors.green),

                        if (service.isPrimary == true)
                          _statusChip("PRIMARY", Colors.amber),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _section("Statistics", [
                _tile(
                  Icons.work_outline,
                  "Completed Jobs",
                  service.completedOrders.toString(),
                ),

                _tile(
                  Icons.star_rate,
                  "Average Rating",
                  service.averageRating != null
                      ? "${service.averageRating!.toStringAsFixed(1)}"
                      : "No ratings",
                ),

                _tile(
                  Icons.calendar_today,
                  "Linked Since",
                  service.dateCreated != null
                      ? DateFormat(
                          "dd MMM yyyy",
                        ).format(DateTime.parse(service.dateCreated!))
                      : "-",
                ),
              ]),
              const SizedBox(height: 20),

              _section(
  "Pricing",
  [
    _tile(
      Icons.payments,
      "Base Price",
      cost?.basePrice != null
          ? "R${cost!.basePrice!.toStringAsFixed(2)}"
          : "Not configured",
    ),

    _tile(
      Icons.notes_outlined,
      "Notes",
      (cost?.notes?.trim().isNotEmpty ?? false)
          ? cost!.notes!
          : "No notes added",
    ),
  ],
                onAction: () async {
                  final priceController = TextEditingController(
  text: cost?.basePrice?.toStringAsFixed(2) ?? "",
);

final notesController = TextEditingController(
  text: cost?.notes ?? "",
);

                  final updated = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (_) {
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: Consumer<UpdateCostOfAServiceController>(
                          builder: (_, controller, __) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Update Base Price",
                                  style: appStyle(
                                    18,
                                    Colors.white,
                                    FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                TextField(
                                  controller: priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    prefixText: "R ",
                                    filled: true,
                                    fillColor: Colors.white10,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),


                                TextField(
  controller: notesController,
  maxLines: 4,
  textCapitalization: TextCapitalization.sentences,
  style: const TextStyle(color: Colors.white),
  decoration: InputDecoration(
    labelText: "Notes (Optional)",
    hintText: "Add any notes about this service...",
    alignLabelWithHint: true,
    filled: true,
    fillColor: Colors.white10,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),
const SizedBox(height: 24),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Kolors.kPrimary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Kolors.kPrimary
                                          .withOpacity(0.7),
                                      disabledForegroundColor: Colors.white,
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: controller.isLoading
                                        ? null
                                        : () async {
                                            final success = await controller
                                                .updateServiceCost(
                                                  costId: cost!.id!,
                                                  cost:
                                                      double.tryParse(
                                                        priceController.text,
                                                      ) ??
                                                      0,
                                                  notes: notesController.text.trim(),
                                                );

                                            if (!context.mounted) return;

                                            if (success) {
                                              await context
                                                  .read<
                                                    GetProviderForServiceController
                                                  >()
                                                  .fetchProviderServices();

                                              if (!context.mounted) return;

                                              Navigator.pop(context, true);
                                            }
                                          },
                                    child: controller.isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            "Save",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );

                  if (updated == true && mounted) {
                    final providerController = context
                        .read<GetProviderForServiceController>();

                    await providerController.fetchProviderServices();

                    final updatedService = providerController.services
                        .firstWhere(
                          (e) => e.id == service.id,
                          orElse: () => service,
                        );

                    setState(() {
                      service = updatedService;
                    });

                    FlushbarService.success(
                      context,
                      "Base price updated successfully.",
                    );
                  }
                },
                actionIcon: Icons.edit_outlined,
                actionTooltip: "Edit pricing",
              ),

              const SizedBox(height: 22),

              _buildServiceGallery(),

              const SizedBox(height: 20),

              _section("Verification", [
                if (service.isAffidavitVerified == true) ...[
                  _tile(Icons.verified_user, "Verification Status", "Verified"),
                ] else if (service.hasUploadedAffidavit == true) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.pending_actions, color: Colors.orange),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Affidavit Pending Verification",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "Your affidavit has been uploaded and is awaiting review by our verification team.",
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "⚠️ Clients will not be able to discover or book your services until your affidavit has been verified.",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.gpp_bad_outlined, color: Colors.red),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Affidavit Required",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "You haven't uploaded an affidavit yet.",
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "⚠️ Clients cannot discover or book your services until an affidavit has been uploaded and verified.",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Kolors.kPrimary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final uploaded = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SPUploadAffidavitScreen(
                                    serviceId: service.id!
                                        .toString(),
                                  ),
                                ),
                              );

                              if (uploaded == true && mounted) {
                                final providerController = context
                                    .read<GetProviderForServiceController>();

                                await providerController
                                    .fetchProviderServices();

                                final updatedService = providerController
                                    .services
                                    .firstWhere(
                                      (e) => e.id == service.id,
                                      orElse: () => service,
                                    );

                                setState(() {
                                  service = updatedService;
                                });

                                FlushbarService.success(
                                  context,
                                  "Affidavit updated successfully.",
                                );
                              }
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text("Upload Affidavit"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ]),

              const SizedBox(height: 32),

              _buildQualifications(),

              const SizedBox(height: 14),

              if (!(service.isPrimary ?? false))
  SizedBox(
    width: double.infinity,
    height: 55,
    child: OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
      ),
      onPressed: () async {
        final confirm = await showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => AppConfirmationDialog(
    icon: Icons.delete_forever_rounded,
    iconColor: Colors.redAccent,
    title: "Remove Linked Service",
    message:
        "Are you sure you want to remove '${service.service?.serviceName ?? "this service"}'?\n\n"
        "This service will no longer be offered to new customers.",
    confirmText: "Remove",
    cancelText: "Keep Service",
    confirmColor: Colors.red,
  ),
);

if (confirm != true || !context.mounted) return;

final controller =
    context.read<DeactivateProviderServiceController>();

final success = await controller.deactivateProviderService(
  providerServiceId: service.id!,
);

if (!context.mounted) return;

if (success) {
  await context
      .read<GetProviderForServiceController>()
      .fetchProviderServices();

  if (!context.mounted) return;

  FlushbarService.success(
    context,
    "Linked service removed successfully.",
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  });
} else {
  FlushbarService.error(
    context,
    controller.errorMessage ??
        "Failed to remove linked service.",
  );
}
      },
      icon: const Icon(Icons.delete_outline),
      label: const Text("Remove Service"),
    ),
  ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceGallery() {
    return Consumer<GetCostOfServiceImagesController>(
      builder: (context, controller, _) {
        // Only skeletonize on the true first load — a refetch after an
        // upload or delete already has cached images, so the grid stays
        // up instead of collapsing to a spinner mid-action.
        if (controller.isLoading && controller.images.isEmpty) {
          return _section(
            "Service Gallery",
            [const ServiceGallerySkeleton()],
          );
        }

        if (controller.error != null && controller.images.isEmpty) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withValues(alpha: .15),
      ),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 42,
        ),
        const SizedBox(height: 10),
        Text(
          controller.error!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

        final images = controller.images;

        return _section(
          "Service Gallery",
          [
           
            if (images.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(.08)),
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white54,
                      size: 46,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "No service images uploaded.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Tap the + button above to upload images.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (_, index) {
                  final image = images[index];

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.black,
                          insetPadding: const EdgeInsets.all(16),
                          child: Stack(
                            children: [
                              InteractiveViewer(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    image.imageUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 12,
                                right: 12,
                                child: Consumer<DeleteCostOfServiceImageController>(
                                  builder: (_, deleteController, __) {
                                    return CircleAvatar(
                                      backgroundColor: Colors.red,
                                      child: IconButton(
                                        icon: deleteController.isLoading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              ),
                                        onPressed: deleteController.isLoading
                                            ? null
                                            : () async {
                                                final confirm = await showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => AppConfirmationDialog(
    icon: Icons.delete_outline,
    iconColor: Colors.redAccent,
    title: "Delete Image",
    message: "Are you sure you want to delete this image?",
    confirmText: "Delete",
    confirmColor: Colors.red,
  ),
);

if (confirm != true) return;

final success = await deleteController.deleteImage(
  imageId: image.id!,
);

if (!context.mounted) return;

if (success) {
  // Close image preview dialog
  Navigator.pop(context);

  await context
      .read<GetCostOfServiceImagesController>()
      .fetchImages(
        service.costOfService!.id!,
        force: true
      );

  if (!context.mounted) return;

  FlushbarService.success(
    context,
    "Image deleted successfully.",
  );
} else {
  FlushbarService.error(
    context,
    deleteController.errorMessage ??
        "Failed to delete image.",
  );
}
                                              },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: image.id ?? index,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          image.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }

                            return Container(
                              color: Colors.white10,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.white10,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
          onAction: () async {
            final result = await FilePicker.pickFiles(
              allowMultiple: true,
              type: FileType.image,
            );

            if (result == null) return;

            final files = result.paths
                .whereType<String>()
                .map((e) => File(e))
                .toList();

            final uploadController = context
                .read<UploadCostOfServiceImagesController>();

            final success = await uploadController.uploadImages(
              costId: service.costOfService!.id!,
              images: files,
            );

            if (!mounted) return;

            if (success) {
              await context
                  .read<GetCostOfServiceImagesController>()
                  .fetchImages(service.costOfService!.id!,
                  force: true);

              FlushbarService.success(context, "Images uploaded successfully.");
            } else {
              FlushbarService.error(
                context,
                uploadController.errorMessage ?? "Failed to upload images.",
              );
            }
          },
          actionIcon: Icons.add_a_photo_outlined,
          actionTooltip: "Add photo",
        );
      },
    );
  }

  Widget _section(
    String title,
    List<Widget> children, {
    VoidCallback? onAction,
    IconData? actionIcon,
    String? actionTooltip,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: appStyle(13, Colors.white70, FontWeight.bold),
                ),
              ),

              if (onAction != null)
                Tooltip(
                  message: actionTooltip ?? "Action",
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Kolors.kPrimary.withOpacity(.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        actionIcon ?? Icons.edit_outlined,
                        color: Kolors.kPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          ...children,
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Kolors.kPrimary),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: appStyle(11, Colors.white54, FontWeight.w500),
                ),

                const SizedBox(height: 4),

                Text(value, style: appStyle(15, Colors.white, FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  String _buttonText(String url) {
    final ext = p.extension(url).toLowerCase();

    switch (ext) {
      case ".pdf":
        return "View PDF";

      case ".jpg":
      case ".jpeg":
      case ".png":
      case ".gif":
      case ".webp":
        return "View Image";

      case ".doc":
      case ".docx":
        return "Open Document";

      default:
        return "View";
    }
  }

  IconData _buttonIcon(String url) {
    final ext = p.extension(url).toLowerCase();

    switch (ext) {
      case ".pdf":
        return Icons.picture_as_pdf;

      case ".doc":
      case ".docx":
        return Icons.description;

      case ".jpg":
      case ".jpeg":
      case ".png":
      case ".gif":
      case ".webp":
        return Icons.image;

      default:
        return Icons.visibility;
    }
  }

  Widget _buildQualifications() {
    return Consumer<GetProviderQualificationController>(
      builder: (context, controller, _) {
        // Only skeletonize on the true first load — a refetch after
        // upload/delete already has cached qualifications, so the list
        // stays up instead of collapsing to a spinner mid-action.
        if (controller.isLoading && controller.qualifications.isEmpty) {
          return _section(
            "Qualifications",
            [const QualificationsSkeleton()],
          );
        }

        if (controller.error != null && controller.qualifications.isEmpty) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withValues(alpha: .15),
      ),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 42,
        ),
        const SizedBox(height: 10),
        Text(
          controller.error!,
          textAlign: TextAlign.center,
          style: appStyle(
            14,
            Colors.white,
            FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

        final qualifications = controller.qualifications;

        return _section(
          "Qualifications",
          [
            
            if (qualifications.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(.08)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 42,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No qualifications uploaded.",
                      style: appStyle(15, Colors.white70, FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Tap the + button above to upload your first qualification.",
                      textAlign: TextAlign.center,
                      style: appStyle(12, Colors.white38, FontWeight.w400),
                    ),
                  ],
                ),
              )
            else
              ...qualifications.map((qualification) {
                final documentUrl = qualification.documentUrl;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(.08)),
                  ),
                  child: Column(
                    children: [
                      _tile(
                        Icons.badge_outlined,
                        "Title",
                        qualification.title ?? "-",
                      ),

                      _tile(
                        Icons.folder_copy_outlined,
                        "Document Type",
                        qualification.documentType ?? "-",
                      ),

                      _tile(
                        Icons.business_outlined,
                        "Issuing Body",
                        qualification.issuingBody ?? "-",
                      ),

                      _tile(
                        Icons.calendar_today_outlined,
                        "Issue Date",
                        qualification.issueDate ?? "-",
                      ),

                      _tile(
                        Icons.event_busy_outlined,
                        "Expiry Date",
                        qualification.expiryDate ?? "No expiry",
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Kolors.kPrimary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed:
                                  documentUrl == null || documentUrl.isEmpty
                                  ? null
                                  : () {
                                      QualificationViewer.open(
                                        context,
                                        documentUrl,
                                      );
                                    },
                              icon: Icon(
                                documentUrl == null || documentUrl.isEmpty
                                    ? Icons.block
                                    : _buttonIcon(documentUrl),
                              ),
                              label: Text(
                                documentUrl == null || documentUrl.isEmpty
                                    ? "Unavailable"
                                    : _buttonText(documentUrl),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Consumer<DeleteProviderQualificationController>(
                            builder: (_, deleteController, __) {
                              return Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: deleteController.isLoading
                                      ? null
                                      : () async {
                                          final confirm = await showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => const AppConfirmationDialog(
    icon: Icons.delete_forever_rounded,
    iconColor: Colors.redAccent,
    title: "Delete Qualification",
    message:
        "Are you sure you want to delete this qualification?\n\nThis action cannot be undone.",
    confirmText: "Delete",
    confirmColor: Colors.red,
  ),
);

if (confirm != true) return;

final success = await deleteController.deleteQualification(
  qualificationId: qualification.id!,
);

if (!context.mounted) return;

if (success) {
  await context
      .read<GetProviderQualificationController>()
      .fetchQualification(
        service.id!,
        force: true
      );

  if (!context.mounted) return;

  FlushbarService.success(
    context,
    "Qualification deleted successfully.",
  );
} else {
  FlushbarService.error(
    context,
    deleteController.errorMessage ??
        "Failed to delete qualification.",
  );
}
                                        },
                                  icon: deleteController.isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.delete_outline),
                                  label: Text(
                                    deleteController.isLoading
                                        ? "Deleting..."
                                        : "Delete",
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
          onAction: () async {
  final proceed = await showDialog<bool>(
    context: context,
    builder: (_) => const AppConfirmationDialog(
      icon: Icons.privacy_tip_outlined,
      iconColor: Colors.orangeAccent,
      title: "Before You Upload",
      message:
          "Qualifications you upload may be shared with potential clients to help verify your experience and build trust.\n\n"
          "Please avoid uploading documents that contain sensitive personal information, such as ID numbers, passport details, banking information, home addresses, or any other confidential data that is not necessary for clients to view.\n\n"
          "You are responsible for ensuring that the documents you upload are appropriate for sharing.",
      confirmText: "I Understand",
      cancelText: "Cancel",
      confirmColor: Kolors.kPrimary,
    ),
  );

  if (proceed != true || !mounted) return;

  final uploaded = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (_) => ChangeNotifierProvider(
      create: (_) => ProviderQualificationController(),
      child: _UploadQualificationSheet(
        providerServiceId: service.service!.serviceId!,
      ),
    ),
  );

  if (kDebugMode) {
    debugPrint("Service ID: ${service.id}");
  }

  if (!mounted || uploaded != true) return;

  await context
      .read<GetProviderQualificationController>()
      .fetchQualification(service.id!,
      force: true);

  if (kDebugMode) {
    debugPrint("ProviderService ID: ${service.id}");
  }

  if (!mounted) return;

  FlushbarService.success(
    context,
    "Qualification uploaded successfully.",
  );
},
          actionIcon: Icons.add_circle_outline,
          actionTooltip: "Add qualification",
        );
      },
    );
  }
}
