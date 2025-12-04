import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/viewmodels/found_viewmodel.dart';
import 'package:rimba_app/ui/widgets/app_bottom_navbar.dart';

class FoundDetailView extends StatelessWidget {
  final FloraTableData flora;

  const FoundDetailView({
    super.key,
    required this.flora,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final foundVm = FoundViewModel(db);

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
              context.go('/found');
            }
          },
        ),
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: _buildImage(flora),
              ),
              const SizedBox(height: 24),
              Text(
                flora.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                (flora.description ?? '').trim().isEmpty
                    ? 'Belum ada deskripsi untuk flora ini.'
                    : flora.description!.trim(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await foundVm.remove(flora.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dihapus dari Temuan'),
                      ),
                    );
                    context.go('/found'); // balik ke list temuan
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.bookmark_remove_rounded),
                  label: const Text('Hapus dari Temuan'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(
        currentTab: AppTab.found,
      ),
    );
  }

  Widget _buildImage(FloraTableData flora) {
    if (flora.imageUrl != null && flora.imageUrl!.isNotEmpty) {
      return Image.file(
        File(flora.imageUrl!),
        width: 220,
        height: 220,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      'assets/images/plant_placeholder.png',
      width: 220,
      height: 220,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 220,
        height: 220,
        color: const Color(0xFFE0E0E0),
        alignment: Alignment.center,
        child: const Icon(Icons.local_florist, size: 48),
      ),
    );
  }
}
