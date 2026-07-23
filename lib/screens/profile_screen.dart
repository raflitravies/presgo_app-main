import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      if (authProvider.isStudent) {
        profileProvider.loadStudentProfile();
      } else if (authProvider.isLecturer) {
        profileProvider.loadLecturerProfile();
      }
    });
  }

  void _showEditDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    String currentName = authProvider.user?.fullName ?? '';
    String currentPhone = authProvider.isStudent
        ? profileProvider.studentProfile?.phone ?? ''
        : profileProvider.lecturerProfile?.phone ?? '';

    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          Consumer<ProfileProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isUpdating
                  ? null
                  : () async {
                Navigator.pop(ctx);
                final success = await provider.updateProfile(
                  nameController.text.trim(),
                  phoneController.text.trim(),
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Profile updated!' : provider.errorMessage ?? 'Failed'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) {
                  if (authProvider.isStudent) profileProvider.loadStudentProfile();
                  else if (authProvider.isLecturer) profileProvider.loadLecturerProfile();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4097FC)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF4097FC)),
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar & name card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05))],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFF4097FC).withOpacity(0.15),
                    child: user?.photoUrl != null
                        ? ClipOval(child: Image.network(user!.photoUrl!, fit: BoxFit.cover, width: 88, height: 88))
                        : Text(
                      user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF4097FC)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? '-',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.nimNip ?? '-',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4097FC).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role ?? '-',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4097FC)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Information',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? '-'),
                  _buildInfoRow(Icons.phone_outlined, 'Phone',
                      authProvider.isStudent
                          ? profileProvider.studentProfile?.phone ?? '-'
                          : profileProvider.lecturerProfile?.phone ?? '-'),
                  if (authProvider.isStudent && profileProvider.studentProfile != null) ...[
                    _buildInfoRow(Icons.account_balance_outlined, 'Faculty',
                        profileProvider.studentProfile!.facultyName),
                    _buildInfoRow(Icons.school_outlined, 'Department',
                        profileProvider.studentProfile!.departmentName),
                    _buildInfoRow(Icons.calendar_today_outlined, 'Batch Year',
                        '${profileProvider.studentProfile!.batchYear}'),
                    _buildInfoRow(Icons.format_list_numbered, 'Current Semester',
                        'Semester ${profileProvider.studentProfile!.currentSemester}'),
                    _buildInfoRow(Icons.verified_outlined, 'Status',
                        profileProvider.studentProfile!.academicStatus),
                  ] else if (authProvider.isLecturer && profileProvider.lecturerProfile != null) ...[
                    _buildInfoRow(Icons.account_balance_outlined, 'Faculty',
                        profileProvider.lecturerProfile!.facultyName),
                    _buildInfoRow(Icons.school_outlined, 'Department',
                        profileProvider.lecturerProfile!.departmentName),
                    if (profileProvider.lecturerProfile!.academicTitle != null)
                      _buildInfoRow(Icons.workspace_premium_outlined, 'Academic Title',
                          profileProvider.lecturerProfile!.academicTitle!),
                    if (profileProvider.lecturerProfile!.specialization != null)
                      _buildInfoRow(Icons.biotech_outlined, 'Specialization',
                          profileProvider.lecturerProfile!.specialization!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Actions card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05))],
              ),
              child: Column(
                children: [
                  _buildActionRow(
                    Icons.lock_outline,
                    'Change Password',
                    Colors.blue,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildActionRow(
                    Icons.logout,
                    'Logout',
                    Colors.red,
                        () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Logout', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        await authProvider.logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4097FC)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.black38)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
            const Spacer(),
            Icon(Icons.chevron_right, size: 20, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}