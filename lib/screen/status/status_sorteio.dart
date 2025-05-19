import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:crud_produto/model/sorteio.dart';
import 'package:crud_produto/model/participante.dart';
import 'package:crud_produto/model/ganhador.dart';
import 'package:crud_produto/service/sorteio_service.dart';
import 'package:crud_produto/service/participante_service.dart';
import 'package:crud_produto/service/ganhador_service.dart';


class StatusSorteio extends StatefulWidget {
  const StatusSorteio({super.key});

  @override
  State<StatusSorteio> createState() => _StatusSorteioState();
}

class _StatusSorteioState extends State<StatusSorteio> {
  final SorteioService _sorteioService = SorteioService();
  final ParticipanteService _participanteService = ParticipanteService();
  final GanhadorService _ganhadorService = GanhadorService();
  
  Sorteio? _sorteio;
  List<Participante> _participantes = [];
  Ganhador? _ganhador;
  bool _loading = true;
  DateTime? _createdTime;
  Timer? _countdownTimer;
  Timer? _participantesTimer;
  Duration _duracao= Duration.zero;

  @override
  void initState() {
    super.initState();
    _carregarSorteio();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _participantesTimer?.cancel();
    super.dispose();
  }

  Future<void> _carregarSorteio() async {
    setState(() => _loading = true);
    final sorteio = await _sorteioService.carregarSorteio();

    if (sorteio != null && sorteio.createdAt != null) {
      final tempoFinal = sorteio.createdAt!.add(sorteio.duracao);
      final duracao = tempoFinal.difference(DateTime.now());

      if (!duracao.isNegative) {
        _startCountdown(tempoFinal);
        Timer(duracao, () async {
          if (mounted && sorteio.id != null) {
            await _processarVencedor(sorteio);
            await _sorteioService.deletarSorteio(sorteio.id!);
            if (mounted) {
              setState(() => _sorteio = null);
              if (context.mounted) {
                _showResultadoSnackbar();
              }
            }
          }
        });
      } else {
        await _processarVencedor(sorteio);
        await _sorteioService.deletarSorteio(sorteio.id!);
      }
    }

    if (sorteio != null) {
      await _carregarParticipantes();
      _startParticipantesTimer();
    }

    setState(() {
      _sorteio = sorteio;
      _createdTime = sorteio?.createdAt;
      _duracao = _calculateduracao();
      _loading = false;
    });
  }

  Future<void> _processarVencedor(Sorteio sorteio) async {
  if (_participantes.isNotEmpty) {
    try {
      final winner = _participantes[Random().nextInt(_participantes.length)];
      _ganhador = Ganhador(
      
        nome: winner.nome,
        telefone: winner.telefone,

      );
      
      await _ganhadorService.salvarGanhador(_ganhador!);
      print("Ganhador salvo com sucesso!");
    } catch (e) {
      print("Erro ao salvar ganhador: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar ganhador: $e")),
      );
    }
  }
}
  Future<void> _carregarParticipantes() async {
    if (_sorteio?.id == null) return;
    final participantes = await _participanteService.carregarParticipantes(_sorteio!.id!);
    setState(() => _participantes = participantes);
  }

  void _startParticipantesTimer() {
    _participantesTimer?.cancel();
    _participantesTimer = Timer.periodic(const Duration(seconds: 5), (_) => _carregarParticipantes());
  }

  void _startCountdown(DateTime tempoFinal) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = tempoFinal.difference(now);
      setState(() => _duracao = diff.isNegative ? Duration.zero : diff);
    });
  }

  Duration _calculateduracao() {
    if (_sorteio == null || _createdTime == null) return Duration.zero;
    final end = _createdTime!.add(_sorteio!.duracao);
    return end.difference(DateTime.now()).isNegative 
        ? Duration.zero 
        : end.difference(DateTime.now());
  }

  Future<void> _finalizarSorteio() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Finalizar Sorteio"),
        content: const Text("Tem certeza que deseja finalizar o sorteio e sortear um vencedor?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Finalizar"),
          ),
        ],
      ),
    );

    if (confirm == true && _sorteio != null) {
      await _processarVencedor(_sorteio!);
      await _sorteioService.deletarSorteio(_sorteio!.id!);
      _countdownTimer?.cancel();
      _participantesTimer?.cancel();

      setState(() {
        _sorteio = null;
        _createdTime = null;
        _duracao = Duration.zero;
        _participantes = [];
      });

      _showResultadoSnackbar();
    }
  }

  void _showResultadoSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _participantes.isEmpty
            ? const Text("Sorteio finalizado sem participantes.")
            : Text("Vencedor sorteado: ${_ganhador?.nome}"),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Widget _buildVencedorCard() {
    if (_ganhador == null) return const SizedBox.shrink();

    return Card(
      color: Colors.green[100],
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "🏆 Vencedor 🏆",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: Icon(Icons.person, color: Colors.green[800]),
              title: Text(
                _ganhador!.nome,
                style: const TextStyle(fontSize: 18),
              ),
              subtitle: Text(_ganhador!.telefone),
            ),
            const SizedBox(height: 10),
            
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantesList() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Participantes (${_participantes.length})",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _participantes.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Nenhum participante registrado"),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _participantes.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(_participantes[index].nome),
                      subtitle: Text(_participantes[index].telefone),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _sorteio == null,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Status do Sorteio"),
          automaticallyImplyLeading: _sorteio == null,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    if (_sorteio != null) ...[
                      _buildSorteioCard(),
                      _buildParticipantesList(),
                    ],
                    if (_ganhador != null) _buildVencedorCard(),
                    if (_sorteio == null && _ganhador == null)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "Nenhum sorteio ativo no momento",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
        floatingActionButton: _sorteio != null
            ? FloatingActionButton.extended(
                onPressed: _finalizarSorteio,
                icon: const Icon(Icons.celebration),
                label: const Text("Sortear Agora"),
                backgroundColor: Colors.red,
              )
            : null,
      ),
    );
  }

  Widget _buildSorteioCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _sorteio!.nome,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _sorteio!.desc,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.timer_outlined),
                const SizedBox(width: 10),
                Text(
                  "Tempo restante: ${_formatDuration(_duracao)}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}