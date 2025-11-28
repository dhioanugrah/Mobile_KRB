// lib/ui/views/moment_detail_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/widgets/app_bottom_navbar.dart';

class MomentDetailView extends StatelessWidget {
  final int momentId;
  final Moment? initialMoment;

  const MomentDetailView({
    super.key,
    required this.momentId,
    this.initialMoment,
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
      body: FutureBuilder<Moment?>(
        future: initialMoment != null
            ? Future.value(initialMoment)
            : db.getMomentById(momentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('Momen tidak ditemukan.'));
          }

          final m = snapshot.data!;
          final date = m.createdAt;
          final tglText =
              '${date.day.toString().padLeft(2, '0')}-'
              '${date.month.toString().padLeft(2, '0')}-'
              '${date.year}';

          final desc = (m.deskripsi ?? '').trim().isEmpty
              ? 'Tidak ada deskripsi.'
              : (m.deskripsi ?? '').trim();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(32),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tglText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    m.tempat,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        desc,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        await db.deleteMomentById(m.id);
                        if (context.mounted) {
                          context.go('/moments');
                        }
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Hapus'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(currentTab: AppTab.library),
    );
  }
}
