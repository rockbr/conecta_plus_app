import 'dart:io';
import 'package:conecta_plus_app/database/usuarios_helper.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:conecta_plus_app/widget/principal.dart';
import 'package:conecta_plus_app/widget/sobre.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppDrawer extends StatefulWidget {
  final String tipo;

  const AppDrawer({super.key, required this.tipo});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  final usuariosHelper = UsuariosHelper();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            _createHeader(),
            Visibility(
              visible: (widget.tipo == 'P'),
              child: _createDrawerItem(
                  icon: Icons.home,
                  text: 'Principal',
                  isIOs: true,
                  onTap: () {
                    TratarErro.gravarLog('app_drawer.dart - Principal', 'INFO');
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Principal()),
                    );
                  }),
            ),
            _createDrawerItem(
              icon: Icons.system_update,
              text: 'Verificar Atualização',
              isIOs: false,
              onTap: () async {
                TratarErro.gravarLog('app_drawer.dart - Verificar Atualização', 'INFO');
                if (await canLaunchUrlString(Util.urlPlayStore)) {
                  await launchUrlString(Util.urlPlayStore);
                } else {
                  throw 'Erro ao abrir URL $Util.urlPlayStore';
                }
              },
            ),
            _createDrawerItem(
              icon: Icons.abc,
              text: 'Sobre',
              isIOs: true,
              onTap: () {
                TratarErro.gravarLog('app_drawer.dart - Sobre', 'INFO');
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Sobre()),
                );
              },
            ),
            _createDrawerItem(
              icon: Icons.local_police,
              text: 'Política de Privacidade',
              isIOs: true,
              onTap: () async {
                TratarErro.gravarLog('app_drawer.dart - Política de Privacidade', 'INFO');
                final Uri url = Uri.parse(Util.appUrlPolitica);
                if (!await launchUrl(url)) {
                  throw Exception('Erro ao abrir URL $url');
                }
              },
            ),
            const Divider(),
            Visibility(
                visible: (widget.tipo != 'L'),
                child: _createDrawerItem(
                  icon: Icons.logout,
                  text: 'Logout',
                  isIOs: true,
                  onTap: () async {
                    TratarErro.gravarLog('app_drawer.dart - Logout', 'INFO');
                    await usuariosHelper.deleteUsuarioTodos();
                    exit(0);
                  },
                )),
            _createDrawerItem(
              icon: Icons.close,
              text: 'Fechar',
              isIOs: true,
              onTap: () async {
                TratarErro.gravarLog('app_drawer.dart - Logout', 'INFO');
                exit(0);
              },
            ),
          ]),
    );
  }

  Widget _createHeader() {
    return const DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill, image: AssetImage('assets/header.png'))),
        child: Stack(children: <Widget>[
          Positioned(
              bottom: 12.0,
              left: 16.0,
              child: Text(Util.appNome,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500))),
        ]));
  }

  Widget _createDrawerItem(
      {required IconData icon,
        required String text,
        required bool isIOs,
        required GestureTapCallback onTap}) {
    return Visibility(
        visible: (isIOs
            ? true
            : Platform.isAndroid
            ? true
            : false),
        child: ListTile(
          title: Row(
            children: <Widget>[
              Icon(icon),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(text),
              )
            ],
          ),
          onTap: onTap,
        ));
  }
}