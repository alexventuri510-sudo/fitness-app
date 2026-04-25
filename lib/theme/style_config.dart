import 'package:flutter/material.dart';

class StyleConfig {
  // Colori
  static const Color colorErrore = Colors.red;
  static const Color colorSuccesso = Colors.green;

  // Dimensioni
  static const double textSizeTitolo = 30.0;

  // Decorazione Campo Testo (Replica la tua funzione campo_testo)
  static InputDecoration campoTestoDecoration({
    required String label,
    bool isPassword = false,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      suffixIcon: suffixIcon,
    );
  }
}
