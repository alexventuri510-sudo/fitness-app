import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Per la funzione copia negli appunti

class AtletaProfiloView extends StatefulWidget {
  final String userId;
  final VoidCallback tornaHome;
  final VoidCallback logout;
  // Funzioni per il database
  final Future<Map<String, dynamic>?> Function(String) getProfilo;
  final Future<bool> Function(String, String, String) updateProfilo;

  const AtletaProfiloView({
    super.key,
    required this.userId,
    required this.tornaHome,
    required this.logout,
    required this.getProfilo,
    required this.updateProfilo,
  });

  @override
  State<AtletaProfiloView> createState() => _AtletaProfiloViewState();
}

class _AtletaProfiloViewState extends State<AtletaProfiloView> {
  final TextEditingController _txtNome = TextEditingController();
  final TextEditingController _txtCognome = TextEditingController();
  final TextEditingController _txtPt = TextEditingController();

  String _codiceAtleta = "Caricamento...";
  String _errore = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    try {
      final profilo = await widget.getProfilo(widget.userId);
      if (profilo != null) {
        setState(() {
          _txtNome.text = profilo['first_name'] ?? "";
          _txtCognome.text = profilo['last_name'] ?? "";
          _txtPt.text = profilo['trainer_name'] ?? "Non assegnato";
          _codiceAtleta = profilo['unique_code'] ?? "N/D";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errore = "Errore nel caricamento: $e";
        _isLoading = false;
      });
    }
  }

  void _copiaCodice() {
    if (_codiceAtleta != "N/D" && _codiceAtleta != "Caricamento...") {
      Clipboard.setData(ClipboardData(text: _codiceAtleta));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Codice $_codiceAtleta copiato!"),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _salvaModifiche() async {
    setState(() => _errore = "");

    if (_txtNome.text.trim().isEmpty || _txtCognome.text.trim().isEmpty) {
      setState(() => _errore = "Compilare i campi vuoti");
      return;
    }

    final successo = await widget.updateProfilo(
      widget.userId,
      _txtNome.text.trim(),
      _txtCognome.text.trim(),
    );

    if (successo && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profilo salvato!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _apriDialogoLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Conferma Logout"),
        content: const Text("Sei sicuro di voler uscire?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            onPressed: () {
              // 1. Chiude il popup di conferma
              Navigator.pop(context);
              // 2. Chiude la vista profilo per tornare alla home (che poi diventerà login)
              Navigator.pop(context);
              // 3. Esegue il logout tramite il callback del main
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              "IL TUO PROFILO",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),

            // BOX CODICE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "CODICE ATLETA: $_codiceAtleta",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _copiaCodice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(70, 35),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text("COPIA"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            if (_errore.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _errore,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            _buildTextField("Nome", _txtNome),
            const SizedBox(height: 15),
            _buildTextField("Cognome", _txtCognome),
            const SizedBox(height: 15),
            _buildTextField(
              "Personal Trainer",
              _txtPt,
              readOnly: true,
              icon: Icons.person,
              color: Colors.orange,
            ),

            const SizedBox(height: 10),
            const Text(
              "Invia il codice al tuo PT per collegarti",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 30),
            _buildActionButton("SALVA MODIFICHE", _salvaModifiche, Colors.blue),
            const SizedBox(height: 15),
            OutlinedButton(
              onPressed: widget.tornaHome,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "TORNA ALLA HOME",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 15),
            _buildActionButton(
              "ESCI DALL'ACCOUNT",
              _apriDialogoLogout,
              Colors.red,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    IconData? icon,
    Color color = Colors.blue,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: color) : null,
        labelStyle: TextStyle(color: color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
