import 'package:flutter/material.dart';
import '../services/database_service.dart';

class PtProfiloView extends StatefulWidget {
  final String userId;
  final VoidCallback tornaHome;
  final VoidCallback logout;

  const PtProfiloView({
    super.key,
    required this.userId,
    required this.tornaHome,
    required this.logout,
  });

  @override
  State<PtProfiloView> createState() => _PtProfiloViewState();
}

class _PtProfiloViewState extends State<PtProfiloView> {
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  String _codiceTrainer = "Caricamento...";
  bool _caricamento = true;

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    try {
      final profilo = await DatabaseService.getProfiloCompleto(widget.userId);
      if (profilo != null) {
        setState(() {
          _nomeController.text = profilo['first_name'] ?? "";
          _cognomeController.text = profilo['last_name'] ?? "";
          _codiceTrainer = profilo['unique_code'] ?? "N/D";
          _caricamento = false;
        });
      }
    } catch (e) {
      setState(() => _caricamento = false);
    }
  }

  void _mostraDialogoLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Conferma Logout"),
        content: const Text("Sei sicuro di voler uscire dall'account Trainer?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            onPressed: () {
              // 1. Chiude il popup
              Navigator.pop(context);
              // 2. Chiude la pagina profilo e torna al login gestito nel main
              Navigator.pop(context);
              // 3. Esegue la logica di logout
              widget.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Sì, esci",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _salvaModifiche() async {
    if (_nomeController.text.trim().isEmpty ||
        _cognomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Compilare tutti i campi"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await DatabaseService.supabase
          .from('profiles')
          .update({
            'first_name': _nomeController.text.trim(),
            'last_name': _cognomeController.text.trim(),
          })
          .eq('id', widget.userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profilo aggiornato!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_caricamento) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "PROFILO TRAINER",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  const Text(
                    "IL TUO CODICE TRAINER",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _codiceTrainer,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _cognomeController,
              decoration: InputDecoration(
                labelText: "Cognome",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              "Gestisci i tuoi dati personali visibili agli atleti",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _salvaModifiche,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("SALVA MODIFICHE"),
            ),

            const SizedBox(height: 15),

            OutlinedButton(
              onPressed: widget.tornaHome,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("TORNA ALLA HOME"),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: _mostraDialogoLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("ESCI DALL'ACCOUNT"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    super.dispose();
  }
}
