import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/viewmodels/moments_viewmodel.dart';
import 'package:rimba_app/ui/widgets/app_bottom_navbar.dart';
import 'package:go_router/go_router.dart';

class MomentAddView extends StatefulWidget {
  const MomentAddView({super.key});

  @override
  State<MomentAddView> createState() => _MomentAddViewState();
}

class _MomentAddViewState extends State<MomentAddView> {
  final _formKey = GlobalKey<FormState>();
  final _tempatController = TextEditingController();
  final _deskripsiController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tempatController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return ChangeNotifierProvider<MomentsViewModel>(
      create: (_) => MomentsViewModel(db),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'momen langka',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        body: _buildForm(),
        bottomNavigationBar:
            const AppBottomNavBar(currentTab: AppTab.add),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _tempatController,
              decoration: const InputDecoration(
                labelText: 'Tempat',
                border: UnderlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Tempat wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: UnderlineInputBorder(),
              ),
              maxLines: 5,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SUBMIT',
                        style: TextStyle(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final vm = context.read<MomentsViewModel>();

    await vm.addMoment(
      tempat: _tempatController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${vm.errorMessage}')),
      );
      return;
    }

    if (mounted) {
      context.go('/moments');
    }
  }
}
