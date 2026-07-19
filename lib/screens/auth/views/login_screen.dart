import 'package:flutter/foundation.dart';
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
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  // Loose phone check: digits, optional leading +, optional spaces/dashes,
  // at least 7 digits total. Intentionally permissive since we're not
  // enforcing a specific country format here — the backend validates.
  static final RegExp _phonePattern = RegExp(r'^\+?[\d\s\-]{7,15}$');

  bool get _looksLikePhone {
    final value = _identifierController.text.trim();
    return value.isNotEmpty && _phonePattern.hasMatch(value) && !value.contains('@');
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _goToCostStep(String identifier) async {
    final providerServiceController = context.read<GetProviderForServiceController>();

    final fetched = await providerServiceController.fetchProviderServices(identifier);

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

    context.go('/providers/$identifier/services/$serviceId/cost');
  }

  Future<void> _handleLogin(SPLoginController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final rawInput = _identifierController.text.trim();
    // Only lowercase email-style input — lowercasing a phone number is a
    // no-op for digits but this keeps intent explicit and avoids mangling
    // any future alphanumeric identifier formats.
    final identifier = rawInput.contains('@') ? rawInput.toLowerCase() : rawInput;

    final success = await controller.login(
      email: identifier,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!success) {
      if (controller.errorMessage != null) {
        _showErrorSnackBar(controller.errorMessage!);
      }
      return;
    }

    if (!mounted) return;

    SuccessOverlay.show(
      context,
      message: "Welcome back! We are preparing your workspace.",
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    if (kDebugMode) {
      print(controller.user?.data?.isProfileCompleted);
    }

    // NOTE: downstream routes (below) are built with `identifier` in the
    // path, e.g. '/sp_patch/$identifier'. If those routes/screens expect
    // the user's email specifically (not whatever identifier they logged
    // in with), the backend response should return the canonical email
    // so we route with that instead — check controller.user?.data for it.
    switch (controller.user?.data?.isProfileCompleted) {
      case 'in-details':
        context.go('/sp_patch/$identifier');
        break;

      case 'in-address':
        context.go('/sp_address_document/$identifier');
        break;

      case 'in-services':
        context.go('/sp_select_service/$identifier');
        break;

      case 'in-cost':
        await _goToCostStep(identifier);
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
      
                                _buildLabel("EMAIL OR MOBILE NUMBER"),
                                _buildInputContainer(
                                  child: TextFormField(
                                    controller: _identifierController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Kolors.kDark),
                                    decoration: _inputDecoration(
                                      "Enter email or mobile number",
                                      _looksLikePhone
                                          ? Icons.phone_outlined
                                          : Icons.email_outlined,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                    validator: (value) {
                                      final trimmed = value?.trim() ?? '';
                                      if (trimmed.isEmpty) {
                                        return "Email or mobile number is required";
                                      }
                                      final isEmail = _emailPattern.hasMatch(trimmed);
                                      final isPhone = _phonePattern.hasMatch(trimmed);
                                      if (!isEmail && !isPhone) {
                                        return "Enter a valid email or mobile number";
                                      }
                                      return null;
                                    },
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
      
                                const SizedBox(height: 20),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      context.push('/reset_password');
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),
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