import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../theme/app_colors.dart';
import '../widgets/auth_animated_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: AuthAnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RECOVER ACCESS', 
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('Enter your details to receive a secure reset link.', 
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 48),
                  
                  _buildGlassField(
                    controller: _identifierController,
                    label: 'Email, Username or Phone',
                    icon: Icons.security_rounded,
                  ),
                  const SizedBox(height: 48),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await authProvider.resetPassword(_identifierController.text);
                                if (mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      title: const Text('Reset Link Sent', style: TextStyle(fontWeight: FontWeight.w900)),
                                      content: Text('Verification details have been sent to ${_identifierController.text}.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentColor)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Account not found or Reset failed'), backgroundColor: AppColors.error),
                                  );
                                }
                              }
                            }
                          },
                    child: authProvider.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary))
                        : const Text('SEND RESET LINK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Field required' : null,
    );
  }
}
