import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AtletaModificaDettaglioEsercizioView extends StatefulWidget {
  final List<dynamic> listaEsercizi;
  final int indiceAttuale;
  final VoidCallback vaiIndietro;
  final Function(String id, List<String> pesi, List<String> reps, String note)
  salvaDati;
  final Function(int) cambiaEsercizio;

  const AtletaModificaDettaglioEsercizioView({
    super.key,
    required this.listaEsercizi,
    required this.indiceAttuale,
    required this.vaiIndietro,
    required this.salvaDati,
    required this.cambiaEsercizio,
  });

  @override
  State<AtletaModificaDettaglioEsercizioView> createState() =>
      _AtletaModificaDettaglioEsercizioViewState();
}

class _AtletaModificaDettaglioEsercizioViewState
    extends State<AtletaModificaDettaglioEsercizioView> {
  final List<TextEditingController> _controllersKg = [];
  final List<TextEditingController> _controllersReps = [];
  final TextEditingController _controllerNote = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inizializzaCampi();
  }

  void _inizializzaCampi() {
    final dati = Map<String, dynamic>.from(
      widget.listaEsercizi[widget.indiceAttuale],
    );
    final int nSerie = dati['series_count'] ?? 1;

    for (var c in _controllersKg) {
      c.dispose();
    }
    for (var c in _controllersReps) {
      c.dispose();
    }
    _controllersKg.clear();
    _controllersReps.clear();

    List<String> pesiOggi = (dati['series_weights_atleta']?.toString() ?? "")
        .split(',');
    List<String> repsOggi = (dati['series_reps_atleta']?.toString() ?? "")
        .split(',');

    for (int i = 0; i < nSerie; i++) {
      _controllersKg.add(TextEditingController(text: _getVal(pesiOggi, i)));
      _controllersReps.add(TextEditingController(text: _getVal(repsOggi, i)));
    }
    _controllerNote.text = dati['athlete_notes'] ?? "";
  }

  String _getVal(List<String> lista, int index) {
    if (index >= 0 && index < lista.length) {
      return lista[index].trim();
    }
    return "";
  }

  void _eseguiSalvataggio() {
    final dati = widget.listaEsercizi[widget.indiceAttuale];
    final String idEs = dati['id'].toString();

    List<String> nuoviPesi = _controllersKg.map((c) => c.text).toList();
    List<String> nuoveReps = _controllersReps.map((c) => c.text).toList();
    String nuoveNote = _controllerNote.text;

    // Aggiornamento locale immediato
    widget.listaEsercizi[widget.indiceAttuale]['series_weights_atleta'] =
        nuoviPesi.join(',');
    widget.listaEsercizi[widget.indiceAttuale]['series_reps_atleta'] = nuoveReps
        .join(',');
    widget.listaEsercizi[widget.indiceAttuale]['athlete_notes'] = nuoveNote;

    widget.salvaDati(idEs, nuoviPesi, nuoveReps, nuoveNote);
  }

  Future<void> _apriVideo(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void dispose() {
    for (var c in _controllersKg) {
      c.dispose();
    }
    for (var c in _controllersReps) {
      c.dispose();
    }
    _controllerNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dati = Map<String, dynamic>.from(
      widget.listaEsercizi[widget.indiceAttuale],
    );
    final String nome = (dati['exercise_name'] ?? "Esercizio")
        .toString()
        .toUpperCase();
    final String target = dati['sets_reps'] ?? "-";
    final String recupero = (dati['rest_seconds'] ?? "0").toString();
    final String notePt = dati['trainer_notes'] ?? "Nessuna nota.";
    final String videoLink = (dati['video_link'] ?? "").toString().trim();
    List<String> pesiScorsi = (dati['series_weights_scorsi']?.toString() ?? "")
        .split(',');

    return PopScope(
      canPop: false, // Gestiamo noi il pop per forzare il refresh
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(
          context,
        ).pop(true); // Restituisce true per forzare il refresh
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(true), // Chiudi con segnale di refresh
            child: const Text(
              "CHIUDI",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          leadingWidth: 80,
          title: const Text(
            "LOG SESSIONE",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "OBIETTIVO: $target",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "RECUPERO: $recupero secondi",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Divider(height: 25),
                      const Text(
                        "INDICAZIONI DEL TRAINER:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notePt,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_note, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            "INSERISCI DATI",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _headerCol("SET", 1),
                          _headerCol("PREC.", 2),
                          _headerCol("KG OGGI", 2),
                          _headerCol("REPS", 2),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (int i = 0; i < _controllersKg.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "#${i + 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "${_getVal(pesiScorsi, i)} kg",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: TextField(
                                    controller: _controllersKg[i],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: _inputStyle(hint: "0"),
                                    textAlign: TextAlign.center,
                                    onChanged: (_) => _eseguiSalvataggio(),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _controllersReps[i],
                                  keyboardType: TextInputType.number,
                                  decoration: _inputStyle(hint: "0"),
                                  textAlign: TextAlign.center,
                                  onChanged: (_) => _eseguiSalvataggio(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Divider(height: 30),
                      const Text(
                        "NOTE PERSONALI:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controllerNote,
                        maxLines: 2,
                        decoration: _inputStyle(
                          hint: "Come hai sentito il peso?",
                        ),
                        onChanged: (_) => _eseguiSalvataggio(),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(
                            Icons.cloud_done,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Sincronizzazione attiva",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (videoLink.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _apriVideo(videoLink),
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text("GUARDA VIDEO ESECUZIONE"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      side: const BorderSide(color: Colors.blueAccent),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _navButton(
                      label: "PRECEDENTE",
                      onPressed: widget.indiceAttuale > 0
                          ? () {
                              _eseguiSalvataggio(); // Salva prima di cambiare
                              widget.cambiaEsercizio(widget.indiceAttuale - 1);
                              setState(() => _inizializzaCampi());
                            }
                          : null,
                    ),
                    _navButton(
                      label: "SUCCESSIVO",
                      onPressed:
                          widget.indiceAttuale < widget.listaEsercizi.length - 1
                          ? () {
                              _eseguiSalvataggio(); // Salva prima di cambiare
                              widget.cambiaEsercizio(widget.indiceAttuale + 1);
                              setState(() => _inizializzaCampi());
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCol(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 10,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _navButton({required String label, VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade200,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  InputDecoration _inputStyle({String? hint}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      fillColor: const Color(0xFFF8F9FA),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.orange),
      ),
    );
  }
}
