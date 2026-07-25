import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'admin_dashboard_screen.dart';
import 'staff_dashboard_screen.dart';
import 'lecturer_dashboard_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool isFirstLogin;
  const ChangePasswordScreen({Key? key, this.isFirstLogin = false}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog('Warning', 'Please fill in all password fields.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog('Validation Error', 'New password and confirmation do not match.');
      return;
    }

    if (newPassword.length < 6) {
      _showErrorDialog('Validation Error', 'New password must be at least 6 characters.');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.changePassword(
      oldPassword,
      newPassword,
    );

    if (!mounted) return;

    if (success) {
      // Alert Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      final user = authProvider.user;
      Widget destination = const HomeScreen();
      if (user?.role == 'ADMIN') {
        destination = const AdminDashboardScreen();
      } else if (user?.role == 'STAFF') {
        destination = const StaffDashboardScreen();
      } else if (user?.role == 'LECTURER') {
        destination = const LecturerDashboardScreen();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    } else {

      final errorMsg = authProvider.errorMessage ?? 'Failed to change password. Please try again.';
      _showErrorDialog('Change Password Failed', errorMsg);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isFirstLogin
          ? null
          : AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isFirstLogin) ...[
                const SizedBox(height: 20),
                const Text(
                  'Welcome to PresGO!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please change your password before continuing.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),
              ],
              _buildPasswordField('Current Password', _oldPasswordController),
              const SizedBox(height: 12),
              _buildPasswordField('New Password', _newPasswordController),
              const SizedBox(height: 12),
              _buildPasswordField('Confirm New Password', _confirmPasswordController),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text('Change Password', style: TextStyle(color: Colors.white)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}