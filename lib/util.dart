import 'dart:convert';
import 'dart:io';

import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Util {

  static String _versionAndroid = '1.0.1';
  static String _versionIos = '1.0.1';
  static String site = "gbasoft.com.br";
  static const String urlPlayStore = 'https://play.google.com/store/apps/details?id=br.com.fetx.tradecheckapp';
  static const String urlAplleStore = 'https://apps.apple.com/us/app/trade-check/id1555134626';
  static const String appUrlPolitica = "https://www.gbasoft.com.br/politica-privacidade";
  static const String appUserWebservice = "api_gbasoft";
  static const String appSenhaWebservice = "qQw<Q!CBTDD5\$T*4";
  static const String appImagemLogo = "assets/logo.png";
  static const String appImagemLogoTitulo = "assets/logo_titulo.png";
  static const String appNome = "Conecta Plus";
  static final String basicAuth = 'Basic ${base64Encode(utf8.encode("${Util.appUserWebservice}:${Util.appSenhaWebservice}"))}';
  static const String appUrlBaseWebservice = "https://www.gbasoft.com.br";
  static String appName = '';
  static String packageName = '';
  static String buildNumber = '';
  static String databaseName = "_banco.db";
  static int databaseVersion = 20;
  static String dataHoraLog = convertDataHoraLogFromString(DateTime.now());
  static Duration connectivityTimeout = const Duration(seconds: 7);

  static void snackBar(String mensagem, {BuildContext? context}) {
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String convertDateFromString(String strDate) {
    DateTime todayDate = DateTime.parse(strDate);

    return formatDate(
        todayDate, [dd, '/', mm, '/', yyyy, ' ', '', '', '', '', '', ' ', '']);
  }

  static String convertData(DateTime date) {
    return formatDate(
        date, [yyyy, '-', mm, '-', dd, '', '', '', '', '', '', '', '']);
  }

  static String convertDataHoraLogFromString(DateTime date) {
    return formatDate(date, [yyyy, mm, dd, HH, nn, ss]);
  }

  static String timeToStringCompleto(DateTime now) {
    String timeString =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    return timeString;
  }

  static String version() {
    if (Platform.isIOS) {
      return _versionIos;
    } else {
      return _versionAndroid;
    }
  }

  static Future<bool> packageInfo() async {
    try {
      PackageInfo packageInf = await PackageInfo.fromPlatform();

      appName = packageInf.appName;
      packageName = packageInf.packageName;
      _versionAndroid = packageInf.version;
      _versionIos = packageInf.version;
      buildNumber = packageInf.buildNumber;

      return true;
    } on Exception catch (e) {
      TratarErro.gravarLog('util.dart: $e', 'ERRO');
      return false;
    }
  }

  static void printDebug(String debug) {
    if (kDebugMode) {
      print(debug);
    }
  }

  static void circularProgressIndicator(BuildContext context, String title) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(margin: const EdgeInsets.only(left: 5), child: Text(title)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static int intNull(dynamic input) {
    if (input == null) {
      return 0;
    } else if (input.toString() == '') {
      return 0;
    } else if (input == '') {
      return 0;
    } else {
      return int.parse(input.toString());
    }
  }

  static String stringNull(dynamic input) {
    if (input == null) {
      return '';
    } else if (input.isEmpty) {
      return '';
    } else {
      return input.toString();
    }
  }

  static Future<bool> validarInternet() async {
    try {
      final resultInternet = await InternetAddress.lookup(site)
          .timeout(Util.connectivityTimeout);

      if (resultInternet.isNotEmpty && resultInternet[0].rawAddress.isNotEmpty) {
        final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

        if (connectivityResult.contains(ConnectivityResult.none) &&
            !connectivityResult.contains(ConnectivityResult.mobile) &&
            !connectivityResult.contains(ConnectivityResult.wifi)) {
          printDebug('Conexão indisponível ou não é uma rede móvel ou Wi-Fi.');
          TratarErro.gravarLog('util.dart: Conexão indisponível ou inválida', 'INFO');
          return false;
        }

        if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
          printDebug('Validando conexão de internet...');

          final result = await InternetAddress.lookup(site)
              .timeout(Util.connectivityTimeout);

          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            printDebug('Conexão de internet está ativa.');

            return true;

          }
        }
      }
      return false;
    } on SocketException catch (e) {
      TratarErro.gravarLog('Falha na verificação da conexão com a internet: $e', 'ERRO');
      return false;
    }
  }

  static void showAlertDialog(
      BuildContext context, String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  static Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  static Future<bool> validarInternetWifi() async {
    try {

      final resultInternet = await InternetAddress.lookup(site)
          .timeout(Util.connectivityTimeout);

      if (resultInternet.isNotEmpty && resultInternet[0].rawAddress.isNotEmpty) {

        final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

        if (connectivityResult.contains(ConnectivityResult.none)
            && !connectivityResult.contains(ConnectivityResult.wifi)) {
          printDebug('Conexão não é uma rede Wi-Fi.');
          TratarErro.gravarLog('util.dart: Conexão não é uma rede Wi-Fi.', 'INFO');
          return false;
        }

        if (connectivityResult.contains(ConnectivityResult.wifi)) {
          printDebug('Validando conexão Wi-Fi...');

          final result = await InternetAddress.lookup(site)
              .timeout(Util.connectivityTimeout);

          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            printDebug('Conectado à internet.');

              return true;
          }
        }
      }
      return false;
    } on SocketException catch (e) {
      TratarErro.gravarLog('Falha na verificação da conexão com a internet: $e', 'ERRO');
      return false;
    }
  }
}