import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DettaglioEsercizioView extends StatelessWidget {
  final List<dynamic> listaEsercizi;
  final int indiceAttuale;
  final VoidCallback vaiIndietro;
  final Function(int) cambiaEsercizio;

  const DettaglioEsercizioView({
    super.key,
    required this.listaEsercizi,
    required this.indiceAttuale,
    required this.vaiIndietro,
    required this.cambiaEsercizio,
  });

  // Funzione di utilità per gestire i valori nulli o vuoti delle liste CSV
  String _getVal(List<String> lista, int index) {
    if (index >= lista.length || lista[index].trim().isEmpty) return "-";
    return lista[index].trim();
  }

  Future<void> _apriVideo(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dati = listaEsercizi[indiceAttuale];

    // Recupero dati e parsing multi-serie
    final String nome = (dati['exercise_name'] ?? "Esercizio")
        .toString()
        .toUpperCase();
    final String target = dati['sets_reps'] ?? "-";
    final String recupero = dati['rest_seconds']?.toString() ?? "0";
    final String notePT = dati['trainer_notes'] ?? "Nessuna nota inserita.";
    final String noteAtleta =
        dati['athlete_notes'] ?? "L'atleta non ha inserito note.";
    final String linkVideo = dati['video_link'] ?? "";

    final int nSerie = dati['series_count'] ?? 1;
    final List<String> pesiAtleta = (dati['series_weights_atleta'] ?? "")
        .toString()
        .split(',');
    final List<String> repsAtleta = (dati['series_reps_atleta'] ?? "")
        .toString()
        .split(',');
    final List<String> pesiScorsi = (dati['series_weights_scorsi'] ?? "")
        .toString()
        .split(',');

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: vaiIndietro,
          child: const Text(
            "<- INDIETRO",
            style: TextStyle(color: Colors.blue, fontSize: 10),
          ),
        ),
        title: const Text(
          "REPORT ATLETA",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // SCHEDA 1: COSA HAI ASSEGNATO (PT)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Target assegnato: $target",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Recupero: $recupero\"",
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "TUE NOTE:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    notePT,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // SCHEDA 2: COSA HA FATTO L'ATLETA (REPORT)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PERFORMANCE ATLETA",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Tabella Intestazione
                  const Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "SET",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "PREC.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "KG ATLETA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "REPS",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Generazione righe per ogni serie
                  for (int i = 0; i < nSerie; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Text("#${i + 1}")),
                          Expanded(
                            flex: 2,
                            child: Text("${_getVal(pesiScorsi, i)} kg"),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${_getVal(pesiAtleta, i)} kg",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              _getVal(repsAtleta, i),
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
                    "NOTE DELL'ATLETA:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      noteAtleta,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // SEZIONE VIDEO
            if (linkVideo.isNotEmpty) ...[
              const Text(
                "VIDEO TUTORIAL:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                onPressed: () => _apriVideo(linkVideo),
                icon: const Icon(Icons.play_circle_fill),
                label: const Text("GUARDA IL VIDEO"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],

            const Divider(height: 40),

            // NAVIGAZIONE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (indiceAttuale > 0)
                  ElevatedButton(
                    onPressed: () => cambiaEsercizio(indiceAttuale - 1),
                    child: const Text("PRECEDENTE"),
                  )
                else
                  const SizedBox(width: 100),

                if (indiceAttuale < listaEsercizi.length - 1)
                  ElevatedButton(
                    onPressed: () => cambiaEsercizio(indiceAttuale + 1),
                    child: const Text("SUCCESSIVO"),
                  )
                else
                  const SizedBox(width: 100),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
