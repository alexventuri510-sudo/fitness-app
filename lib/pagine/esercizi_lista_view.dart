import 'package:flutter/material.dart';
import '../services/database_service.dart';

class EserciziListaView extends StatefulWidget {
  final String planId;
  final int durataSettimane;
  final VoidCallback vaiIndietro;
  final Function(String planId, int sett) vaiAAggiungiEsercizio;
  final Function(List<dynamic> lista, int index, int sett) vaiADettaglio;
  final Function(dynamic esercizio, int sett) vaiAModifica;

  const EserciziListaView({
    super.key,
    required this.planId,
    required this.durataSettimane,
    required this.vaiIndietro,
    required this.vaiAAggiungiEsercizio,
    required this.vaiADettaglio,
    required this.vaiAModifica,
  });

  @override
  State<EserciziListaView> createState() => _EserciziListaViewState();
}

class _EserciziListaViewState extends State<EserciziListaView> {
  int _settimanaAttuale = 1;
  bool _modalitaRiordino = false;
  List<dynamic> _esercizi = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _caricaEsercizi();
  }

  Future<void> _caricaEsercizi() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final dati = await DatabaseService.getEserciziPiano(
        widget.planId,
        _settimanaAttuale,
      );

      if (mounted) {
        setState(() {
          _esercizi = dati;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      debugPrint("Errore caricamento esercizi: $e");
    }
  }

  // --- LOGICA DI REFRESH AGGIORNATA ---

  void _gestisciAggiuntaEsercizio() async {
    // Aspetta che la pagina di aggiunta venga chiusa
    await widget.vaiAAggiungiEsercizio(widget.planId, _settimanaAttuale);
    // Refresh automatico al ritorno
    _caricaEsercizi();
  }

  void _gestisciModificaEsercizio(dynamic es) async {
    // Aspetta che la pagina di modifica venga chiusa
    await widget.vaiAModifica(es, _settimanaAttuale);
    // Refresh automatico al ritorno
    _caricaEsercizi();
  }

  void _gestisciVisualizzazioneDettaglio(int index) async {
    // Aspetta che la pagina dettaglio (dove potresti fare modifiche) venga chiusa
    await widget.vaiADettaglio(_esercizi, index, _settimanaAttuale);
    // Refresh automatico al ritorno
    _caricaEsercizi();
  }

  // ------------------------------------

  void _sposta(int index, String direzione) async {
    int targetIndex = direzione == "su" ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= _esercizi.length) return;

    final idCorrente = _esercizi[index]['id'];
    final idTarget = _esercizi[targetIndex]['id'];

    setState(() {
      final item = _esercizi.removeAt(index);
      _esercizi.insert(targetIndex, item);
    });

    await DatabaseService.spostaEsercizio(idCorrente.toString(), targetIndex);
    await DatabaseService.spostaEsercizio(idTarget.toString(), index);
  }

  void _confermaElimina(dynamic es) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Conferma"),
        content: Text("Vuoi eliminare ${es['exercise_name']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseService.eliminaEsercizio(es['id'].toString());
              _caricaEsercizi();
            },
            child: const Text("Elimina", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.vaiIndietro,
        ),
        title: const Text(
          "PROGRAMMAZIONE",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "SELEZIONA SETTIMANA:",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.durataSettimane,
                itemBuilder: (context, i) {
                  int n = i + 1;
                  bool isActive = n == _settimanaAttuale;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _settimanaAttuale = n;
                          _modalitaRiordino = false;
                        });
                        _caricaEsercizi();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? Colors.blue
                            : Colors.grey[100],
                        foregroundColor: isActive ? Colors.white : Colors.blue,
                        elevation: 0,
                      ),
                      child: Text("SETT $n"),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _gestisciAggiuntaEsercizio,
              icon: const Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: const Text(
                "AGGIUNGI ESERCIZIO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_settimanaAttuale == 1)
                  TextButton.icon(
                    onPressed: () async {
                      final res = await DatabaseService.copiaSettimanaUno(
                        widget.planId,
                        widget.durataSettimane,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res['msg']),
                            backgroundColor: res['success']
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                        if (res['success']) _caricaEsercizi();
                      }
                    },
                    icon: const Icon(
                      Icons.copy_all,
                      size: 18,
                      color: Colors.orange,
                    ),
                    label: const Text(
                      "Copia Sett. 1",
                      style: TextStyle(color: Colors.orange, fontSize: 13),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _modalitaRiordino = !_modalitaRiordino),
                  icon: Icon(
                    Icons.swap_vert,
                    color: _modalitaRiordino ? Colors.green : Colors.orange,
                  ),
                  label: Text(
                    _modalitaRiordino ? "SALVA ORDINE" : "RIORDINA",
                    style: TextStyle(
                      color: _modalitaRiordino ? Colors.green : Colors.orange,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
                  : RefreshIndicator(
                      onRefresh: _caricaEsercizi,
                      child: _esercizi.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 100),
                                Center(
                                  child: Text(
                                    "Nessun esercizio per la Settimana $_settimanaAttuale",
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: _esercizi.length,
                              itemBuilder: (context, index) {
                                final es = _esercizi[index];
                                return _buildCardEsercizio(es, index);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardEsercizio(dynamic es, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (_modalitaRiordino)
            Column(
              children: [
                if (index > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_up, color: Colors.blue),
                    onPressed: () => _sposta(index, "su"),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (index < _esercizi.length - 1)
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    onPressed: () => _sposta(index, "giu"),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  es['exercise_name']?.toString().toUpperCase() ?? "ESERCIZIO",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dettaglio: ${es['sets_reps'] ?? 'N/D'}",
                  style: TextStyle(color: Colors.blueGrey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.visibility,
                  size: 20,
                  color: Colors.blueGrey,
                ),
                onPressed: () => _gestisciVisualizzazioneDettaglio(index),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                onPressed: () => _gestisciModificaEsercizio(es),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.redAccent,
                ),
                onPressed: () => _confermaElimina(es),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
