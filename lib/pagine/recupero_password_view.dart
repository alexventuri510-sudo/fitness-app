import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme/style_config.dart';

class RecuperoPasswordView extends StatefulWidget {
  final VoidCallback vaiALogin;

  const RecuperoPasswordView({super.key, required this.vaiALogin});

  @override
  State<RecuperoPasswordView> createState() => _RecuperoPasswordViewState();
}

class _RecuperoPasswordViewState extends State<RecuperoPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  bool _isCaricamento = false; // Per gestire il ProgressRing

  Future<void> _inviaReset() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inserisci l'indirizzo email"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCaricamento = true);

    try {
      // Nota: Aggiungi questa funzione al tuo DatabaseService se non l'abbiamo fatto
      // Altrimenti usiamo direttamente Supabase.instance.client.auth.resetPasswordForEmail
      await DatabaseService.supabase.auth.resetPasswordForEmail(
        _emailController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email di reset inviata! Controlla la tua posta."),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      widget.vaiALogin();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Errore nell'invio. Verifica l'email."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCaricamento = false);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                "RECUPERO PASSWORD",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 300,
                child: Text(
                  "Inserisci la tua email per ricevere il link di reset.",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Campo Email
              SizedBox(
                width: 340,
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: StyleConfig.campoTestoDecoration(
                    label: "Inserisci la tua email",
                  ).copyWith(hintText: "esempio@email.it"),
                ),
              ),

              const SizedBox(height: 10),

              // Bottone con caricamento
              SizedBox(
                width: 340,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isCaricamento ? null : _inviaReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isCaricamento
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "INVIA EMAIL DI RESET",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 20),

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
}
