import 'package:flutter/material.dart';

class PtHomeView extends StatelessWidget {
  final String nome;
  final VoidCallback vaiAListaAtleti;
  final VoidCallback vaiAAggiungiAtleta;
  final VoidCallback vaiAProfilo;

  const PtHomeView({
    super.key,
    required this.nome,
    required this.vaiAListaAtleti,
    required this.vaiAAggiungiAtleta,
    required this.vaiAProfilo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // Header con Avatar stile Atleta
              _buildHeader(),

              const SizedBox(height: 40),

              const Text(
                "GESTIONE TEAM",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: Colors.blueGrey,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 15),

              // Card: Visualizza Atleti
              _buildDashboardCard(
                titolo: "I tuoi Atleti",
                sottotitolo: "Gestisci schede e progressi",
                icona: Icons.groups_rounded,
                colore: Colors.black,
                azione: vaiAListaAtleti,
              ),

              const SizedBox(height: 15),

              // Card: Aggiungi Atleta
              _buildDashboardCard(
                titolo: "Nuovo Atleta",
                sottotitolo: "Crea account e assegna piani",
                icona: Icons.person_add_alt_1_rounded,
                colore: Colors.grey.shade800,
                azione: vaiAAggiungiAtleta,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bentornato,",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                "Coach $nome",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: vaiAProfilo,
          child: Hero(
            tag: 'profile_avatar',
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              child: const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required String titolo,
    required String sottotitolo,
    required IconData icona,
    required Color colore,
    required VoidCallback azione,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: azione,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colore,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icona, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titolo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        sottotitolo,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
