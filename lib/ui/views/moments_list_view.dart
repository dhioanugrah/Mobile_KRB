import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/viewmodels/moments_viewmodel.dart';
import 'package:rimba_app/ui/widgets/app_bottom_navbar.dart';

class MomentsListView extends StatelessWidget {
  const MomentsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MomentsViewModel>(
      create: (context) {
        final db = context.read<AppDatabase>();
        final vm = MomentsViewModel(db);
        vm.loadMoments();
        return vm;
      },
      child: Consumer<MomentsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'MOMEN',
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
            body: _buildBody(vm, context),
            bottomNavigationBar:
                const AppBottomNavBar(currentTab: AppTab.library),
          );
        },
      ),
    );
  }

  Widget _buildBody(MomentsViewModel vm, BuildContext context) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(child: Text('Terjadi kesalahan: ${vm.errorMessage}'));
    }

    if (vm.moments.isEmpty) {
      return const Center(
        child: Text('Belum ada momen. Tambah lewat tombol + di bawah.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: vm.moments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final m = vm.moments[index];
        final date = m.createdAt;
        final tglText = '${date.day.toString().padLeft(2, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '${date.year}';

        final desc = (m.deskripsi ?? '').trim();
        final preview = desc.isEmpty
            ? 'Tidak ada deskripsi.'
            : (desc.length > 80 ? '${desc.substring(0, 80)}...' : desc);

        return InkWell(
          onTap: () {
            context.go(
              '/moments/${m.id}',
              extra: m,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tglText,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  m.tempat,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
