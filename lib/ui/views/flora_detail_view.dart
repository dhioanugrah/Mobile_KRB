import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/widgets/app_bottom_navbar.dart';
// Update the import path below if the file exists elsewhere, for example:
import 'package:rimba_app/ui/viewmodels/found_viewmodel.dart';
// Or, if the file does not exist, create 'lib/ui/viewmodels/found_view_model.dart' with the required FoundViewModel class.


class FloraDetailView extends StatelessWidget {
  final int floraId;
  final FloraTableData? initialFlora;

  const FloraDetailView({
    super.key,
    required this.floraId,
    this.initialFlora,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: FutureBuilder<FloraTableData?>(
        future: initialFlora != null
            ? Future.value(initialFlora)
            : db.getFloraById(floraId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('Data flora tidak ditemukan.'));
          }

          final flora = snapshot.data!;

          final description = (flora.description ?? '').trim();
          final text = description.isEmpty
              ? 'Belum ada deskripsi untuk flora ini.'
              : description;

          return SingleChildScrollView(
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
                    text,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
onPressed: () async {
  final vm = FoundViewModel(context.read<AppDatabase>());
  final already = await vm.check(flora.id);

  if (!already) {
    await vm.add(flora.id);
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Ditambahkan ke Temuan!')),
  );
},

                      icon: const Icon(Icons.bookmark_border_rounded),
                      label: const Text('Ditemukan'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: AppTab.values.first,
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
