import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class PianiAllenamentoView extends StatefulWidget {
  final String atletaId;
  final String nomeAtleta;
  final VoidCallback vaiIndietro;
  final Function(String id, String nome) vaiACreaPiano;
  final Function(dynamic piano) vaiAListaEsercizi;

  const PianiAllenamentoView({
    super.key,
    required this.atletaId,
    required this.nomeAtleta,
    required this.vaiIndietro,
    required this.vaiACreaPiano,
    required this.vaiAListaEsercizi,
  });

  @override
  State<PianiAllenamentoView> createState() => _PianiAllenamentoViewState();
}

class _PianiAllenamentoViewState extends State<PianiAllenamentoView> {
  bool _mostraPassati = false;
  late Future<List<dynamic>> _futurePiani;

  final Map<String, int> _ordineGiorni = {
    "Lunedì": 1,
    "Martedì": 2,
    "Mercoledì": 3,
    "Giovedì": 4,
    "Venerdì": 5,
    "Sabato": 6,
    "Domenica": 7,
  };

  @override
  void initState() {
    super.initState();
    _caricaPiani();
  }

  // --- MODIFICA FONDAMENTALE: Metodo per ricaricare ---
  void _caricaPiani() {
    setState(() {
      _futurePiani = DatabaseService.getPianiAtleta(widget.atletaId);
    });
  }

  // Gestisce la navigazione al "Crea Piano" e ricarica al ritorno
  Future<void> _gestisciNuovoPiano() async {
    // Aspettiamo che la navigazione finisca (quando l'utente preme indietro o salva)
    await widget.vaiACreaPiano(widget.atletaId, widget.nomeAtleta);
    // Una volta tornati in questa pagina, ricarichiamo i dati
    _caricaPiani();
  }

  void _confermaEliminazione(String pid, String giorno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Conferma eliminazione"),
        content: Text("Sei sicuro di voler eliminare il piano di $giorno?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await DatabaseService.eliminaPianoAllenamento(
                pid,
              );
              if (success) {
                _caricaPiani();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Piano di $giorno eliminato")),
                  );
                }
              }
            },
            child: const Text(
              "Sì, elimina",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: widget.vaiIndietro,
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    label: const Text(
                      "LISTA ATLETI",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Text(
                    widget.nomeAtleta.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const Divider(),

              // --- PULSANTE AGGIORNATO ---
              ElevatedButton(
                onPressed: _gestisciNuovoPiano, // Usa il nuovo metodo asincrono
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("NUOVO PIANO"),
              ),

              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  // Aggiunto per permettere il refresh manuale
                  onRefresh: () async => _caricaPiani(),
                  child: FutureBuilder<List<dynamic>>(
                    future: _futurePiani,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        );
                      }

                      final piani = snapshot.data ?? [];
                      if (piani.isEmpty) {
                        return ListView(
                          // Usiamo ListView per far funzionare il RefreshIndicator
                          children: const [
                            SizedBox(height: 50),
                            Center(
                              child: Text(
                                "Nessun piano creato.",
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        );
                      }

                      List<dynamic> attivi = [];
                      List<dynamic> passati = [];
                      DateTime oggi = DateTime.now();
                      DateTime oggiSoloData = DateTime(
                        oggi.year,
                        oggi.month,
                        oggi.day,
                      );

                      for (var p in piani) {
                        DateTime startDate = DateTime.parse(p['start_date']);
                        int durationWeeks = p['duration_weeks'] ?? 0;
                        DateTime scadenza = startDate.add(
                          Duration(days: durationWeeks * 7),
                        );

                        if (oggi.isAfter(scadenza)) {
                          passati.add(p);
                        } else {
                          attivi.add(p);
                        }
                      }

                      attivi.sort(
                        (a, b) => (_ordineGiorni[a['day_of_week']] ?? 99)
                            .compareTo(_ordineGiorni[b['day_of_week']] ?? 99),
                      );

                      return ListView(
                        children: [
                          const Text(
                            "PIANI ATTIVI",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...attivi.map(
                            (p) => _buildCardPiano(p, false, oggiSoloData),
                          ),

                          if (passati.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => setState(
                                () => _mostraPassati = !_mostraPassati,
                              ),
                              child: Text(
                                _mostraPassati
                                    ? "NASCONDI STORICO"
                                    : "MOSTRA STORICO PIANI",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                            if (_mostraPassati)
                              ...passati.map(
                                (p) => _buildCardPiano(p, true, oggiSoloData),
                              ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPiano(dynamic p, bool isPassato, DateTime oggi) {
    DateTime startDate = DateTime.parse(p['start_date']);
    String dataFormattata = DateFormat('dd/MM/yyyy').format(startDate);
    int settimaneTotali = p['duration_weeks'] ?? 0;
    String testoSettimana = "";

    if (!isPassato) {
      if (oggi.isBefore(startDate)) {
        testoSettimana = "Settimana attuale: - (Non ancora iniziato)";
      } else {
        int giorniPassati = oggi.difference(startDate).inDays;
        int settCalc = (giorniPassati ~/ 7) + 1;
        testoSettimana =
            "Settimana attuale: ${settCalc > settimaneTotali ? settimaneTotali : settCalc}";
      }
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: isPassato ? Colors.grey[100] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['day_of_week'].toString().toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isPassato ? Colors.grey : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Inizio: $dataFormattata",
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (testoSettimana.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          testoSettimana,
                          style: TextStyle(
                            color: isPassato ? Colors.grey : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      Text(
                        "Durata: $settimaneTotali sett.",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 30),
                      onPressed: () => widget.vaiAListaEsercizi(p),
                    ),
                    const Text(
                      "VEDI",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    _confermaEliminazione(p['id'].toString(), p['day_of_week']),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text("ELIMINA"),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
