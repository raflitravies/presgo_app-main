import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // ===== BACKGROUND GRADIENT =====
            Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4097FC), Color(0xFF6DB8FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Curved white bottom of header
            Positioned(
              top: 230,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text('Profile',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),

                  // Avatar + name
                  const SizedBox(height: 8),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: const Icon(Icons.person, size: 50, color: Color(0xFF4097FC)),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4097FC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Dummy User',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '000202211111',
                      style: TextStyle(fontSize: 13, color: Colors.white, letterSpacing: 1),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ===== INFO CARDS =====
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: Column(
                        children: [
                          // Info card
                          _buildCard(children: [
                            _infoTile(Icons.email_outlined, 'Email', 'dummy.user@example.ac.id'),
                            _separator(),
                            _infoTile(Icons.badge_outlined, 'Student ID', '000202211111'),
                            _separator(),
                            _infoTile(Icons.phone_outlined, 'Phone Number', '+6281252567679'),
                            _separator(),
                            _infoTile(Icons.flag_outlined, 'Citizenship', 'ID – Indonesia'),
                            _separator(),
                            _infoTile(Icons.cake_outlined, 'Birth Date', '29 Oct 2000'),
                            _separator(),
                            _infoTile(Icons.location_on_outlined, 'Province', 'ID-JK-Jakarta Raya'),
                            _separator(),
                            _infoTile(Icons.person_outline, 'Gender', 'Male'),
                            _separator(),
                            _infoTile(Icons.auto_awesome_outlined, 'Religion', 'Islam'),
                          ]),

                          const SizedBox(height: 16),

                          // Reset Password
                          _buildCard(children: [
                            InkWell(
                              onTap: () => showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Reset Password'),
                                  content: const Text('A password reset link will be sent to your email.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Send', style: TextStyle(color: Color(0xFF4097FC))),
                                    ),
                                  ],
                                ),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                child: Row(
                                  children: const [
                                    Icon(Icons.lock_reset, color: Color(0xFF4097FC), size: 22),
                                    SizedBox(width: 14),
                                    Text('Reset Password',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF4097FC))),
                                    Spacer(),
                                    Icon(Icons.chevron_right, color: Colors.black26),
                                  ],
                                ),
                              ),
                            ),
                          ]),

                          const SizedBox(height: 12),

                          // Logout
                          _buildCard(
                            color: const Color(0xFFFFF5F5),
                            children: [
                              InkWell(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Text('Logout'),
                                    content: const Text('Are you sure you want to logout?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // close dialog
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const LoginScreen()),
                                            (route) => false,
                                          );
                                        },
                                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.logout, color: Colors.red, size: 22),
                                      SizedBox(width: 14),
                                      Text('Logout',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.red)),
                                      Spacer(),
                                      Icon(Icons.chevron_right, color: Colors.red),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children, Color color = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF4097FC).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF4097FC)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _separator() => const Divider(height: 1, indent: 50, color: Color(0xFFF0F0F0));
}
