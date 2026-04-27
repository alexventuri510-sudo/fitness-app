import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme/style_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NuovaPasswordView extends StatefulWidget {
  final VoidCallback vaiALogin;

  const NuovaPasswordView({super.key, required this.vaiALogin});

  @override
  State<NuovaPasswordView> createState() => _NuovaPasswordViewState();
}

class _NuovaPasswordViewState extends State<NuovaPasswordView> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confermaPassController = TextEditingController();
  bool _isCaricamento = false;
  bool _obscureText = true;

  Future<void> _aggiornaPassword() async {
    final pass = _passController.text.trim();
    final conferma = _confermaPassController.text.trim();

    // 1. Controlli base
    if (pass.isEmpty || conferma.isEmpty) {
      _mostraMessaggio("Compila entrambi i campi", Colors.red);
      return;
    }

    if (pass.length < 6) {
      _mostraMessaggio("La password deve avere almeno 6 caratteri", Colors.red);
      return;
    }

    if (pass != conferma) {
      _mostraMessaggio("Le password non coincidono", Colors.red);
      return;
    }

    setState(() => _isCaricamento = true);

    try {
      // 2. Aggiornamento su Supabase
      await DatabaseService.supabase.auth.updateUser(
        UserAttributes(password: pass),
      );

      if (!mounted) return;

      _mostraMessaggio("Password aggiornata con successo!", Colors.green);

      // 3. Piccolo delay e ritorno al login
      await Future.delayed(const Duration(seconds: 2));
      widget.vaiALogin();
    } catch (e) {
      _mostraMessaggio("Errore durante l'aggiornamento. Riprova.", Colors.red);
    } finally {
      if (mounted) setState(() => _isCaricamento = false);
    }
  }

  void _mostraMessaggio(String testo, Color colore) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(testo), backgroundColor: colore));
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
              const Icon(Icons.lock_reset, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "IMPOSTA NUOVA PASSWORD",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Campo Nuova Password
              SizedBox(
                width: 340,
                child: TextField(
                  controller: _passController,
                  obscureText: _obscureText,
                  decoration:
                      StyleConfig.campoTestoDecoration(
                        label: "Nuova Password",
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 15),

              // Campo Conferma Password
              SizedBox(
                width: 340,
                child: TextField(
                  controller: _confermaPassController,
                  obscureText: _obscureText,
                  decoration: StyleConfig.campoTestoDecoration(
                    label: "Conferma Nuova Password",
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Bottone Conferma
              SizedBox(
                width: 340,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isCaricamento ? null : _aggiornaPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isCaricamento
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "AGGIORNA PASSWORD",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
