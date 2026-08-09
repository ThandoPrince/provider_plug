import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/registration/upload_provider_service_affidavit_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadAffidavitScreen extends StatefulWidget {

  final String serviceId;

  const UploadAffidavitScreen({
   
    required this.serviceId,
    super.key,
  });

  @override
  State<UploadAffidavitScreen> createState() => _UploadAffidavitScreenState();
}

class _UploadAffidavitScreenState extends State<UploadAffidavitScreen> {
  File? _selectedFile;
  String? _selectedFileName;


  static final String _baseUrl = dotenv.env['MEDIA_BASE_URL']!;
  static final String affidavitTemplateUrl =
      "$_baseUrl/static/templates/PLUG_Service_Provider_Declaration_One_Page.pdf";

@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    context.read<UploadProviderServiceAffidavitController>().reset();
  });
}      

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _downloadTemplate() async {
    final uri = Uri.parse(affidavitTemplateUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      FlushbarService.error(
        context,
        "Couldn't open the affidavit template.",
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _onSubmit() async {
    if (_selectedFile == null) {
      FlushbarService.error(
        context,
        "Please select your affidavit file first.",
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final providerServiceId = int.tryParse(widget.serviceId);
    if (providerServiceId == null) {
      FlushbarService.error(
        context,
        "Invalid service reference. Please go back and try again.",
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final controller = context.read<UploadProviderServiceAffidavitController>();

    final success = await controller.uploadAffidavit(
      providerServiceId: providerServiceId,
      affidavit: _selectedFile!,
    );

    if (!mounted) return;

    if (success) {
      context.go('/providers/services/${widget.serviceId}/cost');
    } else {
      FlushbarService.error(
        context,
        controller.errorMessage ??
            controller.response?['message'] as String? ??
            "Affidavit upload failed. Please try again.",
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<UploadProviderServiceAffidavitController>();

    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Kolors.kOffWhite, size: 20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildHeader(theme),
                      const SizedBox(height: 28),
                      _buildTemplateCard(),
                      const SizedBox(height: 24),
                      _buildUploadArea(),
                      if (controller.hasError) ...[
                        const SizedBox(height: 16),
                        _buildInlineError(controller.errorMessage!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _buildFooterAction(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Step 2 of 2",
          style: theme.textTheme.labelMedium?.copyWith(
            color: Kolors.kOffWhite.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Submit Your Affidavit",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Kolors.kOffWhite,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Upload a signed copy of the affidavit to verify your identity and skills.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Kolors.kOffWhite.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: Kolors.kOffWhite, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Need the template?",
              style: TextStyle(color: Kolors.kOffWhite.withOpacity(0.9), fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _downloadTemplate,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text(
              "Download",
              style: TextStyle(color: Kolors.kPrimary, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    final hasFile = _selectedFile != null;

    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? Kolors.kPrimary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.check_circle_rounded : Icons.upload_file_rounded,
              color: hasFile ? Kolors.kPrimary : Colors.grey[400],
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              hasFile ? _selectedFileName! : "Tap to select a file",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Kolors.kDark,
                fontWeight: hasFile ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              hasFile ? "Tap to choose a different file" : "PDF, JPG or PNG",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterAction(UploadProviderServiceAffidavitController controller) {
    final isLoading = controller.isLoading;

    return Container(
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: isLoading ? null : _onSubmit,
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: isLoading ? Colors.grey : Kolors.kPrimary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Submit Affidavit",
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
}