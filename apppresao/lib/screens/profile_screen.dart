import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _bloodTypeCtrl = TextEditingController();

  final _fmt = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user != null) {
      _fullNameCtrl.text = user.fullName ?? '';
      if (user.dateOfBirth != null) {
        _dobCtrl.text = _fmt.format(user.dateOfBirth!);
      }
      if (user.weight != null) {
        _weightCtrl.text = user.weight!.toString();
      }
      if (user.height != null) {
        _heightCtrl.text = user.height!.toString();
      }
      _bloodTypeCtrl.text = user.bloodType ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _dobCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _bloodTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final initial = DateTime(1990, 1, 1);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: initial,
    );
    if (picked != null) {
      _dobCtrl.text = _fmt.format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isLoggedIn) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dobCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Data de nascimento (AAAA-MM-DD)',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: _pickDob,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _heightCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Altura (cm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bloodTypeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tipo sanguíneo',
                  border: OutlineInputBorder(),
                ),
                maxLength: 5,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final user = auth.currentUser!;
                  double? weight;
                  double? height;
                  if (_weightCtrl.text.isNotEmpty) {
                    weight = double.tryParse(_weightCtrl.text);
                  }
                  if (_heightCtrl.text.isNotEmpty) {
                    height = double.tryParse(_heightCtrl.text);
                  }

                  DateTime? dob;
                  if (_dobCtrl.text.isNotEmpty) {
                    try {
                      dob = DateTime.parse(_dobCtrl.text);
                    } catch (_) {}
                  }

                  final updated = user.copyWith(
                    fullName: _fullNameCtrl.text.isEmpty
                        ? null
                        : _fullNameCtrl.text,
                    dateOfBirth: dob,
                    weight: weight,
                    height: height,
                    bloodType: _bloodTypeCtrl.text.isEmpty
                        ? null
                        : _bloodTypeCtrl.text,
                  );

                  await auth.updateProfile(updated);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil atualizado!')),
                    );
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
