import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final services = [
      _ServiceData(
        name: 'Academic Bureau',
        description: 'Academic administration, transcripts, study plans, and student records.',
        icon: Icons.school_outlined,
        color: const Color(0xFF4097FC),
        contacts: [
          _ContactData(Icons.email_outlined, 'Email', 'academic@university.ac.id'),
          _ContactData(Icons.phone_outlined, 'Phone', '+62 21 1234 5678'),
          _ContactData(Icons.access_time_outlined, 'Office Hours', 'Mon–Fri, 08:00–16:00'),
          _ContactData(Icons.location_on_outlined, 'Location', 'Admin Building, 1st Floor'),
        ],
      ),
      _ServiceData(
        name: 'Finance & Tuition',
        description: 'Tuition fees, scholarships, payment issues, and financial aid.',
        icon: Icons.account_balance_outlined,
        color: const Color(0xFF2E7D32),
        contacts: [
          _ContactData(Icons.email_outlined, 'Email', 'finance@university.ac.id'),
          _ContactData(Icons.phone_outlined, 'Phone', '+62 21 1234 5679'),
          _ContactData(Icons.access_time_outlined, 'Office Hours', 'Mon–Fri, 08:00–15:00'),
          _ContactData(Icons.location_on_outlined, 'Location', 'Admin Building, 2nd Floor'),
        ],
      ),
      _ServiceData(
        name: 'IT & Helpdesk',
        description: 'System issues, account access, eCampus, and technical support.',
        icon: Icons.computer_outlined,
        color: const Color(0xFF7B1FA2),
        contacts: [
          _ContactData(Icons.email_outlined, 'Email', 'helpdesk@university.ac.id'),
          _ContactData(Icons.phone_outlined, 'Phone', '+62 21 1234 5680'),
          _ContactData(Icons.access_time_outlined, 'Office Hours', 'Mon–Fri, 08:00–17:00'),
          _ContactData(Icons.location_on_outlined, 'Location', 'IT Center, Ground Floor'),
        ],
      ),
      _ServiceData(
        name: 'Student Affairs',
        description: 'Student organizations, counseling, campus life, and welfare.',
        icon: Icons.people_outline,
        color: const Color(0xFFE65100),
        contacts: [
          _ContactData(Icons.email_outlined, 'Email', 'studentaffairs@university.ac.id'),
          _ContactData(Icons.phone_outlined, 'Phone', '+62 21 1234 5681'),
          _ContactData(Icons.access_time_outlined, 'Office Hours', 'Mon–Fri, 08:00–16:00'),
          _ContactData(Icons.location_on_outlined, 'Location', 'Student Center, 1st Floor'),
        ],
      ),
      _ServiceData(
        name: 'Library',
        description: 'Book loans, digital resources, study rooms, and research assistance.',
        icon: Icons.local_library_outlined,
        color: const Color(0xFF00838F),
        contacts: [
          _ContactData(Icons.email_outlined, 'Email', 'library@university.ac.id'),
          _ContactData(Icons.phone_outlined, 'Phone', '+62 21 1234 5682'),
          _ContactData(Icons.access_time_outlined, 'Office Hours', 'Mon–Sat, 07:00–20:00'),
          _ContactData(Icons.location_on_outlined, 'Location', 'Library Building, All Floors'),
        ],
      ),
      _ServiceData(
        name: 'Health Center',
        description: 'Medical consultations, health certificates, and campus clinic services.',
        icon: Icons.local_hospital_outlined,
        color: const Color(0xFFC62828),
        contacts: [
          _ContactData(Icons.email_outlined, 'Email', 'health@university.ac.id'),
          _ContactData(Icons.phone_outlined, 'Phone', '+62 21 1234 5683'),
          _ContactData(Icons.access_time_outlined, 'Office Hours', 'Mon–Fri, 08:00–16:00'),
          _ContactData(Icons.location_on_outlined, 'Location', 'Health Center Building'),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // ===== HEADER =====
              Container(
                color: const Color(0xFFD6E9F8),
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text('Support',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4097FC).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4097FC).withOpacity(0.2)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline, color: Color(0xFF4097FC), size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tap a service to view contact details and office information.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF4097FC)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== LIST =====
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _ServiceTile(
                    data: services[index],
                    onTap: () => _showServiceDetail(context, services[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceDetail(BuildContext context, _ServiceData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Service title row
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(data.icon, color: data.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.name,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 2),
                      Text(data.description,
                          style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text('Contact Information',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54)),
            const SizedBox(height: 12),

            // Contact items
            ...data.contacts.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: data.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(c.icon, color: data.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.label,
                          style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(c.value,
                          style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ===== SERVICE TILE =====

class _ServiceTile extends StatelessWidget {
  final _ServiceData data;
  final VoidCallback onTap;
  const _ServiceTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: data.color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(data.description,
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: data.color.withOpacity(0.5), size: 22),
          ],
        ),
      ),
    );
  }
}

// ===== DATA MODELS =====

class _ServiceData {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<_ContactData> contacts;

  _ServiceData({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.contacts,
  });
}

class _ContactData {
  final IconData icon;
  final String label;
  final String value;
  _ContactData(this.icon, this.label, this.value);
}
