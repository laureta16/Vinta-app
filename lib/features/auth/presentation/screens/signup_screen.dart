import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:vinta/core/providers/auth_provider.dart';
import 'package:vinta/theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Senior Interactive Background (Animated Gradient)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentColor.withOpacity(0.05),
                  Colors.white,
                  AppColors.secondaryColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(height: 32),
                    const Text('Create Elite\nAccount', 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 36, letterSpacing: -1.5, height: 1.1)),
                    const SizedBox(height: 12),
                    const Text('Join the premium fashion community.', 
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    const SizedBox(height: 48),
                    
                    _buildTextField(_usernameController, 'Username', Icons.person_outline_rounded),
                    const SizedBox(height: 20),
                    _buildTextField(_emailController, 'Email Address', Icons.email_outlined),
                    const SizedBox(height: 20),
                    
                    // Unified Phone Picker
                    IntlPhoneField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      initialCountryCode: 'AL',
                      onChanged: (phone) => _phoneNumber = phone.completeNumber,
                    ),
                    const SizedBox(height: 8),

                    _buildTextField(_passwordController, 'Password', Icons.lock_outline_rounded, isPassword: true),
                    const SizedBox(height: 40),
                    
                    if (authProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await authProvider.signup(
                                _usernameController.text,
                                _emailController.text,
                                _passwordController.text,
                                _phoneNumber,
                              );
                              if (mounted) _showSuccessDialog(context, _emailController.text);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Signup Failed: $e'), backgroundColor: AppColors.error),
                              );
                            }
                          }
                        },
                        child: const Text('CREATE ACCOUNT'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: (value) => value!.isEmpty ? 'Required field' : null,
    );
  }

  void _showSuccessDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Column(
          children: [
            Icon(Icons.mark_email_read_rounded, color: AppColors.success, size: 64),
            SizedBox(height: 16),
            Text('REAL EMAIL SENT!', textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('A production welcome email has been sent to:', textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(email, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.accentColor)),
            const SizedBox(height: 20),
            const Text('Please check your actual inbox (and spam folder) to verify your account.', 
              textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back home
            },
            child: const Text('LET\'S EXPLORE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
