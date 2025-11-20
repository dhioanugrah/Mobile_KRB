import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/viewmodels/categories_viewmodel.dart';


class CategoriesManagementView extends StatelessWidget {
  const CategoriesManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CategoriesViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        backgroundColor: Colors.green,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.go('/admin'), // Kembali ke halaman admin
  ),
      ),
      body: FutureBuilder<List<Category>>(
        future: vm.categories,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final categoryList = snapshot.data!;
          if (categoryList.isEmpty) return const Center(child: Text('Belum ada kategori.'));

          return ListView.builder(
            itemCount: categoryList.length,
            itemBuilder: (context, index) {
              final category = categoryList[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(category.name),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showCategoryDialog(context, vm, category);
                      } else if (value == 'delete') {
                        vm.deleteCategory(category.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showCategoryDialog(context, vm, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, CategoriesViewModel vm, Category? category) {
    final nameController = TextEditingController(text: category?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nama Kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              if (category == null) {
                await vm.addCategory(nameController.text);
              } else {
                await vm.updateCategory(category.id, nameController.text);
              }

              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
