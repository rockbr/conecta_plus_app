import 'dart:async';
import 'package:conecta_plus_app/mensagem.dart';
import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  final String tipo;

  const Header({super.key, required this.tipo});

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Widget _mensagem = const Text('');
  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      setState(() {
        if (widget.tipo == "title") {
          _mensagem = Mensagem.cumprimento();
        } else if (widget.tipo == "subtitle") {
          _mensagem = Mensagem.mensagemHeader();
        } else if (widget.tipo == "leading") {
          _mensagem = const Text('');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //return Text(_mensagem, style: TextStyle(color: Colors.red));

    if (widget.tipo == "leading") {
      return Mensagem.cumprimentoIcones();
    } else if (widget.tipo == "title") {
      return _mensagem;
    } else if (widget.tipo == "subtitle") {
      return _mensagem;
    } else {
      return const Text('');
    }
  }
}