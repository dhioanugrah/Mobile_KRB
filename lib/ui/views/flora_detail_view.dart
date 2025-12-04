import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/widgets/app_bottom_navbar.dart';
import 'package:rimba_app/ui/viewmodels/found_viewmodel.dart';

class FloraDetailView extends StatefulWidget {
  final int floraId;
  final FloraTableData? initialFlora;

  const FloraDetailView({
    super.key,
    required this.floraId,
    this.initialFlora,
  });

  @override
  State<FloraDetailView> createState() => _FloraDetailViewState();
}

class _FloraDetailViewState extends State<FloraDetailView> {
  late final AppDatabase _db;
  late final FoundViewModel _foundVm;

  bool _isFound = false;
  bool _isCheckingFound = true; // untuk disable tombol saat cek awal

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _db = context.read<AppDatabase>();
    _foundVm = FoundViewModel(_db);
    _checkInitialFound();
  }

  Future<void> _checkInitialFound() async {
    final already = await _foundVm.check(widget.floraId);
    if (!mounted) return;
    setState(() {
      _isFound = already;
      _isCheckingFound = false;
    });
  }

  Future<void> _toggleFound(FloraTableData flora) async {
    setState(() {
      _isCheckingFound = true;
    });

    if (_isFound) {
      // sudah ditemukan -> hapus dari temuan
      await _foundVm.remove(flora.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dihapus dari Temuan')),
      );
    } else {
      // belum ditemukan -> tambah ke temuan
      await _foundVm.add(flora.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ditambahkan ke Temuan!')),
      );
      // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      // Tambahkan baris ini supaya otomatis pindah halaman
      GoRouter.of(context).go('/found');
      return; // hentikan fungsi supaya tidak berubah state dua kali
      // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    }

    if (!mounted) return;
    setState(() {
      _isFound = !_isFound;
      _isCheckingFound = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        foregroundColor: Colors.black87,
      ),
      body: FutureBuilder<FloraTableData?>(
        future: widget.initialFlora != null
            ? Future.value(widget.initialFlora)
            : _db.getFloraById(widget.floraId),
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
                      onPressed:
                          _isCheckingFound ? null : () => _toggleFound(flora),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFound
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                        foregroundColor: _isFound ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      icon: Icon(
                        _isFound
                            ? Icons.bookmark_remove_rounded
                            : Icons.bookmark_add_outlined,
                      ),
                      label: Text(
                        _isFound ? 'Hapus dari Temuan' : 'Tambah ke Temuan',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(
        currentTab: AppTab.home,
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
