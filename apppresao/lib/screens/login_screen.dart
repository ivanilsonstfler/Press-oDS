```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

// Tela de login do app (entrada do usuário com email e senha)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave global para controlar o estado do formulário (validação)
  final _formKey = GlobalKey<FormState>();

  // Controllers para capturar o texto digitado nos campos
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Flag para indicar se está em processo de login (mostra loading no botão)
  bool _loading = false;

  // Mensagem de erro de login (ex: credenciais inválidas)
  String? _error;

  @override
  Widget build(BuildContext context) {
    // Provider de autenticação para chamar o método de login
    final auth = Provider.of<AuthProvider>(context);

    // Tamanho da tela (usado para limitar largura máxima do card)
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Fundo com gradiente azul escuro
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                // Limita a largura máxima do conteúdo para ficar mais bonito em telas grandes
                constraints: BoxConstraints(
                  maxWidth: size.width < 500 ? size.width : 420,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone de coração (ilustração do app)
                    const Icon(
                      Icons.favorite_rounded,
                      color: Colors.redAccent,
                      size: 64,
                    ),
                    const SizedBox(height: 12),
                    // Título principal do app
                    const Text(
                      'Controle de Pressão',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtítulo explicando o propósito do app
                    const Text(
                      'Acompanhe suas medições no dia a dia',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Card branco com o formulário de login
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Campo de email
                              TextFormField(
                                controller: _emailCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  // Validação simples: campo não pode ser vazio
                                  if (v == null || v.isEmpty) {
                                    return 'Informe o email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              // Campo de senha
                              TextFormField(
                                controller: _passwordCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Senha',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                obscureText: true, // Oculta a senha
                                validator: (v) {
                                  // Validação simples: campo não pode ser vazio
                                  if (v == null || v.isEmpty) {
                                    return 'Informe a senha';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              // Exibição de mensagem de erro (se houver)
                              if (_error != null)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              // Se estiver carregando, mostra o indicador; senão mostra o botão
                              _loading
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // Valida o formulário antes de tentar login
                                          if (!_formKey.currentState!
                                              .validate()) return;

                                          // Inicia loading e limpa erro anterior
                                          setState(() {
                                            _loading = true;
                                            _error = null;
                                          });

                                          // Chama o método de login do AuthProvider
                                          final msg = await auth.login(
                                            _emailCtrl.text.trim(),
                                            _passwordCtrl.text,
                                          );

                                          // Para o loading e guarda a mensagem de erro (se vier)
                                          setState(() {
                                            _loading = false;
                                            _error = msg;
                                          });

                                          // LOGIN OK -> se msg == null, navega para a rota /dashboard
                                          if (msg == null && mounted) {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/dashboard',
                                            );
                                          }
                                        },
                                        child: const Text('Entrar'),
                                      ),
                                    ),
                              const SizedBox(height: 8),
                              // Botão de texto para ir para a tela de cadastro
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: const Text('Criar conta'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```
