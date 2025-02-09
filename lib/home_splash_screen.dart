
import 'package:conecta_plus_app/database/database_helper.dart';
import 'package:conecta_plus_app/login.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:conecta_plus_app/widget/principal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class HomeSplashScreen extends StatefulWidget {
  const HomeSplashScreen({super.key});

  @override
  _HomeSplashScreenState createState() => _HomeSplashScreenState();
}

class _HomeSplashScreenState extends State<HomeSplashScreen> {
  @override
  void initState() {
    try {
      super.initState();
      _load();
    } on Exception catch (e) {
      TratarErro.gravarLog('home_splash_screen.dart: $e', 'ERRO');
      _abrirApp(context);
    }
  }

  Future<bool> _recriarTabela() async {
    try {

      await DatabaseHelper().recriarTabelas();

      return true;

    } on Exception catch (e) {
      TratarErro.gravarLog('home_splash_screen.dart: $e', 'ERRO');
      return false;
    }
  }

  void _load() async {
    try {

      await _recriarTabela();

      await Sessao.carregaDadosSessao();

      await _abrirApp(context);

    } on Exception catch (e) {
      TratarErro.gravarLog('home_splash_screen.dart: $e', 'ERRO');
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Container();
    } on Exception catch (e) {
      TratarErro.gravarLog('home_splash_screen.dart: $e', 'ERRO');
      _abrirApp(context);
      rethrow;
    }
  }
}

Future<bool> _abrirApp(context) async {

  String versao = Util.version();
  int versaoBanco = Util.databaseVersion;

  TratarErro.gravarLog(' --- Iniciado APP | Versao $versao | Banco $versaoBanco ---- ', 'INFO');

  await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
        (Sessao.idUsuario > 0
            ? const Principal()
            : const Login())
    ));

  return true;
}