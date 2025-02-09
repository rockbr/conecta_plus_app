import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

class Sessao {

  static List<CameraDescription> cameras = [];

  static String latitude = '';
  static String longitude = '';
  static String thoroughfare = '';
  static String subThoroughfare = '';
  static String subLocality = '';
  static String postalCode = '';
  static String subAdministrativeArea = '';
  static int idEmpresa = 0;
  static int idUsuario = 0;
  static String loginUsuario = '';
  static String nomeUsuario = '';
  static String telefone = '';
  static int bloqueado = 0;
  static String dataNascimento = '';

  static Future<bool> carregaDadosSessao() async {

    return false;
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

}