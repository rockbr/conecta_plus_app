import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:conecta_plus_app/api/envia_dados.dart';
import 'package:conecta_plus_app/gps.dart';
import 'package:conecta_plus_app/header.dart';
import 'package:conecta_plus_app/rodape.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:conecta_plus_app/widget/app_drawer.dart';
import 'package:flutter/material.dart';


class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  final String title = Util.appNome;
  String _authStatus = 'Unknown';

  @override
  void initState() {
    //VARIAVEIS PARA TESTE
    //Sessao.fotoCheck = 1;

    //app_tracking_transparency
    if (Platform.isIOS) {
      appTrackingTransparencyIos();
    }
    try {
      Gps.carregaEndereco();

      Sessao.setupCameras();

      EnviaDados.enviarTodosDadosAsync();

    } on Exception catch (e) {
      TratarErro.gravarLog('principal.dart: $e', 'ERRO');
    }

    try {
      BackButtonInterceptor.add(myInterceptor);
      super.initState();
    } on Exception catch (e) {
      TratarErro.gravarLog('principal.dart: $e', 'ERRO');
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //Utilizado para bloquear o Botão de voltar na tela inicial
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Card(
                        color: Colors.white,
                        elevation: 2.0,
                        child: ListTile(
                          dense: true,
                          leading: Header(tipo: "leading"),
                          title: Header(tipo: "title"),
                          subtitle: Header(tipo: "subtitle"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Container(
                margin: const EdgeInsets.only(top: 3.0),
                color: Colors.blueGrey,
                child: const IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[Rodape()],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: const AppDrawer(tipo: 'P'),
      ),
    );
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Util.printDebug("Back Button Principal!");
    //Util.enviaDadosApi();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Principal()));
    return true;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> appTrackingTransparencyIos() async {
    final TrackingStatus status =
    await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Show a custom explainer dialog before the system dialog
      await showCustomTrackingDialog(context);
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      final TrackingStatus status =
      await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    Util.printDebug("UUID: $uuid");
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Trade Check'),
          content: const Text(
            'Nós nos preocupamos com sua privacidade e segurança de dados. '
                'Podemos continuar usando seus dados para registrar o seu ponto?\n\nVocê pode alterar sua escolha a qualquer momento nas configurações do aplicativo. ',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
}