import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ===== DATA MODEL =====

enum LibraryType { journal, proceeding }

class LibraryItem {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final String year;
  final String category;
  final LibraryType type;
  final String fileSize;
  final String abstract;

  LibraryItem({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.year,
    required this.category,
    required this.type,
    required this.fileSize,
    required this.abstract,
  });
}

// ===== SCREEN =====

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isSearching = false;

  // Simulated dynamic data — nanti dari API
  final List<LibraryItem> _allItems = [
    LibraryItem(
      id: 'J001',
      title: 'Quantum Optics and Photon Entanglement in Modern Physics',
      author: 'Ahmad Fauzi, Rini Hartati',
      publisher: 'Journal of Physics Indonesia',
      year: '2024',
      category: 'Physics',
      type: LibraryType.journal,
      fileSize: '2.4 MB',
      abstract: 'This paper explores the fundamental principles of quantum optics, focusing on photon entanglement and its implications for modern quantum communication systems.',
    ),
    LibraryItem(
      id: 'J002',
      title: 'Atmospheric Boundary Layer Dynamics Over Tropical Regions',
      author: 'Siti Nurhaliza, Budi Santoso',
      publisher: 'Indonesian Meteorological Journal',
      year: '2024',
      category: 'Atmospheric Science',
      type: LibraryType.journal,
      fileSize: '3.1 MB',
      abstract: 'An investigation into boundary layer dynamics in tropical climates, with emphasis on heat flux and moisture exchange between the surface and atmosphere.',
    ),
    LibraryItem(
      id: 'J003',
      title: 'Viscous Flow Simulation in Microfluidic Channels',
      author: 'Donny Kurniawan',
      publisher: 'Applied Fluid Mechanics Review',
      year: '2023',
      category: 'Fluid Mechanics',
      type: LibraryType.journal,
      fileSize: '1.8 MB',
      abstract: 'A computational study of viscous flow behavior in microfluidic channels using finite element analysis, with experimental validation.',
    ),
    LibraryItem(
      id: 'J004',
      title: 'Machine Learning Applications in Remote Sensing Data',
      author: 'Clara Aurelia, Hannan R.',
      publisher: 'Journal of Geoinformatics',
      year: '2023',
      category: 'Geophysics',
      type: LibraryType.journal,
      fileSize: '4.2 MB',
      abstract: 'This research applies convolutional neural networks to classify land cover types using multispectral remote sensing imagery.',
    ),
    LibraryItem(
      id: 'P001',
      title: 'International Conference on Physics and Applied Sciences 2024',
      author: 'Various Authors',
      publisher: 'ICPAS 2024 Proceedings',
      year: '2024',
      category: 'Conference',
      type: LibraryType.proceeding,
      fileSize: '12.7 MB',
      abstract: 'Proceedings of the 2024 International Conference on Physics and Applied Sciences, featuring 48 peer-reviewed papers across multiple tracks.',
    ),
    LibraryItem(
      id: 'P002',
      title: 'Seminar Nasional Fisika Universitas 2023',
      author: 'Various Authors',
      publisher: 'SNF Universitas 2023',
      year: '2023',
      category: 'Seminar',
      type: LibraryType.proceeding,
      fileSize: '8.3 MB',
      abstract: 'Kumpulan makalah dari Seminar Nasional Fisika yang membahas perkembangan terkini dalam bidang fisika terapan dan pendidikan fisika.',
    ),
    LibraryItem(
      id: 'P003',
      title: 'Workshop on Computational Physics Methods',
      author: 'Gunawan Sjahriza et al.',
      publisher: 'Physics Department Publication',
      year: '2023',
      category: 'Workshop',
      type: LibraryType.proceeding,
      fileSize: '5.6 MB',
      abstract: 'Workshop proceedings covering numerical methods, Monte Carlo simulation, molecular dynamics, and finite difference techniques in computational physics.',
    ),
  ];

  List<LibraryItem> _getFiltered(LibraryType type) {
    return _allItems.where((item) {
      final matchType = item.type == type;
      final matchQuery = _query.isEmpty ||
          item.title.toLowerCase().contains(_query.toLowerCase()) ||
          item.author.toLowerCase().contains(_query.toLowerCase()) ||
          item.category.toLowerCase().contains(_query.toLowerCase());
      return matchType && matchQuery;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
              // ===== HEADER =====
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
                          if (!_isSearching)
                            const Text('Library',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                          if (_isSearching)
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Search title, author, category...',
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                  border: InputBorder.none,
                                ),
                                onChanged: (v) => setState(() => _query = v),
                              ),
                            ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              _isSearching ? Icons.close : Icons.search,
                              color: const Color(0xFF4097FC),
                            ),
                            onPressed: () {
                              setState(() {
                                _isSearching = !_isSearching;
                                if (!_isSearching) {
                                  _query = '';
                                  _searchController.clear();
                                }
                              });
                            },
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
                      tabs: [
                        Tab(text: 'E-Journal (${_getFiltered(LibraryType.journal).length})'),
                        Tab(text: 'Proceedings (${_getFiltered(LibraryType.proceeding).length})'),
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
                    _buildList(_getFiltered(LibraryType.journal), LibraryType.journal),
                    _buildList(_getFiltered(LibraryType.proceeding), LibraryType.proceeding),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<LibraryItem> items, LibraryType type) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type == LibraryType.journal ? Icons.article_outlined : Icons.menu_book_outlined,
              size: 64, color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              _query.isEmpty ? 'No items available' : 'No results for "$_query"',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _LibraryCard(
        item: items[index],
        onTap: () => _showDetail(context, items[index]),
      ),
    );
  }

  void _showDetail(BuildContext context, LibraryItem item) {
    final isJournal = item.type == LibraryType.journal;
    final color = isJournal ? const Color(0xFF4097FC) : const Color(0xFF7B1FA2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  children: [
                    // Type + ID badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(isJournal ? Icons.article : Icons.menu_book, size: 13, color: color),
                              const SizedBox(width: 4),
                              Text(isJournal ? 'E-Journal' : 'Proceeding',
                                  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(item.id,
                            style: const TextStyle(fontSize: 12, color: Colors.black38)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(item.year,
                              style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Title
                    Text(item.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.4)),

                    const SizedBox(height: 10),

                    // Author
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: Colors.black38),
                        const SizedBox(width: 4),
                        Expanded(child: Text(item.author,
                            style: const TextStyle(fontSize: 13, color: Colors.black54))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.business_outlined, size: 14, color: Colors.black38),
                        const SizedBox(width: 4),
                        Expanded(child: Text(item.publisher,
                            style: const TextStyle(fontSize: 13, color: Colors.black54))),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 12),

                    // Abstract
                    const Text('Abstract',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Text(item.abstract,
                        style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.6)),

                    const SizedBox(height: 24),

                    // Category + size row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(item.category,
                              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                        ),
                        const Spacer(),
                        const Icon(Icons.picture_as_pdf_outlined, size: 14, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text('PDF • ${item.fileSize}',
                            style: const TextStyle(fontSize: 12, color: Colors.black38)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Download button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.download, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('Downloading: ${item.title}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              backgroundColor: color,
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_outlined, size: 20),
                        label: Text('Download PDF (${item.fileSize})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== LIBRARY CARD =====

class _LibraryCard extends StatelessWidget {
  final LibraryItem item;
  final VoidCallback onTap;
  const _LibraryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isJournal = item.type == LibraryType.journal;
    final color = isJournal ? const Color(0xFF4097FC) : const Color(0xFF7B1FA2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isJournal ? Icons.article_outlined : Icons.menu_book_outlined,
                  color: color, size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + year
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.category,
                              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        Text(item.year,
                            style: const TextStyle(fontSize: 11, color: Colors.black38)),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(item.title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87, height: 1.3),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),

                    // Author
                    Text(item.author,
                        style: const TextStyle(fontSize: 11, color: Colors.black45),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),

                    // Bottom row
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_outlined, size: 12, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(item.fileSize,
                            style: const TextStyle(fontSize: 11, color: Colors.black38)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.download_outlined, size: 12, color: color),
                              const SizedBox(width: 4),
                              Text('Download',
                                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
