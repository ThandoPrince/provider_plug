// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:flutter_application_2/common/utils/kcolors.dart';


// class ResetPasswordScreen extends StatefulWidget {
//   const ResetPasswordScreen({super.key});

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _identifierController =
//       TextEditingController();
//   final TextEditingController _passwordController =
//       TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   bool _useEmail = true;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void dispose() {
//     _identifierController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _resetPassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     final controller =
//         context.read<ResetPasswordController>();

//     final success = await controller.resetPassword(
//       identifier: _identifierController.text.trim(),
//       newPassword: _passwordController.text.trim(),
//       useEmail: _useEmail,
//     );

//     if (!mounted) return;

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Password reset successfully"),
//           backgroundColor: Colors.green,
//         ),
//       );

//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             controller.errorMessage ??
//                 "Failed to reset password",
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ResetPasswordController>(
//       builder: (context, controller, _) {
//         return Scaffold(
//           backgroundColor: Kolors.kPrimary,
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             title: const Text("Reset Password"),
//           ),
//           body: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 20),

//                     const Text(
//                       "Forgot your password?",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     Text(
//                       "Reset your password using your email address or mobile number.",
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(.8),
//                       ),
//                     ),

//                     const SizedBox(height: 30),

//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius:
//                             BorderRadius.circular(16),
//                       ),
//                       child: Column(
//                         children: [
//                           RadioListTile<bool>(
//                             title: const Text(
//                                 "Reset with Email"),
//                             value: true,
//                             groupValue: _useEmail,
//                             onChanged: (value) {
//                               setState(() {
//                                 _useEmail = value!;
//                                 _identifierController.clear();
//                               });
//                             },
//                           ),
//                           RadioListTile<bool>(
//                             title: const Text(
//                                 "Reset with Mobile Number"),
//                             value: false,
//                             groupValue: _useEmail,
//                             onChanged: (value) {
//                               setState(() {
//                                 _useEmail = value!;
//                                 _identifierController.clear();
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     TextFormField(
//                       controller: _identifierController,
//                       keyboardType: _useEmail
//                           ? TextInputType.emailAddress
//                           : TextInputType.phone,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         hintText: _useEmail
//                             ? "Email Address"
//                             : "Mobile Number",
//                         border: OutlineInputBorder(
//                           borderRadius:
//                               BorderRadius.circular(16),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null ||
//                             value.trim().isEmpty) {
//                           return _useEmail
//                               ? "Email is required"
//                               : "Mobile number is required";
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 20),

//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: _obscurePassword,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         hintText: "New Password",
//                         border: OutlineInputBorder(
//                           borderRadius:
//                               BorderRadius.circular(16),
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword =
//                                   !_obscurePassword;
//                             });
//                           },
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null ||
//                             value.length < 8) {
//                           return "Password must be at least 8 characters";
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 20),

//                     TextFormField(
//                       controller:
//                           _confirmPasswordController,
//                       obscureText:
//                           _obscureConfirmPassword,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         hintText: "Confirm Password",
//                         border: OutlineInputBorder(
//                           borderRadius:
//                               BorderRadius.circular(16),
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureConfirmPassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscureConfirmPassword =
//                                   !_obscureConfirmPassword;
//                             });
//                           },
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value !=
//                             _passwordController.text) {
//                           return "Passwords do not match";
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 30),

//                     SizedBox(
//                       width: double.infinity,
//                       height: 55,
//                       child: ElevatedButton(
//                         onPressed: controller.isLoading
//                             ? null
//                             : _resetPassword,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               Colors.black,
//                           shape:
//                               RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(
//                                     16),
//                           ),
//                         ),
//                         child: controller.isLoading
//                             ? const CircularProgressIndicator(
//                                 color: Colors.white,
//                               )
//                             : const Text(
//                                 "Reset Password",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight:
//                                       FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }