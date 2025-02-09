import 'package:conecta_plus_app/api/webService.dart';
import 'package:conecta_plus_app/database/usuarios_helper.dart';
import 'package:conecta_plus_app/model/usuario.dart';
import 'package:conecta_plus_app/rodape.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/size_config.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:conecta_plus_app/widget/app_drawer.dart';
import 'package:conecta_plus_app/widget/principal.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final String title = Util.appNome;

  final usuariosHelper = UsuariosHelper();

  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _passwordVisible = false;
  String erroLogin = '';

  int count = 0;
  bool validandoDados = false;
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Column(children: [
          Expanded(
              flex: 2,
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.00),
                      child: Center(
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Image.asset(
                                  Util.appImagemLogoTitulo,
                                ),
                                TextFormField(
                                  //inputFormatters: [
                                  //LowerCaseTextFormatter(),
                                  //],
                                  //textCapitalization: TextCapitalization.characters,
                                  controller: _usuarioController,
                                  decoration: const InputDecoration(
                                    labelText: "Usuário",
                                    fillColor: Colors.white,
                                    //fillColor: Colors.green
                                  ),
                                  validator: (val) {
                                    if (val?.length == 0) {
                                      return "Digite seu ID";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                TextFormField(
                                  controller: _senhaController,
                                  decoration: InputDecoration(
                                    labelText: "Senha",
                                    fillColor: Colors.white,
                                    // Adicione o ícone de botão para mostrar/ocultar a senha aqui
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val?.isEmpty ?? true) {
                                      return "Digite sua senha";
                                    } else {
                                      return null;
                                    }
                                  },
                                  obscureText:
                                  !_passwordVisible, // Mostrar/ocultar a senha com base no estado
                                ),
                                const Padding(padding: EdgeInsets.only(top: 10.0)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _login,
                                        child: Text(
                                          validandoDados
                                              ? 'Validando ...'
                                              : 'Login',
                                          textScaleFactor: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: SizedBox(
                                        child: Text(
                                          erroLogin,
                                          style: TextStyle(
                                              fontSize: SizeConfig.of(context)
                                                  .dynamicScaleSize(
                                                  size: 15,
                                                  scaleFactorTablet: 1,
                                                  scaleFactorMini: 0),
                                              color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ]))))),
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
        ]),
        drawer: AppDrawer(tipo: _abrirTela()),
      ),
    );
  }

  Future<void> _login() async {
    try {
      Util.printDebug('_login');

      TratarErro.gravarLog('login.dart - _login()', 'INFO');

      setState(() {
        erroLogin = '';
        validandoDados = true;
      });

      if (Sessao.idUsuario > 0) {
        if (await _abrirApp(context) == false) {
          setState(() {
            erroLogin = '\n\rERRO LOGIN';
            validandoDados = false;
          });
        }
      } else if (!await Util.validarInternet()) {
        TratarErro.gravarLog(
            'login.dart: Para logar você deve estar conectado na internet',
            'INFO');
        Util.showAlertDialog(context, 'Atenção',
            'Para logar você deve estar conectado na internet');
      } else if (_usuarioController.text.isEmpty) {
        Util.showAlertDialog(context, 'Atenção', 'Digite seu usuário');
      } else if (_senhaController.text.isEmpty) {
        Util.showAlertDialog(context, 'Atenção', 'Digite sua senha');
      } else if (_usuarioController.text.isNotEmpty &&
          _senhaController.text.isNotEmpty) {
        if (await WebService()
            .apiGetLogin(_usuarioController.text, _senhaController.text) ==
            false) {
          TratarErro.gravarLog('login.dart: Usuário ou senha inválida', 'INFO');
          Util.showAlertDialog(context, 'Atenção', 'Usuário ou senha inválida');
        } else {
          //Grava Sessão
          if (Sessao.idUsuario > 0) {
            TratarErro.gravarLog(
                'login.dart: ${Sessao.idUsuario} - ${Sessao.nomeUsuario} - ${Sessao.loginUsuario}',
                'INFO');

            Usuario usuario = Usuario(
              id: Sessao.idUsuario,
              nome: Sessao.nomeUsuario,
              login: Sessao.loginUsuario,
              bloqueado: Sessao.bloqueado,
              idEmpresa: Sessao.idEmpresa,
              dataNascimento: Sessao.dataNascimento,
            );

            await usuariosHelper.upsertUsuario(usuario);

            if (await _abrirApp(context) == false) {
              setState(() {
                erroLogin = '\n\rERRO LOGIN';
                validandoDados = false;
              });
            }

          } else {
            TratarErro.gravarLog('login.dart: ERRO LOGIN', 'ERRO');

            setState(() {
              erroLogin = '\n\rERRO LOGIN';
              validandoDados = false;
            });
          }
        }
      }
    } on Exception catch (e) {
      setState(() {
        erroLogin = '\n\rERRO LOGIN: $e';
        validandoDados = false;
      });
      TratarErro.gravarLog('login.dart: $e', 'ERRO');
    }
  }

  String _abrirTela() {
    return 'L';
  }

  Future<bool> _abrirApp(context) async {
    TratarErro.gravarLog('login.dart: _abrirApp()', 'INFO');

    if (Sessao.idUsuario > 0) {
      TratarErro.gravarLog('login.dart: Principal()', 'INFO');

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Principal()));

      return true;
    }

    return false;
  }
}
