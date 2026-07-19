import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ===== DATA MODEL =====

class EventData {
  final String title;
  final String location;
  final String openedDate;
  final bool isClosed;
  final Color bannerColor;
  final IconData bannerIcon;

  EventData({
    required this.title,
    required this.location,
    required this.openedDate,
    required this.isClosed,
    required this.bannerColor,
    required this.bannerIcon,
  });
}

// ===== EVENT SCREEN =====

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<EventData> _events = [
    EventData(
      title: 'PUND: Sumatera Barat',
      location: 'PEC 2nd Floor',
      openedDate: '30 Nov 2024, 17:00',
      isClosed: true,
      bannerColor: const Color(0xFFE8A838),
      bannerIcon: Icons.restaurant,
    ),
    EventData(
      title: 'Carnival Concert 2024',
      location: 'PUCC',
      openedDate: '30 Dec 2024, 13:00',
      isClosed: true,
      bannerColor: const Color(0xFF9C27B0),
      bannerIcon: Icons.music_note,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // ===== APP BAR =====
              Container(
                color: const Color(0xFFD6E9F8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text('Event',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                          const Spacer(),
                          // Ticket icon button
                          IconButton(
                            icon: const Icon(Icons.airplane_ticket_outlined, color: Color(0xFF4097FC), size: 26),
                            onPressed: () => Navigator.push(
                              context,
                              PageRouteBuilder(transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero, pageBuilder: (_, __, ___) => const TicketScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tab bar
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF4097FC),
                      unselectedLabelColor: Colors.black45,
                      indicatorColor: const Color(0xFF4097FC),
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      tabs: const [
                        Tab(text: 'Upcoming Events'),
                        Tab(text: 'Past Events'),
                      ],
                    ),
                  ],
                ),
              ),

              // ===== CONTENT =====
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEventGrid(_events),
                    _buildEventGrid([]), // past events kosong untuk sekarang
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventGrid(List<EventData> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No events found', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) => _EventCard(data: events[index]),
    );
  }
}

// ===== EVENT CARD =====

class _EventCard extends StatelessWidget {
  final EventData data;
  const _EventCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEventDetail(context, data),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 110,
                width: double.infinity,
                color: data.bannerColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.15,
                      child: Icon(data.bannerIcon, size: 80, color: Colors.white),
                    ),
                    Icon(data.bannerIcon, size: 48, color: Colors.white.withOpacity(0.9)),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Colors.black45),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(data.location,
                            style: const TextStyle(fontSize: 11, color: Colors.black45),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(data.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),

                  const SizedBox(height: 8),

                  // Opened date
                  Text('Opened: ${data.openedDate}',
                      style: const TextStyle(fontSize: 10, color: Colors.black45)),

                  const SizedBox(height: 6),

                  // Status badge
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: data.isClosed
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data.isClosed ? 'Closed' : 'Open',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: data.isClosed ? Colors.red : Colors.green,
                        ),
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

  void _showEventDetail(BuildContext context, EventData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Banner
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Container(
                height: 160,
                width: double.infinity,
                color: data.bannerColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(opacity: 0.15, child: Icon(data.bannerIcon, size: 140, color: Colors.white)),
                    Icon(data.bannerIcon, size: 72, color: Colors.white.withOpacity(0.9)),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(data.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: data.isClosed ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data.isClosed ? 'Closed' : 'Open',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: data.isClosed ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.black45),
                      const SizedBox(width: 6),
                      Text(data.location, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.black45),
                      const SizedBox(width: 6),
                      Text('Opened: ${data.openedDate}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    ]),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: data.isClosed ? null : () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4097FC),
                          disabledBackgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          data.isClosed ? 'Registration Closed' : 'Register Now',
                          style: TextStyle(
                            color: data.isClosed ? Colors.grey : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== TICKET SCREEN =====

class TicketScreen extends StatelessWidget {
  const TicketScreen({Key? key}) : super(key: key);

  // Nanti dari API — sekarang kosong
  final List<Map<String, dynamic>> _tickets = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: const Color(0xFFD6E9F8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('Tickets',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: const Text('Active E-tickets',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
              ),

              Expanded(
                child: _tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.confirmation_number_outlined,
                                  size: 44, color: Colors.grey.shade300),
                            ),
                            const SizedBox(height: 16),
                            Text('No tickets found',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                            const SizedBox(height: 6),
                            Text('Your e-tickets will appear here',
                                style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tickets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ticket = _tickets[index];
                          return _TicketCard(ticket: ticket);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== TICKET CARD =====

class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Top color strip
          Container(
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF4097FC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4097FC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.airplane_ticket, color: Color(0xFF4097FC)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticket['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(ticket['date'] ?? '', style: const TextStyle(color: Colors.black45, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.qr_code, color: Color(0xFF4097FC), size: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
