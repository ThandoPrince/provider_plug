import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/controller/auth/get_provider_for_service_controller.dart';
import 'package:flutter_application_2/common/controller/registration/fetch_service_group_by_controller.dart';
import 'package:flutter_application_2/common/services/a_link_service_api_.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_confirmation_dialog.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/screens/entryPoint/linked_services/select_service/views/cost_of_a_service_screen.dart';
import 'package:provider/provider.dart';
 // Direct API import
import 'package:go_router/go_router.dart';

class CreateAServiceScreen extends StatefulWidget {
  const CreateAServiceScreen({super.key});

  @override
  State<CreateAServiceScreen> createState() => _CreateAServiceScreenState();
}

class _CreateAServiceScreenState extends State<CreateAServiceScreen> {
  String? _selectedGroupId;
  final _serviceNameController = TextEditingController();
  bool _isSubmitting = false; // Local loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FetchServiceGroupByController>().fetchGroups();
    });
  }

  void _onSubmit() async {
  if (_selectedGroupId == null ||
      _serviceNameController.text.trim().isEmpty) {
    HapticFeedback.vibrate();

    FlushbarService.error(
      context,
      'Please select a category and provide a service name.',
    );
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    final response = await ALinkServiceApi.submitService(
      serviceName: _serviceNameController.text.trim(),
      serviceGroupId: _selectedGroupId!,
    );

    if (!mounted) return;

    if (response['success'] == true &&
        response['service'] != null) {
      final serviceId = response['service']['service_id'];
      final status = response['status'];

      if (status == 'linked_existing') {
        FlushbarService.warning(
          context,
          "We found an existing category for this! Linking now...",
        );
      } else if (status == 'requires_review') {
        _showSuccessDialog(serviceId);
        return;
      }

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CreateACostOfServiceScreen(
            serviceId: serviceId,
          ),
        ),
      );

      if (result == true && mounted) {
        context
          .read<GetProviderForServiceController>()
          .fetchProviderServices();
        Navigator.pop(context, true);
      }
    } else {
      FlushbarService.error(
        context,
        response['message'] ??
            "Could not create service. Please try again.",
      );
    }
  } catch (e) {
    FlushbarService.error(
      context,
      "A connection error occurred. Please check your internet.",
    );
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}

  void _showSuccessDialog(int serviceId) async {
  final proceed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AppConfirmationDialog(
      icon: Icons.mark_email_read_outlined,
      iconColor: Kolors.kPrimary,
      title: "Service Creation Request Sent",
      message:
          "Thank you! Our team will review your service. You can now proceed to add the cost of your service.",
      confirmText: "OK",
      cancelText: null,
      confirmColor: Kolors.kPrimary,
    ),
  );

  if (proceed != true || !mounted) return;
  context
          .read<GetProviderForServiceController>()
          .fetchProviderServices();

  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => CreateACostOfServiceScreen(
        serviceId: serviceId,
      ),
    ),
  );

  if (result == true && mounted) {
    context
            .read<GetProviderForServiceController>()
            .fetchProviderServices();
    Navigator.pop(context, true);
  }
}
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
  canPop: false,
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
              // Expanded forces the scrollable content to take up available space
              Expanded(
                child: Consumer<FetchServiceGroupByController>(
                  builder: (context, controller, _) {
                    if (controller.loading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Kolors.kOffWhite),
                      );
                    }
      
                    return SafeArea(
                      bottom: false,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(theme),
                            const SizedBox(height: 32),
                            _buildForm(controller),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // The Button is now outside the Expanded, pinning it to the bottom
              _buildFooterAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.transparent),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: _isSubmitting ? null : _onSubmit,
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: Kolors.kPrimary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: _isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Submit for Review",
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

  // --- UI Helpers (Headers and Labels) ---
  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Can't find your service?",
          style: theme.textTheme.labelMedium?.copyWith(
            color: Kolors.kOffWhite.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Suggest a New Service",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Kolors.kOffWhite,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Tell us what you do. Our team will review and add it to our approved list.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Kolors.kOffWhite.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // In your _buildForm method, update the dropdown decoration
  Widget _buildForm(FetchServiceGroupByController controller) {
    // Add an error state if categories fail to load
    if (controller.groups.isEmpty && !controller.loading) {
      return Center(
        child: TextButton.icon(
          onPressed: () => controller.fetchGroups(),
          icon: const Icon(Icons.refresh, color: Kolors.kOffWhite),
          label: const Text(
            "Retry loading categories",
            style: TextStyle(color: Kolors.kOffWhite),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel("SERVICE CATEGORY GROUP"),
        _buildDropdownContainer(
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _selectedGroupId,
              isExpanded: true, // Prevents overflow for long names
              dropdownColor: Colors.white,
              items: controller.groups
                  .map(
                    (g) => DropdownMenuItem(
                      value: g.groupId,
                      child: Text(
                        g.name.toString(),
                        style: const TextStyle(
                          color: Kolors.kDark,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedGroupId = v),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Select a group",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildInputLabel("WHAT DO YOU CALL YOUR SERVICE?"),
        _buildInputContainer(
          child: TextFormField(
            controller: _serviceNameController,
            textCapitalization: TextCapitalization.words, // Better UX for names
            style: const TextStyle(color: Kolors.kDark),
            decoration: const InputDecoration(
              hintText: "e.g. Specialized Piano Tuning",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
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
      ),
    ),
  );
  Widget _buildDropdownContainer({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
  Widget _buildInputContainer({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}
