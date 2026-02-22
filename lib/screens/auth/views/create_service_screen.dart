import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/registration/fetch_service_group_by_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart'; // Using your kcolors
import 'package:provider/provider.dart'; 
import 'package:flutter_application_2/common/services/link_service_api.dart';
import 'package:go_router/go_router.dart';

class CreateServiceScreen extends StatefulWidget {
  final String providerEmail;

  const CreateServiceScreen({required this.providerEmail, super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  String? _selectedGroupId;
  final _serviceNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FetchServiceGroupByController>().fetchGroups();
    });
  }

  void _onSubmit() async {
    if (_selectedGroupId == null || _serviceNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a group and enter a name")),
      );
      return;
    }

    final response = await LinkServiceApi().submitService(
      email: widget.providerEmail,
      serviceName: _serviceNameController.text,
      serviceGroupId: _selectedGroupId!,
    );

    if (response['success'] == true) {
      // Success styling usually involves a cool dialog or snackbar
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        child: Consumer<FetchServiceGroupByController>(
          builder: (context, controller, _) {
            if (controller.loading) {
              return const Center(child: CircularProgressIndicator(color: Kolors.kOffWhite));
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
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
                      style: theme.textTheme.bodyMedium?.copyWith(color: Kolors.kOffWhite.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 32),

                    // --- Form Fields ---
                    _buildInputLabel("SERVICE CATEGORY GROUP"),
                    _buildDropdownContainer(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGroupId,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                          style: const TextStyle(color: Kolors.kDark, fontSize: 16),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Select a group",
                          ),
                          items: controller.groups.map((g) => DropdownMenuItem(
                            value: g.groupId,
                            child: Text(g.name.toString()),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedGroupId = v),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    _buildInputLabel("WHAT DO YOU CALL YOUR SERVICE?"),
                    _buildInputContainer(
                      child: TextFormField(
                        controller: _serviceNameController,
                        style: const TextStyle(color: Kolors.kDark),
                        cursorColor: Kolors.kPrimary,
                        decoration: const InputDecoration(
                          hintText: "e.g. Specialized Piano Tuning",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- Submission Button ---
                    _buildSubmitButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- UI Helper Components to keep code clean & pro ---

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(color: Kolors.kOffWhite, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildSubmitButton() {
    return InkWell(
      onTap: _onSubmit,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Kolors.kPrimary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Submit for Review",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}