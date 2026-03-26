import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          // Account Section
          _buildSectionHeader('ACCOUNT'),
          _buildTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            subtitle: auth.user?.email ?? '',
            onTap: () => Navigator.pop(context),
          ),
          _buildTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () => _showComingSoon(context),
          ),
          _buildTile(
            icon: Icons.security_rounded,
            title: 'Privacy',
            subtitle: 'Manage your data',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(height: 32),

          // Preferences Section
          _buildSectionHeader('PREFERENCES'),
          _buildTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Push & in-app alerts',
            onTap: () => _showComingSoon(context),
          ),
          _buildTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _showComingSoon(context),
          ),
          _buildTile(
            icon: Icons.location_on_outlined,
            title: 'Location',
            subtitle: 'Albania',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(height: 32),

          // Support Section
          _buildSectionHeader('SUPPORT'),
          _buildTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            subtitle: 'FAQs and guides',
            onTap: () => _showComingSoon(context),
          ),
          _buildTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => _showComingSoon(context),
          ),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _showComingSoon(context),
          ),
          _buildTile(
            icon: Icons.info_outline_rounded,
            title: 'About Vinta',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAbout(context),
          ),
          const Divider(height: 32),

          // Danger Zone
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out?'),
                    content: const Text('You will need to sign in again.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await auth.logout();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.1),
                foregroundColor: AppColors.error,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('SIGN OUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.5,
              color: AppColors.textSecondary)),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mediumGray),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!'), duration: Duration(seconds: 1)),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Vinta',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Vinta. Premium Fashion Marketplace.',
    );
  }
}
