import 'package:flutter/material.dart';

class StatusSorteio extends StatefulWidget {
  const StatusSorteio({super.key});

  @override
  State<StatusSorteio> createState() => _StatusSorteioState();
}

class _StatusSorteioState extends State<StatusSorteio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Status do Sorteio"),
      ),
      body: Center(
        child: Text("Conteúdo do Status do Sorteio"),
      ),
    );
  }
}
