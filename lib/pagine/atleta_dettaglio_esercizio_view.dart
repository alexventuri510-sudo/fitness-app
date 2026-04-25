import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AtletaDettaglioEsercizioView extends StatelessWidget {
  final List<dynamic> listaEsercizi;
  final int indiceAttuale;
  final VoidCallback vaiIndietro;
  final Function(int) cambiaEsercizio;

  const AtletaDettaglioEsercizioView({
    super.key,
    required this.listaEsercizi,
    required this.indiceAttuale,
    required this.vaiIndietro,
    required this.cambiaEsercizio,
  });

  // Funzione per aprire il video
  Future<void> _apriVideo(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Errore apertura video: $e');
    }
  }

  // Helper per estrarre valori in modo sicuro dalle stringhe CSV
  String _getVal(List<String> lista, int index) {
    if (index >= 0 && index < lista.length) {
      String val = lista[index].trim();
      return val.isEmpty ? "-" : val;
    }
    return "-";
  }

  @override
  Widget build(BuildContext context) {
    if (listaEsercizi.isEmpty)
      return const Scaffold(body: Center(child: Text("Nessun dato")));

    final dati = listaEsercizi[indiceAttuale];

    // Recupero dati base
    final String nome = (dati['exercise_name'] ?? "Esercizio")
        .toString()
        .toUpperCase();
    final String target = dati['sets_reps'] ?? "-";
    final String recupero = (dati['rest_seconds'] ?? "0").toString();
    final String notePt = dati['trainer_notes'] ?? "Nessuna nota inserita.";
    final String noteAtleta =
        dati['athlete_notes'] ?? "Nessuna nota registrata.";
    final String videoLink = (dati['video_link'] ?? "").toString().trim();

    // Logica Multi-serie
    final int nSerie = dati['series_count'] ?? 1;

    // Split sicuro: se la stringa è null o vuota, restituisce una lista vuota
    List<String> pesiScorsi = (dati['series_weights_scorsi']?.toString() ?? "")
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList();
    List<String> pesiOggi = (dati['series_weights_atleta']?.toString() ?? "")
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList();
    List<String> repsOggi = (dati['series_reps_atleta']?.toString() ?? "")
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: vaiIndietro,
        ),
        title: Text(
          "ESERCIZIO ${indiceAttuale + 1} DI ${listaEsercizi.length}",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SCHEDA INFO ESERCIZIO ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        size: 18,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Target: $target",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Recupero: $recupero secondi",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const Divider(height: 25),
                  const Text(
                    "NOTE DEL TRAINER:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notePt,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- SCHEDA RIASSUNTO SESSIONE ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "DATI REGISTRATI",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Intestazione Tabella
                  Row(
                    children: [
                      _headerCell("SET", 1),
                      _headerCell("SCORSI", 2),
                      _headerCell("KG OGGI", 2, color: Colors.blue),
                      _headerCell("REPS", 1, color: Colors.blue),
                    ],
                  ),
                  const Divider(),
                  // Righe serie
                  for (int i = 0; i < nSerie; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
                            child: Text("${_getVal(pesiScorsi, i)} kg"),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${_getVal(pesiOggi, i)} kg",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              _getVal(repsOggi, i),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Divider(),
                  const Text(
                    "LE TUE NOTE:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    noteAtleta,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- SEZIONE VIDEO ---
            if (videoLink.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _apriVideo(videoLink),
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text("GUARDA VIDEO TUTORIAL"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // --- NAVIGAZIONE ---
            Row(
              children: [
                if (indiceAttuale > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => cambiaEsercizio(indiceAttuale - 1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("PRECEDENTE"),
                    ),
                  )
                else
                  const Spacer(),

                const SizedBox(width: 15),

                if (indiceAttuale < listaEsercizi.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => cambiaEsercizio(indiceAttuale + 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("SUCCESSIVO"),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String testo, int flex, {Color color = Colors.black}) {
    return Expanded(
      flex: flex,
      child: Text(
        testo,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: color,
        ),
      ),
    );
  }
}
