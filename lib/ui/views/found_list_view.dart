import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/core/router/app_router.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/viewmodels/found_viewmodel.dart';
import 'package:rimba_app/ui/widgets/app_bottom_navbar.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class FoundListView extends StatelessWidget {
  const FoundListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoundViewModel(context.read<AppDatabase>()),
      child: Consumer<FoundViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              centerTitle: true,
              title: const Text(
                "Temuan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.eco_rounded, color: Colors.green),
                )
              ],
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.foundList.isEmpty
                    ? const Center(child: Text("Belum ada flora ditemukan"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: vm.foundList.length,
                        itemBuilder: (context, index) {
                          final f = vm.foundList[index];
                          return GestureDetector(
                            onTap: () => context.go(
                              '/found/${f.id}',
                              extra: f,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: f.imageUrl != null
                                        ? Image.file(
                                            File(f.imageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/images/placeholder.png',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  f.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            bottomNavigationBar:
                const AppBottomNavBar(currentTab: AppTab.found),
          );
        },
      ),
    );
  }
}
