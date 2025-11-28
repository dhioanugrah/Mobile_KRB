import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/widgets/app_bottom_navbar.dart';


class CategoryFloraListView extends StatelessWidget {
  final int categoryId;
  final Category? category; // dikirim lewat extra (optional)

  const CategoryFloraListView({
    super.key,
    required this.categoryId,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {},
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
      body: StreamBuilder<List<FloraTableData>>(
        stream: db.watchFloraByCategory(categoryId),
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final floras = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // header hijau kategori
              Container(
                width: double.infinity,
                color: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(
                    category?.name ?? 'Kategori',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                color: const Color(0xFFEDEDED),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${floras.length} plants',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: kalau mau bikin filter lanjutan
                      },
                      icon: const Icon(Icons.filter_list_rounded, size: 18),
                      label: const Text('Filter'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (floras.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('Belum ada flora di kategori ini.'),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: floras.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final flora = floras[index];
                      return _FloraListItem(flora: flora);
                    },
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: AppTab.values.first,
      ),
    );
  }
}

class _FloraListItem extends StatelessWidget {
  final FloraTableData flora;

  const _FloraListItem({required this.flora});

  @override
  Widget build(BuildContext context) {
    final description = (flora.description ?? '').trim();
    final preview = description.isEmpty
        ? 'Tidak ada deskripsi.'
        : (description.length > 120
            ? '${description.substring(0, 120)}...'
            : description);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flora.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              onPressed: () {
                context.go(
                  '/flora/${flora.id}',
                  extra: flora,
                );
              },
              child: const Text(
                'DETAIL',
                style: TextStyle(fontSize: 11),
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
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      'assets/images/plant_placeholder.png',
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 70,
        height: 70,
        color: const Color(0xFFE0E0E0),
        alignment: Alignment.center,
        child: const Icon(Icons.local_florist),
      ),
    );
  }
}
