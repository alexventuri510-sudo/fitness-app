import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModificaEsercizioView extends StatefulWidget {
  final Map<String, dynamic> datiEsercizio;
  final VoidCallback vaiIndietro;

  const ModificaEsercizioView({
    super.key,
    required this.datiEsercizio,
    required this.vaiIndietro,
  });

  @override
  State<ModificaEsercizioView> createState() => _ModificaEsercizioViewState();
}

class _ModificaEsercizioViewState extends State<ModificaEsercizioView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _setsRepsController;
  late TextEditingController _seriesCountController;
  late TextEditingController _restSecondsController;
  late TextEditingController _linkController;
  late TextEditingController _trainerNotesController;

  bool _caricamento = false;

  @override
  void initState() {
    super.initState();
    // Inizializzazione dei controller con i dati esistenti
    _nomeController = TextEditingController(
      text: widget.datiEsercizio['exercise_name']?.toString() ?? "",
    );
    _setsRepsController = TextEditingController(
      text: widget.datiEsercizio['sets_reps']?.toString() ?? "",
    );
    _seriesCountController = TextEditingController(
      text: widget.datiEsercizio['series_count']?.toString() ?? "1",
    );
    _restSecondsController = TextEditingController(
      text: widget.datiEsercizio['rest_seconds']?.toString() ?? "0",
    );
    _linkController = TextEditingController(
      text: widget.datiEsercizio['video_link']?.toString() ?? "",
    );
    _trainerNotesController = TextEditingController(
      text: widget.datiEsercizio['trainer_notes']?.toString() ?? "",
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _setsRepsController.dispose();
    _seriesCountController.dispose();
    _restSecondsController.dispose();
    _linkController.dispose();
    _trainerNotesController.dispose();
    super.dispose();
  }

  Future<void> _salvaModifiche() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _caricamento = true);

    try {
      final supabase = Supabase.instance.client;

      await supabase
          .from('exercises')
          .update({
            'exercise_name': _nomeController.text.trim(),
            'sets_reps': _setsRepsController.text.trim(),
            'series_count': int.tryParse(_seriesCountController.text) ?? 1,
            'rest_seconds': int.tryParse(_restSecondsController.text) ?? 0,
            'video_link': _linkController.text.trim(),
            'trainer_notes': _trainerNotesController.text.trim(),
            // 'updated_at' verrà aggiornato automaticamente dal trigger SQL
          })
          .eq('id', widget.datiEsercizio['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Esercizio aggiornato con successo!"),
            backgroundColor: Colors.green,
          ),
        );

        // Restituiamo 'true' per notificare alla lista di ricaricarsi
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Errore durante il salvataggio: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _caricamento = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "<- ANNULLA",
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ),
        title: const Text(
          "MODIFICA ESERCIZIO",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "DATI PRINCIPALI",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _inputField(_nomeController, "Nome Esercizio"),
              _inputField(
                _setsRepsController,
                "Serie e Ripetizioni (es: 4 x 10)",
              ),
              _inputField(
                _seriesCountController,
                "Numero serie (es: 4)",
                isNumber: true,
              ),
              _inputField(
                _restSecondsController,
                "Recupero in secondi (es: 90)",
                isNumber: true,
              ),
              const SizedBox(height: 20),
              const Text(
                "CONTENUTI EXTRA",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _inputField(_linkController, "Link Video Tutorial"),
              _inputField(
                _trainerNotesController,
                "Note Tecniche per l'Atleta",
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _caricamento ? null : _salvaModifiche,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _caricamento
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "SALVA MODIFICHE",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) {
          if ((v == null || v.isEmpty) && label.contains("Nome")) {
            return "Il nome è obbligatorio";
          }
          return null;
        },
      ),
    );
  }
}
