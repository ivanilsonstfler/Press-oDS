import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/medicao.dart';
import '../providers/auth_provider.dart';
import '../repositories/medicao_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sistolicaCtrl = TextEditingController();
  final _diastolicaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _remediosCtrl = TextEditingController();
  final _repo = MedicaoRepository();

  DateTime? _startDate;
  DateTime? _endDate;
  List<Medicao> _medicoes = [];
  bool _loading = false;

  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _loadMedicoes();
  }

  Future<void> _loadMedicoes() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    final list = await _repo.getMedicoesByUser(
      userId: user.id!,
      startDate: _startDate,
      endDate: _endDate,
    );
    setState(() {
      _medicoes = list;
      _loading = false;
    });
  }

  Future<void> _addMedicao() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;

    final med = Medicao(
      sistolica: int.parse(_sistolicaCtrl.text),
      diastolica: int.parse(_diastolicaCtrl.text),
      dataMedicao: DateTime.now(),
      notas: _notasCtrl.text.isEmpty ? null : _notasCtrl.text,
      remediosTomados:
          _remediosCtrl.text.isEmpty ? null : _remediosCtrl.text,
      userId: user.id!,
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
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      _loadMedicoes();
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: _endDate ?? now,
    );
    if (picked != null) {
      // incluir o dia inteiro (igual ao timedelta no Flask)
      setState(() => _endDate = picked.add(const Duration(hours: 23, minutes: 59, seconds: 59)));
      _loadMedicoes();
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
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Form de medição
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sistolicaCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Pressão Sistólica',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final value = int.tryParse(v ?? '');
                                if (value == null) {
                                  return 'Informe um número';
                                }
                                if (value < 50 || value > 300) {
                                  return 'Entre 50 e 300';
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
                                labelText: 'Pressão Diastólica',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final value = int.tryParse(v ?? '');
                                if (value == null) {
                                  return 'Informe um número';
                                }
                                if (value < 30 || value > 200) {
                                  return 'Entre 30 e 200';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notasCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notas (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 200,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _remediosCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Remédios Tomados (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 200,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addMedicao,
                        child: const Text('Adicionar Medição'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Filtro por data
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStartDate,
                    child: Text(_startDate == null
                        ? 'Início'
                        : DateFormat('dd/MM/yyyy').format(_startDate!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEndDate,
                    child: Text(_endDate == null
                        ? 'Fim'
                        : DateFormat('dd/MM/yyyy').format(_endDate!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : _medicoes.isEmpty
                    ? const Text('Nenhuma medição encontrada.')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _medicoes.length,
                        itemBuilder: (context, index) {
                          final m = _medicoes[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${m.sistolica}/${m.diastolica} - ${m.status}'),
                              subtitle: Text(_fmt.format(m.dataMedicao)),
                              isThreeLine: true,
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (m.notas != null && m.notas!.isNotEmpty)
                                    Text('Notas: ${m.notas}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  if (m.remediosTomados != null &&
                                      m.remediosTomados!.isNotEmpty)
                                    Text('Remédios: ${m.remediosTomados}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
