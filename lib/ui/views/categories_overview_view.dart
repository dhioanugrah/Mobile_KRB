import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/widgets/app_bottom_navbar.dart';

class CategoriesOverviewView extends StatelessWidget {
  const CategoriesOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'RIMBA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.eco_rounded,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Category>>(
                future: db.getAllCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Gagal memuat kategori: ${snapshot.error}'),
                    );
                  }

                  final categories = snapshot.data ?? [];

                  if (categories.isEmpty) {
                    return const Center(
                      child: Text('Belum ada kategori, tambahkan dari admin.'),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.80,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final c = categories[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          context.go(
                            '/categories/${c.id}',
                            extra: c,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _categoryImageFor(c),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: AppTab.values.first,
      ),
    );
  }

  /// sementara: mapping nama kategori ke asset (kalau ada),
  /// kalau belum ada ya pakai placeholder.
  Widget _categoryImageFor(Category c) {
    // contoh mapping sederhana, nanti kamu bisa ganti sesuai asset yang kamu punya
    final lower = c.name.toLowerCase();
    String? asset;

    if (lower.contains('endemi')) {
      asset = 'assets/images/categories/endemi.png';
    } else if (lower.contains('anggrek')) {
      asset = 'assets/images/categories/anggrek.png';
    } else if (lower.contains('pohon')) {
      asset = 'assets/images/categories/pohon.png';
    }

    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Icon(
        Icons.local_florist,
        color: Colors.green.shade400,
        size: 32,
      ),
    );
  }
}
