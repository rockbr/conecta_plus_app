import 'package:flutter/material.dart';

class Mensagem {

  static String cumprimentoHeader(int hora) {
    if (hora >= 0 && hora <= 11) {
      return "BOM DIA";
    } else if (hora >= 12 && hora <= 17) {
      return "BOA TARDE";
    } else {
      return "BOA NOITE";
    }
  }
  static Widget cumprimento() {
    DateTime now = DateTime.now();
    int hora = int.parse(now.hour.toString().padLeft(2, '0'));

      return Text(cumprimentoHeader(hora));
  }

  static Widget mensagemHeader() {
    String mensagem = '';
    return Text(mensagem);
  }

  static Icon iconePadrao() {
    DateTime now = DateTime.now();
    int hora = int.parse(now.hour.toString().padLeft(2, '0'));


      if (hora >= 0 && hora <= 11) {
        return const Icon(
          Icons.wb_sunny,
          color: Colors.amberAccent,
          size: 32.0,
          semanticLabel: 'BOM DIA',
        );
      } else if (hora >= 12 && hora <= 17) {
        return const Icon(
          Icons.wb_sunny,
          color: Colors.amber,
          size: 32.0,
          semanticLabel: 'BOA TARDE',
        );
      } else {
        return const Icon(
          Icons.lens,
          color: Colors.black45,
          size: 32.0,
          semanticLabel: 'BOA NOITE',
        );
      }

  }

  static Icon cumprimentoIcones() {

      return iconePadrao();
  }
}