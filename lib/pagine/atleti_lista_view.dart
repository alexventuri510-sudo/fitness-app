import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AtletiListaView extends StatefulWidget {
  final VoidCallback vaiIndietro;
  final Function(String id, String nome) vaiAPianiAtleta;

  const AtletiListaView({
    super.key,
    required this.vaiIndietro,
    required this.vaiAPianiAtleta,
  });

  @override
  State<AtletiListaView> createState() => _AtletiListaViewState();
}

class _AtletiListaViewState extends State<AtletiListaView> {
  late Future<List<dynamic>> _futureAtleti;

  @override
  void initState() {
    super.initState();
    _caricaAtleti();
  }

  // Metodo per ricaricare i dati
  void _caricaAtleti() {
    setState(() {
      _futureAtleti = DatabaseService.getAtletiCollegati();
    });
  }

  void _confermaScollegamento(String atletaId, String nomeAtleta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Scollega Atleta"),
        content: Text(
          "Sei sicuro di voler scollegare $nomeAtleta? Non vedrai più i suoi piani, ma i dati non verranno eliminati.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Chiude il dialog immediatamente

              // Esegue lo scollegamento sul DB
              final success = await DatabaseService.scollegaAtleta(atletaId);

              if (success) {
                // Piccolo trucco: aspettiamo un istante prima di ricaricare
                // per essere sicuri che Supabase abbia processato l'update
                await Future.delayed(const Duration(milliseconds: 300));
                _caricaAtleti();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Atleta $nomeAtleta scollegato"),
                      backgroundColor: Colors.black87,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Errore: controlla la connessione o i permessi DB",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              "Sì, scollega",
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.vaiIndietro,
        ),
        title: const Text(
          "I MIEI ATLETI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<List<dynamic>>(
          future: _futureAtleti,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text("Errore: ${snapshot.error}"));
            }

            final atleti = snapshot.data ?? [];

            if (atleti.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group_off, size: 60, color: Colors.grey),
                    const SizedBox(height: 15),
                    const Text(
                      "Nessun atleta collegato.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: _caricaAtleti,
                      child: const Text(
                        "AGGIORNA LISTA",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: Colors.black,
              onRefresh: () async {
                _caricaAtleti();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: atleti.length,
                itemBuilder: (context, index) {
                  final a = atleti[index];
                  final nome = a['first_name'] ?? 'Utente';
                  final cognome = a['last_name'] ?? '';
                  final nomeCompleto = "$nome $cognome";

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          nome.isNotEmpty ? nome[0].toUpperCase() : "?",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        nomeCompleto.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        "Codice: ${a['unique_code'] ?? '-'}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => widget.vaiAPianiAtleta(
                              a['id'].toString(),
                              nomeCompleto,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "GESTISCI",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.link_off,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            onPressed: () => _confermaScollegamento(
                              a['id'].toString(),
                              nomeCompleto,
                            ),
                            tooltip: "Scollega atleta",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
