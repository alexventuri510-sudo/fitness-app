import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme/style_config.dart';

class RegisterView extends StatefulWidget {
  final VoidCallback vaiALogin;

  const RegisterView({super.key, required this.vaiALogin});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Controller per i campi di testo
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  String? _ruoloSelezionato;
  String _errorText = "";
  String _successText = "";

  Future<void> _eseguiRegistrazione() async {
    setState(() {
      _errorText = "";
      _successText = "";
    });

    // Validazione campi obbligatori (come in Python)
    if (_emailController.text.isEmpty ||
        _passController.text.isEmpty ||
        _nomeController.text.isEmpty ||
        _ruoloSelezionato == null) {
      setState(() {
        _errorText = "Compila tutti i campi obbligatori!";
      });
      return;
    }

    try {
      final res = await DatabaseService.registraUtente(
        _emailController.text,
        _passController.text,
        _nomeController.text,
        _cognomeController.text,
        _ruoloSelezionato!,
      );

      if (res != null) {
        setState(() {
          _successText = "Account creato con successo!";
          _errorText = "";
          // Svuota i campi
          _nomeController.clear();
          _cognomeController.clear();
          _emailController.clear();
          _passController.clear();
          _ruoloSelezionato = null;
        });
      }
    } catch (ex) {
      String msgEx = ex.toString();
      setState(() {
        if (msgEx.contains("Password should be at least 6 characters")) {
          _errorText = "La password deve essere di almeno 6 caratteri";
        } else if (msgEx.contains("invalid format") ||
            msgEx.contains("Unable to validate email")) {
          _errorText = "Indirizzo email non valido";
        } else if (msgEx.toLowerCase().contains("already registered")) {
          _errorText = "Questa email è già registrata!";
        } else {
          _errorText = "Errore durante la registrazione";
        }
        _successText = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("📝", style: TextStyle(fontSize: 60)),
              const Text(
                "REGISTRAZIONE",
                style: TextStyle(
                  fontSize: StyleConfig.textSizeTitolo,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Campi di input
              _buildField(_nomeController, "Nome"),
              const SizedBox(height: 10),
              _buildField(_cognomeController, "Cognome"),
              const SizedBox(height: 10),
              _buildField(
                _emailController,
                "Email",
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              _buildField(_passController, "Password", obscure: true),
              const SizedBox(height: 10),

              // Dropdown Ruolo
              SizedBox(
                width: 300,
                child: DropdownButtonFormField<String>(
                  value: _ruoloSelezionato,
                  decoration: StyleConfig.campoTestoDecoration(label: "Ruolo"),
                  items: const [
                    DropdownMenuItem(value: "atleta", child: Text("Atleta")),
                    DropdownMenuItem(value: "trainer", child: Text("Trainer")),
                  ],
                  onChanged: (val) => setState(() => _ruoloSelezionato = val),
                ),
              ),

              // Messaggi di stato
              if (_errorText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    _errorText,
                    style: const TextStyle(
                      color: StyleConfig.colorErrore,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (_successText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: const Text(
                    "Account creato con successo!",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Bottone CREA ACCOUNT
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _eseguiRegistrazione,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("CREA ACCOUNT"),
                ),
              ),

              TextButton(
                onPressed: widget.vaiALogin,
                child: const Text("Torna al Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: StyleConfig.campoTestoDecoration(label: label),
      ),
    );
  }
}
