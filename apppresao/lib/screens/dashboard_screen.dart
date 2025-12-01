import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/medicao.dart';
import '../providers/auth_provider.dart';
import '../repositories/medicao_repository.dart';
import '../utils/export_utils.dart';
import 'consulta_screen.dart';
import 'pressure_chart_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
    // Chave para validar e salvar o formulário de nova medição
  final _formKey = GlobalKey<FormState>();
    // Controllers dos campos de texto (pressão, notas, remédios)
  final _sistolicaCtrl = TextEditingController();
  final _diastolicaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _remediosCtrl = TextEditingController();
    // Repositório para acessar as medições
  final _repo = MedicaoRepository();

// Filtros de data para carregar as medições
  DateTime? _startDate;
  DateTime? _endDate;
  // Lista de medições carregadas
  List<Medicao> _medicoes = [];
  // Indicador de carregamento
  bool _loading = false;
// Formatação de data para exibição
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');
// Índice da aba atual (0 = medições, 1 = gráfico)
  int _currentTab = 0;
  String _humorSelecionado = 'bem'; // padrão

  @override
  void initState() {
    super.initState();
    // Carrega as medições ao iniciar a tela
    _loadMedicoes();
  }
// Carrega as medições do usuário com base nos filtros de data
  Future<void> _loadMedicoes() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);// obtém o provedor de autenticação
    final user = auth.currentUser;
    if (user == null) return;// se não houver usuário logado, retorna

    setState(() => _loading = true);// define o estado de carregamento como verdadeiro
    final list = await _repo.getMedicoesByUser(
      userId: user.id!,
      startDate: _startDate,
      endDate: _endDate,
    );// busca as medições do repositório com os filtros aplicados
    setState(() {
      _medicoes = list;
      _loading = false;
    });// atualiza o estado com a lista de medições carregadas e define o carregamento como falso
  }

  Future<void> _addMedicao() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;// se não houver usuário logado, retorna

    final med = Medicao(
      sistolica: int.parse(_sistolicaCtrl.text),
      diastolica: int.parse(_diastolicaCtrl.text),
      dataMedicao: DateTime.now(),
      notas: _notasCtrl.text.isEmpty ? null : _notasCtrl.text,
      remediosTomados:
          _remediosCtrl.text.isEmpty ? null : _remediosCtrl.text,
      userId: user.id!,
      humor: _humorSelecionado,
    );
    await _repo.addMedicao(med);

    _sistolicaCtrl.clear();
    _diastolicaCtrl.clear();
    _notasCtrl.clear();
    _remediosCtrl.clear();

    await _loadMedicoes();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: _startDate ?? now,
    );// mostra o seletor de data

    if (picked != null) {
      setState(() => _startDate = picked);
      _loadMedicoes();
    }// se uma data foi selecionada, atualiza o estado e recarrega as medições
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: _endDate ?? now,
    );// mostra o seletor de data

    if (picked != null) {
      setState(() => _endDate = picked.add(
          const Duration(hours: 23, minutes: 59, seconds: 59)));
      _loadMedicoes();
    }// se uma data foi selecionada, atualiza o estado e recarrega as medições
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Normal':
        return Colors.greenAccent;
      case 'Elevada':
        return Colors.amberAccent;
      case 'Hipertensão Estágio 1':
        return Colors.orangeAccent;
      case 'Hipertensão Estágio 2':
        return Colors.redAccent;
      default:
        return Colors.blueGrey;
    }// retorna a cor correspondente ao status da medição
  }

  Map<String, num> _calcularResumo() {
    if (_medicoes.isEmpty) {
      return {
        'mediaSist': 0,
        'mediaDiast': 0,
        'maxSist': 0,
        'maxDiast': 0,
        'minSist': 0,
        'minDiast': 0,
      };// se não houver medições, retorna zeros
    }

    int somaSist = 0;
    int somaDiast = 0;
    int maxSist = _medicoes.first.sistolica;
    int maxDiast = _medicoes.first.diastolica;
    int minSist = _medicoes.first.sistolica;
    int minDiast = _medicoes.first.diastolica;

    for (final m in _medicoes) {
      somaSist += m.sistolica;
      somaDiast += m.diastolica;
      if (m.sistolica > maxSist) maxSist = m.sistolica;
      if (m.diastolica > maxDiast) maxDiast = m.diastolica;
      if (m.sistolica < minSist) minSist = m.sistolica;
      if (m.diastolica < minDiast) minDiast = m.diastolica;
    }

    final mediaSist = somaSist / _medicoes.length;
    final mediaDiast = somaDiast / _medicoes.length;

    return {
      'mediaSist': mediaSist,
      'mediaDiast': mediaDiast,
      'maxSist': maxSist,
      'maxDiast': maxDiast,
      'minSist': minSist,
      'minDiast': minDiast,
    };
  }

  void _mostrarExplicacao() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Classificação da pressão'),
        content: const Text(
          'Normal: abaixo de 120/80 mmHg\n'
          'Elevada: sistólica 120–129 e diastólica < 80\n'
          'Hipertensão Estágio 1: 130–139 ou 80–89\n'
          'Hipertensão Estágio 2: ≥ 140 ou ≥ 90\n\n'
          'Sempre siga as orientações do seu médico.',
        ),// mostra um diálogo com a explicação das classificações de pressão arterial
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportarCsv() async {
    if (_medicoes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma medição para exportar.')),
      );// mostra uma mensagem se não houver medições para exportar
      return;
    }

    final csv = ExportUtils.medicoesToCsv(_medicoes);
    await Share.share(csv, subject: 'Medições de pressão arterial');// compartilha o CSV gerado com outras aplicações
  }

  void _abrirModoConsulta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultaScreen(medicoes: _medicoes),
      ),
    );// navega para a tela de modo consulta, passando as medições carregadas
  }

  Widget _buildHumorSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Como você está se sentindo?',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),// rótulo do seletor de humor
        const SizedBox(width: 8),
        ToggleButtons(
          isSelected: [
            _humorSelecionado == 'bem',
            _humorSelecionado == 'ok',
            _humorSelecionado == 'mal',
          ],
          onPressed: (index) {
            setState(() {
              if (index == 0) _humorSelecionado = 'bem';
              if (index == 1) _humorSelecionado = 'ok';
              if (index == 2) _humorSelecionado = 'mal';
            });
          },
          borderRadius: BorderRadius.circular(20),
          constraints: const BoxConstraints(minHeight: 32, minWidth: 40),
          children: const [
            Text('👍'),
            Text('😐'),
            Text('👎'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);// obtém o provedor de autenticação
    final user = auth.currentUser;

    if (!auth.isLoggedIn) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final resumo = _calcularResumo();

    final telaMedicoes = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, ${user?.username ?? ''} 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ), // saudação ao usuário
          ),
          const SizedBox(height: 4),
          const Text(
            'Registre e acompanhe suas medições.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),

          // Card de resumo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Média',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${resumo['mediaSist']?.toStringAsFixed(0) ?? '--'}/${resumo['mediaDiast']?.toStringAsFixed(0) ?? '--'}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_medicoes.isNotEmpty)
                          Text(
                            'Última: ${_medicoes.first.sistolica}/${_medicoes.first.diastolica}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Máx: ${resumo['maxSist']}/${resumo['maxDiast']}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mín: ${resumo['minSist']}/${resumo['minDiast']}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Card de formulário
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Nova medição',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _mostrarExplicacao,
                          icon: const Icon(
                            Icons.help_outline,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _sistolicaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Sistólica',
                              suffixText: 'mmHg',
                            ),
                            validator: (v) {
                              final value = int.tryParse(v ?? '');
                              if (value == null) {
                                return 'Número';
                              }
                              if (value < 50 || value > 300) {
                                return '50–300';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _diastolicaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Diastólica',
                              suffixText: 'mmHg',
                            ),
                            validator: (v) {
                              final value = int.tryParse(v ?? '');
                              if (value == null) {
                                return 'Número';
                              }
                              if (value < 30 || value > 200) {
                                return '30–200';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildHumorSelector(),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notasCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                      ),
                      maxLength: 200,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _remediosCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Remédios (opcional)',
                      ),
                      maxLength: 200,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addMedicao,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Adicionar medição'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStartDate,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _startDate == null
                        ? 'Início'
                        : DateFormat('dd/MM').format(_startDate!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickEndDate,
                  icon: const Icon(Icons.event),
                  label: Text(
                    _endDate == null
                        ? 'Fim'
                        : DateFormat('dd/MM').format(_endDate!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_medicoes.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  'Nenhuma medição cadastrada ainda.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _medicoes.length,
              itemBuilder: (context, index) {
                final m = _medicoes[index];
                final color = _statusColor(m.status);

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.2),
                      child: Text(
                        '${m.sistolica}\n${m.diastolica}',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    title: Text(
                      m.status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fmt.format(m.dataMedicao),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        if (m.humor != null)
                          Text(
                            'Como estava: ${m.humor}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        if (m.notas != null && m.notas!.isNotEmpty)
                          Text(
                            'Notas: ${m.notas}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        if (m.remediosTomados != null &&
                            m.remediosTomados!.isNotEmpty)
                          Text(
                            'Remédios: ${m.remediosTomados}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );

    final telaGrafico = PressureChartTab(medicoes: _medicoes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard NOVO'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person_outline),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'exportar') {
                _exportarCsv();
              } else if (value == 'consulta') {
                _abrirModoConsulta();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'exportar',
                child: Text('Exportar CSV'),
              ),
              PopupMenuItem(
                value: 'consulta',
                child: Text('Modo consulta'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF020617)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _currentTab == 0 ? telaMedicoes : telaGrafico,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Medições',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Gráfico',
          ),
        ],
      ),
    );
  }
}
