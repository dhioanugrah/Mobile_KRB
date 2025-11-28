import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/viewmodels/found_viewmodel.dart';
import 'package:rimba_app/ui/widgets/app_bottom_navbar.dart';

class FoundDetailView extends StatelessWidget {
  final FloraTableData flora;

  const FoundDetailView({super.key, required this.flora});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoundViewModel(context.read<AppDatabase>()),
      child: Consumer<FoundViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black87,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 120,
                  backgroundImage: flora.imageUrl != null
                      ? FileImage(File(flora.imageUrl!))
                      : const AssetImage('assets/images/placeholder.png')
                          as ImageProvider,
                ),
                const SizedBox(height: 24),
                Text(
                  flora.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      flora.description ?? '',
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await vm.remove(flora.id);
                      context.go('/found');
                    },
                    icon: const Icon(Icons.bookmark_remove_outlined),
                    label: const Text("Hapus"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                )
              ],
            ),
            bottomNavigationBar:
                const AppBottomNavBar(currentTab: AppTab.found),
          );
        },
      ),
    );
  }
}
