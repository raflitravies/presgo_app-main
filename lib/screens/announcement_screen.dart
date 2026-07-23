import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/announcement_provider.dart';
import '../models/announcement_model.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnnouncementProvider>(context, listen: false).loadAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Announcements',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.campaign_outlined, size: 64, color: Colors.black26),
                  SizedBox(height: 16),
                  Text('No announcements yet',
                      style: TextStyle(color: Colors.black54, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.announcements.length,
            itemBuilder: (context, index) {
              final a = provider.announcements[index];
              return _buildAnnouncementCard(a);
            },
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel a) {
    final categoryColor = _getCategoryColor(a.category);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AnnouncementDetailScreen(announcement: a)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (a.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: categoryColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      a.category!,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: categoryColor),
                    ),
                  ),
                const Spacer(),
                if (a.publishedAt != null)
                  Text(
                    _formatDate(a.publishedAt!),
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              a.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              a.content,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (a.createdByName != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 13, color: Colors.black38),
                  const SizedBox(width: 4),
                  Text(
                    a.createdByName!,
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'ACADEMIC':
        return Colors.blue;
      case 'FINANCIAL':
        return Colors.green;
      case 'GENERAL':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateTimeStr;
    }
  }
}

// ===================================================================
// DETAIL SCREEN
// ===================================================================

class AnnouncementDetailScreen extends StatelessWidget {
  final AnnouncementModel announcement;
  const AnnouncementDetailScreen({Key? key, required this.announcement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(announcement.category);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Announcement',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & date
            Row(
              children: [
                if (announcement.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: categoryColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      announcement.category!,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: categoryColor),
                    ),
                  ),
                const Spacer(),
                if (announcement.publishedAt != null)
                  Text(
                    _formatDate(announcement.publishedAt!),
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              announcement.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            // Author
            if (announcement.createdByName != null)
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: Colors.black38),
                  const SizedBox(width: 4),
                  Text(
                    'By ${announcement.createdByName}',
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            // Content
            Text(
              announcement.content,
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
            ),
            if (announcement.expiresAt != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Expires: ${_formatDate(announcement.expiresAt!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'ACADEMIC':
        return Colors.blue;
      case 'FINANCIAL':
        return Colors.green;
      case 'GENERAL':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateTimeStr;
    }
  }
}