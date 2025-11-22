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
```dart
// Tela principal do app: dashboard com formulário, lista de medições e gráfico.
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

  // Repositório responsável por acessar o banco de dados das medições
  final _repo = MedicaoRepository();

  // Filtros de data (início e fim) para a listagem
  DateTime? _startDate;
  DateTime? _endDate;

  // Lista de medições carregadas do repositório
  List<Medicao> _medicoes = [];

  // Indica se está carregando (usado para mostrar o CircularProgressIndicator)
  bool _loading = false;

  // Formatação padrão para exibir a data/hora das medições
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  // Controle da aba atual do BottomNavigationBar (0 = medições, 1 = gráfico)
  int _currentTab = 0;

  // Campo para guardar o humor selecionado na nova medição
  String _humorSelecionado = 'bem'; // padrão

  @override
  void initState() {
    super.initState();
    // Ao iniciar a tela, carrega as medições do usuário logado
    _loadMedicoes();
  }

  // Busca todas as medições do usuário (com ou sem filtro de datas)
  Future<void> _loadMedicoes() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return; // Se não houver usuário, não faz nada

    setState(() => _loading = true); // Mostra indicador de carregamento

    // Chama o repositório passando o userId e filtros de data
    final list = await _repo.getMedicoesByUser(
      userId: user.id!,
      startDate: _startDate,
      endDate: _endDate,
    );

    // Atualiza a lista local e tira o loading
    setState(() {
      _medicoes = list;
      _loading = false;
    });
  }

  // Cria uma nova medição a partir do formulário e salva no repositório
  Future<void> _addMedicao() async {
    // Valida o formulário; se tiver erro, retorna
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return; // Segurança extra caso não esteja logado

    // Monta o objeto Medicao com os dados do formulário
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

    // Salva no banco/repositório
    await _repo.addMedicao(med);

    // Limpa os campos do formulário depois de salvar
    _sistolicaCtrl.clear();
    _diastolicaCtrl.clear();
    _notasCtrl.clear();
    _remediosCtrl.clear();

    // Recarrega as medições para atualizar a lista e o resumo
    await _loadMedicoes();
  }

  // Abre o datepicker para escolher a data de início do filtro
  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000), // Data mínima
      lastDate: now, // Não permite datas futuras
      initialDate: _startDate ?? now, // Usa a atual ou a última selecionada
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      _loadMedicoes(); // Recarrega a lista com o filtro aplicado
    }
  }

  // Abre o datepicker para escolher a data de fim do filtro
  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: _endDate ?? now,
    );
    if (picked != null) {
      // Ajusta a data para o final do dia (23:59:59) para incluir aquele dia todo
      setState(() => _endDate = picked.add(
          const Duration(hours: 23, minutes: 59, seconds: 59)));
      _loadMedicoes(); // Recarrega a lista com o filtro atualizado
    }
  }

  // Define a cor associada a um status de pressão arterial
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
        // Caso não reconheça o status, usa um neutro
        return Colors.blueGrey;
    }
  }

  // Calcula médias, máximos e mínimos das medições atuais
  Map<String, num> _calcularResumo() {
    if (_medicoes.isEmpty) {
      // Se não tiver medições, devolve tudo zero
      return {
        'mediaSist': 0,
        'mediaDiast': 0,
        'maxSist': 0,
        'maxDiast': 0,
        'minSist': 0,
        'minDiast': 0,
      };
    }

    int somaSist = 0;
    int somaDiast = 0;

    // Inicializa max e min com os valores da primeira medição
    int maxSist = _medicoes.first.sistolica;
    int maxDiast = _medicoes.first.diastolica;
    int minSist = _medicoes.first.sistolica;
    int minDiast = _medicoes.first.diastolica;

    // Percorre todas as medições acumulando e checando min/max
    for (final m in _medicoes) {
      somaSist += m.sistolica;
      somaDiast += m.diastolica;

      if (m.sistolica > maxSist) maxSist = m.sistolica;
      if (m.diastolica > maxDiast) maxDiast = m.diastolica;
      if (m.sistolica < minSist) minSist = m.sistolica;
      if (m.diastolica < minDiast) minDiast = m.diastolica;
    }

    // Calcula média baseando-se no total de elementos
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

  // Mostra um diálogo explicando a classificação da pressão arterial
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Fecha o diálogo
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Exporta a lista de medições em formato CSV e compartilha
  Future<void> _exportarCsv() async {
    if (_medicoes.isEmpty) {
      // Mensagem caso não haja medições para exportar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma medição para exportar.')),
      );
      return;
    }

    // Converte a lista em CSV usando utilitário
    final csv = ExportUtils.medicoesToCsv(_medicoes);

    // Usa o Share para compartilhar o texto CSV
    await Share.share(csv, subject: 'Medições de pressão arterial');
  }

  // Abre outra tela para modo consulta (tela somente leitura ou detalhada)
  void _abrirModoConsulta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultaScreen(medicoes: _medicoes),
      ),
    );
  }

  // Constrói o componente de seleção de humor (👍, 😐, 👎)
  Widget _buildHumorSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Como você está se sentindo?',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(width: 8),
        ToggleButtons(
          // Define quais botões estão selecionados com base na string _humorSelecionado
          isSelected: [
            _humorSelecionado == 'bem',
            _humorSelecionado == 'ok',
            _humorSelecionado == 'mal',
          ],
          onPressed: (index) {
            // Atualiza o humor selecionado de acordo com o botão clicado
            setState(() {
              if (index == 0) _humorSelecionado = 'bem';
              if (index == 1) _humorSelecionado = 'ok';
              if (index == 2) _humorSelecionado = 'mal';
            });
          },
          // Estilo dos botões
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
    // Provider de autenticação para obter o usuário logado
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    // Se não estiver logado, redireciona para a tela de login
    if (!auth.isLoggedIn) {
      // Future.microtask usado para evitar problemas de navegação durante o build
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      // Enquanto redireciona, mostra apenas um loading
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    // Calcula os dados de resumo (médias, min/max) com base nas medições atuais
    final resumo = _calcularResumo();

    // Conteúdo da aba de medições (formulário + lista)
    final telaMedicoes = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saudação ao usuário
          Text(
            'Olá, ${user?.username ?? ''} 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Registre e acompanhe suas medições.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),

          // Card de resumo das medições (média, última, máx, mín)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Parte da esquerda: média e última medição
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
                          // Exibe média sistólica/diastólica arredondada (0 casas decimais)
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
                            // Mostra a primeira medição da lista como "última"
                            'Última: ${_medicoes.first.sistolica}/${_medicoes.first.diastolica}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Parte da direita: máximos e mínimos
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

          // Card com o formulário de nova medição
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey, // Usa a chave global para validar/salvar
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
                        // Botão de ajuda com a explicação dos níveis de pressão
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
                        // Campo de sistólica
                        Expanded(
                          child: TextFormField(
                            controller: _sistolicaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Sistólica',
                              suffixText: 'mmHg',
                            ),
                            validator: (v) {
                              // Validação: precisa ser número dentro do intervalo permitido
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
                        // Campo de diastólica
                        Expanded(
                          child: TextFormField(
                            controller: _diastolicaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Diastólica',
                              suffixText: 'mmHg',
                            ),
                            validator: (v) {
                              // Validação: precisa ser número dentro do intervalo permitido
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
                    // Componente de seleção de humor
                    _buildHumorSelector(),
                    const SizedBox(height: 8),
                    // Campo de notas (opcional)
                    TextFormField(
                      controller: _notasCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                      ),
                      maxLength: 200,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    // Campo de remédios tomados (opcional)
                    TextFormField(
                      controller: _remediosCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Remédios (opcional)',
                      ),
                      maxLength: 200,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    // Botão para salvar a nova medição
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

          // Linha com os botões de filtro de data (Início / Fim)
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

          // Estado de carregamento, lista vazia ou lista de medições
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
            // Lista de medições (dentro da ScrollView; por isso shrinkWrap true)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _medicoes.length,
              itemBuilder: (context, index) {
                final m = _medicoes[index];
                final color = _statusColor(m.status); // Cor conforme status

                return Card(
                  child: ListTile(
                    // Avatar à esquerda com sistólica/diastólica
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
                    // Título com o status (Normal, Elevada, etc.)
                    title: Text(
                      m.status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Subtítulo com data, humor, notas e remédios
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

    // Conteúdo da aba de gráfico (usa outro widget para desenhar o chart)
    final telaGrafico = PressureChartTab(medicoes: _medicoes);

    // Scaffold principal da tela
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard NOVO'),
        actions: [
          // Ícone para ir até a tela de perfil/conta
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person_outline),
          ),
          // Menu de opções (exportar CSV, modo consulta)
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
        // Fundo em gradiente azul/escuro
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF020617)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          // Alterna entre a tela de medições e o gráfico conforme a aba
          child: _currentTab == 0 ? telaMedicoes : telaGrafico,
        ),
      ),
      // Barra de navegação inferior com duas abas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          // Atualiza o índice da aba selecionada
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
```
