import 'package:conecta_plus_app/api/webService.dart';
import 'package:conecta_plus_app/database/usuarios_helper.dart';
import 'package:conecta_plus_app/model/usuario.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

class Sessao {

  static List<CameraDescription> cameras = [];

  static String ultimoEnvioFoto = '';
  static String ultimoEnvioPonto = '';
  static String latitude = '';
  static String longitude = '';
  static String thoroughfare = '';
  static String subThoroughfare = '';
  static String subLocality = '';
  static String postalCode = '';
  static String subAdministrativeArea = '';
  static int idEmpresa = 0;
  static int idPessoa = 0;
  static int idPessoaConecta = 0;
  static int idUsuario = 0;
  static String loginUsuario = '';
  static String nomeUsuario = '';
  static String telefone = '';
  static int bloqueado = 0;
  static String dataNascimento = '';
  static int pontoCheck = 0;
  static int fotoCheck = 0;
  static int envioPendentePonto = 0;
  static int envioPendenteFoto = 0;

  static Future<bool> carregaDadosSessao() async {
    try {
      Util.printDebug('<-- _carregaDados');

      await Util.packageInfo();
      await _carregaDadosSessao();

      Util.printDebug('_carregaDados -- >');

      return true;
    } on Exception catch (e) {
      TratarErro.gravarLog('sessao.dart: $e', 'ERRO');
      rethrow;
    }
  }

  static setupCameras() async {
    Util.printDebug('Sessao: setupCameras');
    // Fetch the available cameras before initializing the app.
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
      Util.printDebug(e.description.toString());
      TratarErro.gravarLog('util.dart: $e', 'ERRO');
    }
  }
  static Future<bool> _carregaDadosSessao() async {

    try {

      TratarErro.gravarLog('sessao.dart - _carregaDadosSessao()', 'INFO');

      Util.printDebug('_carregaDadosSessao');

      final usuariosHelper = UsuariosHelper();

      Usuario? sessaoFuture;

      try {
        sessaoFuture = await usuariosHelper.getUsuario();
      } on Exception {
        sessaoFuture = await usuariosHelper.getUsuario();
      }

      try {

        if (sessaoFuture != null) {

          Sessao.idUsuario = sessaoFuture.id == null ? 0 : sessaoFuture.id!;
          Sessao.nomeUsuario = sessaoFuture.nome == null ? '' : sessaoFuture.nome!;
          Sessao.loginUsuario = sessaoFuture.login == null ? '' : sessaoFuture.login!;
          Sessao.idEmpresa = sessaoFuture.idEmpresa == null ? 0 : sessaoFuture.idEmpresa!;
          Sessao.idPessoa = sessaoFuture.idPessoa == null ? 0 : sessaoFuture.idPessoa!;
          Sessao.idPessoaConecta = sessaoFuture.idPessoaConecta == null ? 0 : sessaoFuture.idPessoaConecta!;

          //#region API

          try {
            WebService().apiGetLoginPorId(Sessao.loginUsuario, Sessao.idUsuario);
            WebService().apiGetIntegraUsuarios(Sessao.idUsuario, Sessao.idPessoaConecta);

          } on Exception catch (e) {
            TratarErro.gravarLog('sessao.dart: $e', 'ERRO');
          }

          //#endregion
        }

      } on Exception catch (e){
        TratarErro.gravarLog('sessao.dart: $e', 'ERRO');
      }

      return true;
    } on Exception catch (e) {
      TratarErro.gravarLog('sessao.dart: $e', 'ERRO');
      return false;
    }
  }
}