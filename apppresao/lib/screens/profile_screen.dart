```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

// Tela de perfil do usuário (dados pessoais e clínicos básicos)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Chave do formulário para validações futuras, se necessário
  final _formKey = GlobalKey<FormState>();

  // Controllers dos campos de texto
  final _fullNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _bloodTypeCtrl = TextEditingController();

  // Formato de data usado para exibir/armazenar a data de nascimento no campo
  final _fmt = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();

    // Carrega os dados atuais do usuário para preencher o formulário
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    if (user != null) {
      // Nome completo
      _fullNameCtrl.text = user.fullName ?? '';

      // Data de nascimento (se existir) no formato yyyy-MM-dd
      if (user.dateOfBirth != null) {
        _dobCtrl.text = _fmt.format(user.dateOfBirth!);
      }

      // Peso, se já estiver salvo
      if (user.weight != null) {
        _weightCtrl.text = user.weight!.toString();
      }

      // Altura, se já estiver salva
      if (user.height != null) {
        _heightCtrl.text = user.height!.toString();
      }

      // Tipo sanguíneo
      _bloodTypeCtrl.text = user.bloodType ?? '';
    }
  }

  @override
  void dispose() {
    // Libera os controllers da memória quando a tela for destruída
    _fullNameCtrl.dispose();
    _dobCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _bloodTypeCtrl.dispose();
    super.dispose();
  }

  // Abre um datepicker para o usuário escolher a data de nascimento
  Future<void> _pickDob() async {
    // Data inicial padrão do calendário
    final initial = DateTime(1990, 1, 1);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),      // limite inferior
      lastDate: DateTime.now(),       // não permite data futura
      initialDate: initial,
    );

    // Se o usuário escolher uma data, preenche o campo com o formato definido
    if (picked != null) {
      _dobCtrl.text = _fmt.format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider de autenticação (para acessar usuário e atualizar perfil)
    final auth = Provider.of<AuthProvider>(context);

    // Se não estiver logado, redireciona para login
    if (!auth.isLoggedIn) {
      // Usa microtask para evitar navegação durante o build imediato
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
              // Nome completo (sem validação obrigatória, pode ser vazio)
              TextFormField(
                controller: _fullNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 12),

              // Data de nascimento (campo somente leitura, abre datepicker ao toque)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dobCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Data de nascimento (AAAA-MM-DD)',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,   // impede digitação direta
                      onTap: _pickDob,  // chama o seletor de data
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Linha com Peso (kg) e Altura (cm)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        border: OutlineInputBorder(),
                      ),
                      // Permite números com ponto ou vírgula (dependendo do teclado)
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

              // Tipo sanguíneo do usuário (ex.: O+, A-, etc.)
              TextFormField(
                controller: _bloodTypeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tipo sanguíneo',
                  border: OutlineInputBorder(),
                ),
                maxLength: 5,
              ),
              const SizedBox(height: 16),

              // Botão para salvar as alterações do perfil
              ElevatedButton(
                onPressed: () async {
                  // Pega o usuário atual do AuthProvider
                  final user = auth.currentUser!;

                  double? weight;
                  double? height;

                  // Converte o peso digitado para double (se não estiver vazio)
                  if (_weightCtrl.text.isNotEmpty) {
                    weight = double.tryParse(_weightCtrl.text);
                  }

                  // Converte a altura digitada para double (se não estiver vazia)
                  if (_heightCtrl.text.isNotEmpty) {
                    height = double.tryParse(_heightCtrl.text);
                  }

                  // Tenta converter a data de nascimento digitada em DateTime
                  DateTime? dob;
                  if (_dobCtrl.text.isNotEmpty) {
                    try {
                      dob = DateTime.parse(_dobCtrl.text);
                    } catch (_) {
                      // Se der erro no parse, simplesmente ignora e deixa dob como null
                    }
                  }

                  // Cria uma cópia do usuário atual com os novos dados preenchidos
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

                  // Chama o método do AuthProvider para salvar o perfil atualizado
                  await auth.updateProfile(updated);

                  // Se o widget ainda estiver montado, mostra um SnackBar de sucesso
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
```
