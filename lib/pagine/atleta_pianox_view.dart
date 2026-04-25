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
  String _titoloAllenamento = "SESSIONE DI ALLENAMENTO";

  @override
  void initState() {
    super.initState();
    _preparaTitolo();
    _caricaEsercizi();
  }

  void _preparaTitolo() {
    if (widget.dataPianoStr != null && widget.dataPianoStr!.isNotEmpty) {
      try {
        DateTime dataPiano = DateTime.parse(widget.dataPianoStr!.split("T")[0]);
        DateTime ora = DateTime.now();
        DateTime oggi = DateTime(ora.year, ora.month, ora.day);
        DateTime domani = oggi.add(const Duration(days: 1));

        if (dataPiano.isAtSameMomentAs(oggi)) {
          _titoloAllenamento = "Allenamento di oggi";
        } else if (dataPiano.isAtSameMomentAs(domani)) {
          _titoloAllenamento = "Allenamento di domani";
        } else {
          _titoloAllenamento =
              "Allenamento del ${DateFormat('dd/MM/yyyy').format(dataPiano)}";
        }
      } catch (e) {
        _titoloAllenamento = "Allenamento programmato";
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
            ),
            child: Column(
              children: [
                Text(
                  _titoloAllenamento.toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "SETTIMANA ${widget.settimana}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
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
    final String pesiSalvati = es['series_weights_atleta'] ?? "";
    final bool isCompletato = pesiSalvati
        .split(',')
        .any((v) => v.trim().isNotEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCompletato
              ? Colors.green.shade200
              : Colors.black.withOpacity(0.08),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          "${index + 1}. ${es['exercise_name']?.toString().toUpperCase() ?? 'ESERCIZIO'}",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "Target: ${es['sets_reps'] ?? '-'}",
            style: const TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            // 1. Aspetta la chiusura della pagina dettaglio
            await widget.vaiADettaglioEsercizio(
              _esercizi,
              index,
              widget.settimana,
            );

            // 2. Appena l'utente torna indietro, ricarica i dati freschi dal DB
            _caricaEsercizi();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isCompletato ? Colors.green : Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: Text(
            isCompletato ? "VEDI/MOD" : "INIZIA",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
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
