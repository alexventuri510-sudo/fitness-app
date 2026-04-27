import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class AtletaPianoXView extends StatefulWidget {
  final String planId;
  final int settimana;
  final String nomeAtleta;
  final VoidCallback vaiIndietro;
  final Function(List<dynamic>, int, int) vaiADettaglioEsercizio;
  final String? dataPianoStr;

  const AtletaPianoXView({
    super.key,
    required this.planId,
    required this.settimana,
    required this.nomeAtleta,
    required this.vaiIndietro,
    required this.vaiADettaglioEsercizio,
    this.dataPianoStr,
  });

  @override
  State<AtletaPianoXView> createState() => _AtletaPianoXViewState();
}

class _AtletaPianoXViewState extends State<AtletaPianoXView> {
  List<dynamic> _esercizi = [];
  bool _isLoading = true;
  String _titoloGiorno = "";
  String _dataInizioSottotitolo = "";

  @override
  void initState() {
    super.initState();
    _preparaDate();
    _caricaEsercizi();
  }

  void _preparaDate() {
    if (widget.dataPianoStr != null && widget.dataPianoStr!.isNotEmpty) {
      try {
        DateTime dataPiano = DateTime.parse(widget.dataPianoStr!.split("T")[0]);

        // Formattazione Giorno Settimana (Lunedì, Martedì...)
        String giornoSettimana = DateFormat(
          'EEEE',
          'it_IT',
        ).format(dataPiano).toUpperCase();
        String dataFormattata = DateFormat('dd/MM/yyyy').format(dataPiano);

        _titoloGiorno = "ALLENAMENTO DI $giornoSettimana DEL $dataFormattata";
        _dataInizioSottotitolo = "Allenamento iniziato il $dataFormattata";
      } catch (e) {
        _titoloGiorno = "SESSIONE DI ALLENAMENTO";
        _dataInizioSottotitolo = "";
      }
    }
  }

  Future<void> _caricaEsercizi() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final dati = await DatabaseService.getEserciziPiano(
        widget.planId,
        widget.settimana,
      );
      if (mounted) {
        setState(() {
          _esercizi = dati;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("DEBUG: Errore caricamento esercizi PianoX: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: widget.vaiIndietro,
        ),
        title: const Text(
          "SESSIONE ATTIVA",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
            ),
            child: Column(
              children: [
                Text(
                  _titoloGiorno,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "SETTIMANA ${widget.settimana}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                if (_dataInizioSottotitolo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _dataInizioSottotitolo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                : _esercizi.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _esercizi.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> es = Map<String, dynamic>.from(
                        _esercizi[index],
                      );
                      return _buildEsercizioCard(es, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEsercizioCard(Map<String, dynamic> es, int index) {
    // Controllo se l'atleta ha inserito dati (pesi o note)
    final String pesiSalvati = es['series_weights_atleta'] ?? "";
    final String noteAtleta = es['note_atleta'] ?? "";

    // Il pulsante diventa verde se ci sono pesi inseriti o se la nota non è vuota
    final bool isCompletato =
        pesiSalvati.split(',').any((v) => v.trim().isNotEmpty) ||
        noteAtleta.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCompletato
              ? Colors.green.shade300
              : Colors.black.withOpacity(0.08),
          width: isCompletato ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 14),
            children: [
              TextSpan(
                text: "${index + 1}) ",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.blue,
                ),
              ),
              TextSpan(
                text:
                    es['exercise_name']?.toString().toUpperCase() ??
                    'ESERCIZIO',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "Target: ${es['sets_reps'] ?? '-'}",
            style: const TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        trailing: SizedBox(
          width: 90,
          child: ElevatedButton(
            onPressed: () async {
              await widget.vaiADettaglioEsercizio(
                _esercizi,
                index,
                widget.settimana,
              );
              _caricaEsercizi();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompletato ? Colors.green : Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              isCompletato ? "MODIFICA" : "INIZIA",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 50,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          const Text(
            "Nessun esercizio trovato",
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
