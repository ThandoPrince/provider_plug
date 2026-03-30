import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/get_provider_for_service_controller.dart';
import 'package:flutter_application_2/common/controller/registration/fetch_auth_controller.dart';
import 'package:flutter_application_2/screens/onboarding/Widgets/back_exit_widget.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_2/common/controller/auth/sp_login_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/auth/widgets/login_overlay.dart';

class SPLoginScreen extends StatefulWidget {
  const SPLoginScreen({super.key});

  @override
  State<SPLoginScreen> createState() => _SPLoginScreenState();
}

class _SPLoginScreenState extends State<SPLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _goToCostStep(String email) async {
  final providerServiceController = context.read<GetProviderForServiceController>();

  final fetched = await providerServiceController.fetchProviderServices(email);

  if (!mounted) return;

  if (!fetched) {
    _showErrorSnackBar(
      providerServiceController.error ??
          'Failed to fetch provider services.',
    );
    return;
  }

  final targetService =
      providerServiceController.firstServiceWithoutCost ??
      providerServiceController.primaryService ??
      providerServiceController.firstService;

  final serviceId = targetService?.serviceId;

  if (serviceId == null) {
    _showErrorSnackBar('No valid service found for cost setup.');
    return;
  }

  context.go('/providers/$email/services/$serviceId/cost');
}

 Future<void> _handleLogin(SPLoginController controller) async {
  if (!_formKey.currentState!.validate()) return;

  final email = _emailController.text.trim().toLowerCase();

  final success = await controller.login(
    email: email,
    password: _passwordController.text,
  );

  if (!mounted) return;

  if (!success) {
    if (controller.errorMessage != null) {
      _showErrorSnackBar(controller.errorMessage!);
    }
    return;
  }

  final profileController = context.read<FetchAuthController>();
  final profileSuccess = await profileController.fetchProfile(email);

  if (!mounted) return;

  if (!profileSuccess) {
    _showErrorSnackBar(
      profileController.error ?? "Failed to fetch profile details.",
    );
    return;
  }

  final profile = profileController.profile;
  final status = profile?.isProfileCompleted;

  SuccessOverlay.show(
    context,
    message: "Welcome back! We are preparing your workspace.",
  );

  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  switch (status) {
    case 'in-details':
      context.go('/sp_patch/$email');
      break;

    case 'in-address':
      context.go('/sp_address_document/$email');
      break;

    case 'in-services':
      context.go('/sp_select_service/$email');
      break;

    case 'in-cost':
      await _goToCostStep(email);
      break;

    case 'completed':
      context.go('/entrypoint');
      break;

    default:
      _showErrorSnackBar("Unknown profile status.");
  }
}

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExit(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
          child: SafeArea(
            child: Consumer<SPLoginController>(
              builder: (context, controller, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 40),
                                const Icon(
                                  Icons.shield_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 24),
                                _buildHeader(),
                                const SizedBox(height: 48),
      
                                _buildLabel("EMAIL ADDRESS"),
                                _buildInputContainer(
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Kolors.kDark),
                                    decoration: _inputDecoration(
                                      "Enter registered email",
                                      Icons.email_outlined,
                                    ),
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                            ? "Email is required"
                                            : null,
                                  ),
                                ),
      
                                const SizedBox(height: 20),
      
                                _buildLabel("PASSWORD"),
                                _buildInputContainer(
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscureText,
                                    style:
                                        const TextStyle(color: Kolors.kDark),
                                    decoration: _inputDecoration(
                                      "••••••••",
                                      Icons.lock_outline_rounded,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscureText = !_obscureText),
                                      ),
                                    ),
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                            ? "Password is required"
                                            : null,
                                  ),
                                ),
      
                                const Spacer(),
      
                                _buildLoginButton(controller),
                                const SizedBox(height: 24),
                                _buildRegisterLink(),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome Back,",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Log in to manage your services",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(SPLoginController controller) {
    return InkWell(
      onTap: controller.isLoading ? null : () => _handleLogin(controller),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Kolors.kPrimary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Kolors.kPrimary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
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
                  "Login to Workspace",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: TextButton(
        onPressed: () => context.push('/auth_registration'),
        child: RichText(
          text: TextSpan(
            text: "New to the platform? ",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
            children: const [
              TextSpan(
                text: "Register Now",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Kolors.kPrimary),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: child,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}