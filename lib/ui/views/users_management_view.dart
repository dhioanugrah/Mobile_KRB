import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/core/services/auth_service.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/viewmodels/users_viewmodel.dart';

class UsersManagementView extends StatelessWidget {
  const UsersManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UsersViewModel>();
    final currentUser = context.watch<AuthService>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: () => vm.loadUsers(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.purple,
        onRefresh: vm.loadUsers,
        child: vm.isLoading
            ? _buildLoading()
            : vm.errorMessage != null
                ? _buildError(context, vm.errorMessage!)
                : vm.users.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: vm.users.length,
                        itemBuilder: (context, index) {
                          final user = vm.users[index];
                          final isCurrentUser = currentUser?.id == user.id;
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.purple.shade200,
                                child: Text(
                                  user.username.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              title: Text(
                                user.username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.email,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      Chip(
                                        label: Text(
                                          user.role.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: user.role == 'admin'
                                            ? Colors.deepPurple
                                            : Colors.grey.shade600,
                                      ),
                                      if (isCurrentUser)
                                        const Chip(
                                          label: Text(
                                            'Anda',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor: Colors.teal,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<_UserAction>(
                                onSelected: (action) =>
                                    _handleUserAction(context, vm, action, user),
                                itemBuilder: (context) {
                                  final items = <PopupMenuEntry<_UserAction>>[];
                                  if (user.role != 'admin') {
                                    items.add(
                                      const PopupMenuItem(
                                        value: _UserAction.setAdmin,
                                        child: Text('Jadikan Admin'),
                                      ),
                                    );
                                  }
                                  if (user.role != 'user') {
                                    items.add(
                                      const PopupMenuItem(
                                        value: _UserAction.setUser,
                                        child: Text('Jadikan User'),
                                      ),
                                    );
                                  }
                                  if (!isCurrentUser) {
                                    items.add(
                                      const PopupMenuItem(
                                        value: _UserAction.delete,
                                        child: Text(
                                          'Hapus',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    );
                                  }
                                  if (items.isEmpty) {
                                    return const [
                                      PopupMenuItem(
                                        enabled: false,
                                        child: Text('Tidak ada aksi'),
                                      ),
                                    ];
                                  }
                                  return items;
                                },
                              ),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _showCreateUserDialog(context, vm),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 200),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 200),
        Center(
          child: Text(
            'Belum ada pengguna terdaftar.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 200),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.read<UsersViewModel>().loadUsers(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleUserAction(
    BuildContext context,
    UsersViewModel vm,
    _UserAction action,
    User user,
  ) async {
    switch (action) {
      case _UserAction.setAdmin:
        await _performWithFeedback(
          context,
          () => vm.updateRole(user.id, 'admin'),
          successMessage: '${user.username} sekarang adalah admin.',
        );
        break;
      case _UserAction.setUser:
        await _performWithFeedback(
          context,
          () => vm.updateRole(user.id, 'user'),
          successMessage: '${user.username} sekarang adalah user.',
        );
        break;
      case _UserAction.delete:
        final confirm = await _confirmDelete(context, user);
        if (confirm != true) return;
        if (!context.mounted) return;
        await _performWithFeedback(
          context,
          () => vm.deleteUser(user.id),
          successMessage: '${user.username} dihapus.',
        );
        break;
    }
  }

  Future<void> _performWithFeedback(
    BuildContext context,
    Future<String?> Function() action, {
    required String successMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await action();
    if (!context.mounted) return;
    if (error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(successMessage)),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, User user) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${user.username}? Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateUserDialog(BuildContext context, UsersViewModel vm) async {
    final formKey = GlobalKey<FormState>();
    final usernameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String role = 'user';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pengguna'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'Minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Peran'),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      role = value;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final error = await vm.addUser(
      username: usernameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text.trim(),
      role: role,
    );

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text('Pengguna ${usernameCtrl.text} ditambahkan.')),
      );
    }
  }
}

enum _UserAction { setAdmin, setUser, delete }
