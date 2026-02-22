import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/sp_login_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SPLoginScreen extends StatefulWidget {
  const SPLoginScreen({super.key});

  @override
  State<SPLoginScreen> createState() => _SPLoginScreenState();
}

class _SPLoginScreenState extends State<SPLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // --- Signature Brand Gradient ---
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
  child: Consumer<SPLoginController>(
    builder: (context, loginController, _) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Form(
                key: _formKey,
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // --- Header ---
                      const Icon(Icons.shield_rounded,
                          color: Colors.white, size: 48),
                      const SizedBox(height: 24),

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

                      const SizedBox(height: 48),

                      // --- Email ---
                      _buildLabel("EMAIL ADDRESS"),
                      _buildInputContainer(
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Kolors.kDark),
                          decoration: const InputDecoration(
                            hintText: "Enter your registered email",
                            hintStyle: TextStyle(
                                color: Colors.grey, fontSize: 14),
                            prefixIcon: Icon(Icons.email_outlined,
                                color: Kolors.kPrimary),
                            border: InputBorder.none,
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? "Required"
                                  : null,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- Password ---
                      _buildLabel("PASSWORD"),
                      _buildInputContainer(
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Kolors.kDark),
                          decoration: const InputDecoration(
                            hintText: "••••••••",
                            hintStyle: TextStyle(
                                color: Colors.grey, fontSize: 14),
                            prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: Kolors.kPrimary),
                            border: InputBorder.none,
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? "Required"
                                  : null,
                        ),
                      ),

                      if (loginController.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            loginController.errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],

                      // 🔥 This pushes everything below to the bottom
                      const Spacer(),

                      // --- Login Button ---
                      _buildLoginButton(loginController),

                      const SizedBox(height: 20),

                      // --- Registration Link ---
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              context.push('/auth_registration'),
                          child: RichText(
                            text: TextSpan(
                              text: "New to the platform? ",
                              style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(0.7)),
                              children: const [
                                TextSpan(
                                  text: "Register Now",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration:
                                        TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

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
    );
  }

  // --- UI Helpers for Consistency ---

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
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: child,
      ),
    );
  }

  Widget _buildLoginButton(SPLoginController controller) {
    return InkWell(
      onTap: controller.isLoading
          ? null
          : () async {
              if (_formKey.currentState!.validate()) {
                final success = await controller.login(
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                );
                if (success) context.go('/entrypoint');
              }
            },
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
              ? const CircularProgressIndicator(color: Colors.white)
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
}