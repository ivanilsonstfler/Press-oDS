```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Tela de cadastro de novo usuário
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Chave global do formulário (para validação)
  final _formKey = GlobalKey<FormState>();

  // Controllers dos campos de texto
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Flag para indicar se está processando o cadastro (mostra loading)
  bool _loading = false;

  // Mensagem de erro vinda do AuthProvider (ex.: e-mail já usado)
  String? _error;

  @override
  Widget build(BuildContext context) {
    // Provider de autenticação, usado para chamar o método register
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Campo: Nome de usuário
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome de usuário',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    // Validação simples: pelo menos 2 caracteres
                    if (v == null || v.length < 2) {
                      return 'Mínimo 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Campo: Email
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    // Apenas verifica se não está vazio
                    if (v == null || v.isEmpty) return 'Informe o email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Campo: Senha
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true, // Esconde o texto (senha)
                  validator: (v) {
                    // Mínimo de 6 caracteres de senha
                    if (v == null || v.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Campo: Confirmar senha
                TextFormField(
                  controller: _confirmCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) {
                    // Verifica se a confirmação é igual à senha digitada
                    if (v != _passwordCtrl.text) {
                      return 'Senhas não conferem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Exibe mensagem de erro, se houver
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 12),

                // Se estiver carregando, mostra o indicador; senão mostra o botão "Cadastrar"
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          // Valida o formulário antes de prosseguir
                          if (!_formKey.currentState!.validate()) return;

                          // Inicia loading e limpa erro anterior
                          setState(() {
                            _loading = true;
                            _error = null;
                          });

                          // Chama o método de cadastro no AuthProvider
                          final msg = await auth.register(
                            _usernameCtrl.text.trim(),
                            _emailCtrl.text.trim(),
                            _passwordCtrl.text,
                          );

                          // Atualiza o estado com o resultado (para parar loading e mostrar erro, se tiver)
                          setState(() {
                            _loading = false;
                            _error = msg;
                          });

                          // Se não houve erro (msg == null) e o widget ainda está na árvore, vai para /dashboard
                          if (msg == null && mounted) {
                            Navigator.pushReplacementNamed(
                                context, '/dashboard');
                          }
                        },
                        child: const Text('Cadastrar'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```
