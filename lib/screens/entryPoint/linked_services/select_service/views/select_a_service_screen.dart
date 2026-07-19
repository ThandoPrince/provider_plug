import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/registration/link_service_controller.dart';
import 'package:flutter_application_2/common/models/models/services_model.dart';
import 'package:flutter_application_2/common/services/fetch_approved_services_api.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

class SelectAServiceScreen extends StatefulWidget {
  

  const SelectAServiceScreen({ super.key});

  @override
  State<SelectAServiceScreen> createState() => _SelectAServiceScreenState();
}

class _SelectAServiceScreenState extends State<SelectAServiceScreen> {
  late Future<List<ServiceModel>> _servicesFuture;
  List<ServiceModel> _allServices = [];
  List<ServiceModel> _filteredServices = [];
  ServiceModel? _selectedService;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final _linkController = context.read<LinkServiceController>();



    _servicesFuture = FetchApprovedServicesApi.fetchApprovedServices();
    _searchController.addListener(_filterServices);
  }

  Future<void> _handleRefresh() async {
  setState(() {
    _servicesFuture = FetchApprovedServicesApi.fetchApprovedServices();
  });
}

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = _allServices
          .where((s) => s.serviceName!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Kolors.kDark,
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
    
        child: FutureBuilder<List<ServiceModel>>( 
          future: _servicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Kolors.kPrimary),
              );
            }
            if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            const Text("Couldn't load services", style: TextStyle(color: Colors.white)),
            TextButton(
              onPressed: _handleRefresh,
              child: const Text("Retry", style: TextStyle(color: Kolors.kPrimary)),
            )
          ],
        ),
      );
    }
    
            _allServices = snapshot.data ?? [];
            if (_searchController.text.isEmpty && _filteredServices.isEmpty) {
              _filteredServices = _allServices;
            }
    
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Section ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Step 1 of 2",
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Kolors.kOffWhite,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "What service do you provide?",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Kolors.kOffWhite,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Select your primary expertise to continue.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Kolors.kOffWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
              
                  // --- Pro Search Bar ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Kolors.kDark.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        cursorColor: Kolors.kPrimary,
                        decoration: const InputDecoration(
                          hintText: "Search services...",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
              
                  // --- Service Grid/List ---
                  Expanded(
                    child: _filteredServices.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            itemCount: _filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = _filteredServices[index];
                              final isSelected = _selectedService == service;
              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_selectedService == service) {
                                      _selectedService = null;
                                    } else {
                                      _selectedService = service;
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Kolors.kPrimary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: Kolors.kPrimary.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service.serviceName ?? "",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: Kolors.kDark,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            _buildRiskBadge(
                                              service.riskLevel ?? "LOW",
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_off_rounded,
                                        color: isSelected
                                            ? Kolors.kPrimary
                                            : Colors.grey[300],
                                        size: 26,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
              
                  _buildStickyFooter(theme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    Color color = Colors.green;
    if (risk == "MEDIUM") color = Colors.orange;
    if (risk == "HIGH") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        risk,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStickyFooter(ThemeData theme) {
    final controller = context.watch<LinkServiceController>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Kolors.kDark.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
      child: InkWell(
        onTap: controller.isLoading ? null : () async { // Prevent double-tap
          if (_selectedService != null) {
            final success = await controller.submitService(
              
              serviceName: _selectedService!.serviceName!,
              serviceGroupId: _selectedService!.serviceGroup?.groupId,
            );

            if (success && mounted) {
              context.go('/providers/add/${_selectedService!.serviceId}/cost');
            } else if (mounted) {
              // SHOW ACTUAL ERROR MESSAGE FROM CONTROLLER
              FlushbarHelper.createError(
                message: controller.message ?? 'Failed to link service',
              ).show(context);
            }
          } else {
            context.push('/sp_add_a_service');
          }
        },
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: controller.isLoading ? Colors.grey : Kolors.kPrimary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: controller.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    _selectedService != null ? "Continue" : "I don't see my service",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    ),
  );
}
    
  

  Widget _buildEmptyState() {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No matching services found",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
