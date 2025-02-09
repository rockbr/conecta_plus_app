import 'dart:io';

import 'package:conecta_plus_app/model/aparelho.dart';
import 'package:conecta_plus_app/permissao.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Sobre extends StatefulWidget {
  const Sobre({super.key});

  @override
  _SobreState createState() => _SobreState();
}

class _SobreState extends State<Sobre> {
  Aparelho? aparelho;

  @override
  void initState() {
    try {
      super.initState();
      carregaDados();
    } on Exception catch (e) {
      TratarErro.gravarLog('sobre.dart: $e', 'ERRO');
      //Util.snackBar("Erro: " + e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sobre")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Card(
                      color: Colors.grey[100],
                      child: InkWell(
                        onTap: () {
                          _requestPermission();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  "Informações",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 20),
                                ),
                                const Divider(),
                                Text(
                                  "Armazenamento: ${aparelho?.armazenamento}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "Câmera: ${aparelho?.camera}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "Conectividade: ${aparelho?.conectividade}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "GPS: ${aparelho?.gps}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Visibility(
                                    visible: Platform.isIOS,
                                    child: Text(
                                      "APP Transparência: ${aparelho?.appTrackingTransparency}",
                                      style: const TextStyle(fontSize: 14),
                                    )),
                                Text(
                                  "Plataforma: ${aparelho?.plataforma}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "Internet: ${aparelho?.internet}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "Site: ${aparelho?.site}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "Versão APP: ${aparelho?.versaoApp}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "Versão Database: ${aparelho?.versaoDatabase}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Card(
                      color: Colors.grey[100],
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                "Último Envio",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 20),
                              ),
                              const Divider(),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Card(
                      color: Colors.grey[100],
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Fetx",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 20),
                              ),
                              Divider(),
                              Text(
                                "https://www.fetx.com.br",
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                "https://www.fetx.com.br/suporte",
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                "suporte.fetx@gmail.com",
                                style: TextStyle(fontSize: 14),
                              ),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      //drawer: AppDrawer(),
    );
  }

  Future<void> _requestPermission() async {
    openAppSettings();
  }

  Future<void> carregaDados() async {
    try {
      Permissao permissao = Permissao();
      var aparelhoAsync = await permissao.verificaPermissoes();

      setState(() {
        aparelho = aparelhoAsync;
      });
    } on Exception catch (e) {
      TratarErro.gravarLog('sobre.dart: $e', 'ERRO');
      //Util.snackBar("Erro: " + e.toString());
    }
  }
}