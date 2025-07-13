import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:conecta_plus_app/api/envia_dados.dart';
import 'package:conecta_plus_app/api/webService.dart';
import 'package:conecta_plus_app/gps.dart';
import 'package:conecta_plus_app/header.dart';
import 'package:conecta_plus_app/rodape.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:conecta_plus_app/widget/app_drawer.dart';
import 'package:conecta_plus_app/widget/camera.dart';
import 'package:conecta_plus_app/widget/relogio_ponto.dart';
import 'package:flutter/material.dart';


class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  final String title = Util.appNome;
  String _authStatus = 'Unknown';
  final TextEditingController _nomeController = TextEditingController();

  @override
  void initState() {

    _nomeController.value = TextEditingValue(
      text: Sessao.nomeCliente,
      selection: TextSelection.collapsed(offset: Sessao.nomeCliente.length),
    );

    if (Platform.isIOS) {
      appTrackingTransparencyIos();
    }
    try {
      Gps.carregaEndereco();

      Sessao.setupCameras();

      EnviaDados.enviarTodosDadosAsync();
      WebService().apiGetIntegraUsuarios(Sessao.idUsuario, Sessao.idPessoaConecta);
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
                      _nomeCliente(),
                      _cardHeader(1, "Ponto", Icons.access_time),
                      _ponto(),
                      _cardHeader(1, "Foto", Icons.photo_camera),
                      _foto(),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Container(
                margin: const EdgeInsets.only(top: 3.0),
                color: Colors.amberAccent,
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

  Widget _cardHeader(int mostra, String nome, IconData icone) {
    return Visibility(
      visible: (mostra == 1 ? true : false),
      child: Padding(
        padding: const EdgeInsets.only(top: 0.5),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Card(
                color: Colors.amber,
                elevation: 2.0,
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    icone,
                    color: Colors.white,
                    size: 24.0,
                    semanticLabel: nome,
                  ),
                  title: Text(nome,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white)),
                  onTap: () {
                    Util.printDebug("Tap $nome");
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nomeCliente() {
    return Visibility(
      visible: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 0.5, bottom: 0.5),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Card(
                color: Colors.amber,
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Nome do Cliente',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Campo de texto com maiúsculas automáticas
                      TextField(
                        controller: _nomeController,
                        style: const TextStyle(fontSize: 12),
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Digite o nome do cliente',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          // Força tudo em maiúsculo
                          final upper = value.toUpperCase();
                          if (value != upper) {
                            _nomeController.value = _nomeController.value.copyWith(
                              text: upper,
                              selection: TextSelection.collapsed(offset: upper.length),
                            );
                          }

                          // Salva na sessão
                          if (upper.trim().isNotEmpty) {
                            Sessao.nomeCliente = upper.trim();
                            Util.printDebug("Cliente: ${Sessao.nomeCliente}");
                          }
                        },
                      ),

                      const SizedBox(height: 4),

                      // Ícone de confirmação de ponto
                      if (Sessao.pontoCheck == 1)
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.check_circle, color: Colors.red, size: 16),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ponto() {
    return Visibility(
      visible: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 0.5, bottom: 0.5),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Card(
                color: Colors.white,
                elevation: 2.0,
                child: ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.access_time,
                    color: Colors.deepOrange,
                    size: 24.0,
                    semanticLabel: 'Ponto',
                  ),
                  title: const Text(
                    'Ponto',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  trailing: (Sessao.pontoCheck == 1
                      ? const Icon(Icons.check_circle, color: Colors.red, size: 16.0)
                      : null),
                  subtitle: const Text("", style: TextStyle(fontSize: 11)),
                  onTap: () {
                    if (Sessao.nomeCliente.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, preencha o nome do cliente.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RelogioPonto(),
                      ),
                    );

                    Util.printDebug("Tap Ponto - Cliente: ${_nomeController.text}");
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foto() {
    return Visibility(
      visible: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 0.5, bottom: 0.5),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Card(
                color: Colors.white,
                elevation: 2.0,
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.photo_camera,
                    color: Colors.deepOrange
                        ,
                    size: 24.0,
                    semanticLabel: 'Fotos',
                  ),
                  title: const Text('Fotos',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  trailing: (Sessao.fotoCheck == 1
                      ? const Icon(Icons.check_circle, color: Colors.red, size: 16.0)
                      : null),
                  subtitle: Text("", style: const TextStyle(fontSize: 11)),
                  onTap: () {
                    if (Sessao.nomeCliente.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, preencha o nome do cliente.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Camera()
                        ),
                      );

                    Util.printDebug("Tap Camera");
                  },
                ),
              ),
            ),
          ],
        ),
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