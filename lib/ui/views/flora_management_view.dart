import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/viewmodels/flora_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

class FloraManagementView extends StatelessWidget {
  const FloraManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FloraViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Flora'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),// Kembali ke halaman sebelumnya
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pilih kategori utama
            FutureBuilder<List<Category>>(
              future: vm.categories,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final categories = snapshot.data!;
                return DropdownButton<int>(
                  value: vm.selectedCategoryId,
                  hint: const Text("Pilih Kategori"),
                  isExpanded: true,
                  items: categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (value) => vm.setCategory(value),
                );
              },
            ),
            const SizedBox(height: 12),
            // Daftar flora
            Expanded(
              child: vm.selectedCategoryId == null
                  ? const Center(child: Text('Pilih kategori dulu'))
                  : StreamBuilder<List<FloraTableData>>(
                      stream: vm.floraStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final floraList = snapshot.data!;
                        if (floraList.isEmpty) return const Center(child: Text('Belum ada flora.'));
                        return ListView.builder(
                          itemCount: floraList.length,
                          itemBuilder: (context, index) {
                            final flora = floraList[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: flora.imageUrl != null
                                    ? Image.file(File(flora.imageUrl!), width: 50, height: 50, fit: BoxFit.cover)
                                    : const Icon(Icons.local_florist, color: Colors.green),
                                title: Text(flora.name),
                                subtitle: Text(flora.description ?? '-'),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      _showFloraDialog(context, vm, flora);
                                    } else if (value == 'delete') {
                                      await vm.deleteFlora(flora.id);
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showFloraDialog(context, vm, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFloraDialog(BuildContext context, FloraViewModel vm, FloraTableData? flora) {
    final nameController = TextEditingController(text: flora?.name ?? '');
    final descController = TextEditingController(text: flora?.description ?? '');
    XFile? pickedImage;
    int? dialogSelectedCategoryId = flora?.categoryId ?? vm.selectedCategoryId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(flora == null ? 'Tambah Flora' : 'Edit Flora'),
        content: FutureBuilder<List<Category>>(
          future: vm.categories,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final categories = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Flora'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                  ),
                  const SizedBox(height: 12),
                  // Pilih kategori di dialog
                  DropdownButton<int>(
                    value: dialogSelectedCategoryId,
                    hint: const Text("Pilih Kategori"),
                    isExpanded: true,
                    items: categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (value) => dialogSelectedCategoryId = value,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      pickedImage = await vm.pickImage();
                      if (pickedImage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gambar dipilih: ${pickedImage!.name}')),
                        );
                      }
                    },
                    child: const Text('Pilih Gambar'),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (dialogSelectedCategoryId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
                );
                return;
              }

              vm.setCategory(dialogSelectedCategoryId);

              if (flora == null) {
                await vm.addFlora(
                  name: nameController.text,
                  description: descController.text,
                  imageFile: pickedImage,
                );
              } else {
                await vm.updateFlora(
                  flora,
                  name: nameController.text,
                  description: descController.text,
                  imageFile: pickedImage,
                );
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
