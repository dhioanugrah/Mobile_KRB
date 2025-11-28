import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:go_router/go_router.dart';
import 'package:rimba_app/ui/widgets/app_bottom_navbar.dart';



class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoriesSection(db),
            const SizedBox(height: 24),
            _buildMapSection(),
          ],
        ),
      ),
  bottomNavigationBar: const AppBottomNavBar(
    currentTab: AppTab.home,
  ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.black87,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () {
          // TODO: buka drawer / menu kalau mau
        },
      ),
      title: const Text(
        'Home',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE8F5E9),
            child: Icon(
              Icons.eco_rounded,
              color: Colors.green.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // ===================== CATEGORIES + FLORA =====================

  Widget _buildCategoriesSection(AppDatabase db) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + search icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Categories 🌿',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.search_rounded),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Category>>(
          future: db.getAllCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Gagal memuat kategori: ${snapshot.error}'),
              );
            }

            final categories = snapshot.data ?? [];

            if (categories.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Belum ada kategori, tambahkan dari panel admin.'),
              );
            }

            // set default selected category kalau belum ada
            _selectedCategoryId ??= categories.first.id;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // chips kategori
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((c) {
                      final isSelected = c.id == _selectedCategoryId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c.name),
                          selected: isSelected,
                          selectedColor: Colors.green.shade600,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          backgroundColor: const Color(0xFFE8F5E9),
                          onSelected: (_) {
                            setState(() {
                              _selectedCategoryId = c.id;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                // carousel flora
                _buildFloraCarousel(db),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFloraCarousel(AppDatabase db) {
    final categoryId = _selectedCategoryId;
    if (categoryId == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 230,
          child: StreamBuilder<List<FloraTableData>>(
            stream: db.watchFloraByCategory(categoryId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final floras = snapshot.data ?? [];

              if (floras.isEmpty) {
                return const Center(
                  child: Text('Belum ada flora pada kategori ini.'),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: floras.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final flora = floras[index];
                  return _FloraCard(flora: flora);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.go('/categories');
            },

            child: const Text('More'),
          ),
        ),
      ],
    );
  }

  // ===================== MAP SECTION =====================

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Peta KRB',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              'assets/images/krb_map.jpg', // kamu tinggal tambahin file ini di assets
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Tambahkan gambar peta di assets/images/krb_map.jpg',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ===================== BOTTOM NAV =====================

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              icon: Icons.home_rounded,
              isActive: true,
              onTap: () {
                // sudah di home
              },
            ),
            _NavIcon(
              icon: Icons.map_outlined,
              onTap: () {
                // TODO: nanti bisa ke halaman map / moments
              },
            ),
            _NavIcon(
              icon: Icons.add_circle_rounded,
              isHighlighted: true,
              onTap: () {
                // TODO: bisa diarahkan ke tambah moment/flora
              },
            ),
            _NavIcon(
              icon: Icons.menu_book_outlined,
              onTap: () {
                // TODO: ke halaman info / panduan
              },
            ),
            _NavIcon(
              icon: Icons.person_outline_rounded,
              onTap: () {
                // TODO: ke halaman profil user
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FloraCard extends StatelessWidget {
  final FloraTableData flora;

  const _FloraCard({required this.flora});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _buildImage(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            flora.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              // TODO: buka halaman detail flora
            },
            child: const Text(
              'Detail',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (flora.imageUrl != null && flora.imageUrl!.isNotEmpty) {
      return Image.file(
        File(flora.imageUrl!),
        fit: BoxFit.cover,
      );
    }
    // fallback kalau belum ada gambar di DB
    return Image.asset(
      'assets/images/monstera.png',
      fit: BoxFit.cover,
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHighlighted
        ? Colors.green.shade600
        : (isActive ? Colors.green.shade700 : Colors.grey.shade500);

    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: isHighlighted ? 32 : 26,
          color: color,
        ),
      ),
    );
  }
}
