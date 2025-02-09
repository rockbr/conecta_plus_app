import 'dart:io';

import 'package:conecta_plus_app/api/envia_dados.dart';
import 'package:conecta_plus_app/model/aparelho.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissao {
  Future<Aparelho?> verificaPermissoes() async {
    try {
      Aparelho? aparelho;
      String vGps = '';
      String vCamera = '';
      String vStorage = '';
      String vAppTrackingTransparency = '';
      String vConectividade = '';
      String vSiteGoogle = '';
      String vSite = '';
      String vPlataforma = '';
      String vInformacoes = '';
      String? vId = Sessao.idUsuario.toString();

      if (Platform.isAndroid) {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        var release = androidInfo.version.release;
        var sdkInt = androidInfo.version.sdkInt;
        var manufacturer = androidInfo.manufacturer;
        var model = androidInfo.model;

        vId = androidInfo.id;
        vPlataforma = 'Android $release (SDK $sdkInt), $manufacturer $model';
        // Android 9 (SDK 28), Xiaomi Redmi Note 7
      } else if (Platform.isIOS) {
        var iosInfo = await DeviceInfoPlugin().iosInfo;
        var systemName = iosInfo.systemName;
        var version = iosInfo.systemVersion;
        var name = iosInfo.name;
        var model = iosInfo.model;

        vId = iosInfo.identifierForVendor;
        vPlataforma = '$systemName $version, $name $model';
        // iOS 13.1, iPhone 11 Pro Max iPhone

        var statusTrackingTransparency = Permission.appTrackingTransparency;
        if (await statusTrackingTransparency.isRestricted) {
          vAppTrackingTransparency = "Restrito";
        } else if (await statusTrackingTransparency.isPermanentlyDenied) {
          vAppTrackingTransparency = "Permanentemente Negado";
        } else if (await statusTrackingTransparency.isGranted) {
          vAppTrackingTransparency = "OK";
        } else if (await statusTrackingTransparency.isDenied) {
          vAppTrackingTransparency = "Negado";
        }
      } else if (Platform.isFuchsia) {
        vPlataforma = 'Fuchsia';
      } else if (Platform.isLinux) {
        vPlataforma = 'Linux';
      } else if (Platform.isMacOS) {
        vPlataforma = 'Mac OS';
      } else if (Platform.isWindows) {
        vPlataforma = 'Windows';
      }

      var statusStorage = Permission.storage;
      if (await statusStorage.isDenied) {
        vStorage = "Negado";
      } else if (await statusStorage.isGranted) {
        vStorage = "OK";
      } else if (await statusStorage.isLimited) {
        vStorage = "Limitado";
      } else if (await statusStorage.isPermanentlyDenied) {
        vStorage = "Permanentemente Negado";
      } else if (await statusStorage.isRestricted) {
        vStorage = "Restrito";
      }

      var status = await Permission.camera.status;
      if (status.isDenied) {
        vCamera = "Negado";
      } else {
        vCamera = "OK";
      }

      bool gps = await Geolocator.isLocationServiceEnabled();

      if (gps) {
        vGps = 'Ligado';
      } else {
        vGps = 'Desligado';
      }

      LocationPermission? gpsPermissao = await Geolocator.checkPermission();

      if (gpsPermissao == LocationPermission.deniedForever) {
        vGps += ', Negado para sempre';
      } else if (gpsPermissao == LocationPermission.denied) {
        vGps += ', Negado';
      } else if (gpsPermissao == LocationPermission.unableToDetermine) {
        vGps += ', Incapaz de Determinar';
      } else if (gpsPermissao == LocationPermission.always) {
        vGps += ', Sempre';
      } else if (gpsPermissao == LocationPermission.whileInUse) {
        vGps += ', Enquanto Estiver em Uso';
      } else {
        vGps += ', Sem Permissão';
      }
      List<ConnectivityResult> conectividade =
      await Connectivity().checkConnectivity();

      if (conectividade.contains(ConnectivityResult.none)) {
        vConectividade = 'Sem conectivadade';
      } else if (conectividade.contains(ConnectivityResult.wifi)) {
        vConectividade = 'Wi-Fi';
      } else if (conectividade.contains(ConnectivityResult.mobile)) {
        vConectividade = 'Dados móveis';
      } else if (conectividade.contains(ConnectivityResult.ethernet)) {
        vConectividade = 'Ethernet';
      } else {
        vConectividade = 'Sem conectivadade';
      }

      List<InternetAddress>? siteGoogle =
      await InternetAddress.lookup('google.com')
          .timeout(Util.connectivityTimeout);

      if (siteGoogle.isNotEmpty && siteGoogle[0].rawAddress.isNotEmpty) {
        vSiteGoogle = 'OK';
      } else {
        vSiteGoogle = 'Sem Acesso';
      }

      List<InternetAddress>? siteFetx =
      await InternetAddress.lookup('fetx.com.br')
          .timeout(Util.connectivityTimeout);

      if (siteFetx.isNotEmpty && siteFetx[0].rawAddress.isNotEmpty) {
        vSite = 'OK';
      } else {
        vSite = 'Sem Acesso';
      }

      //vInformacoes  = await getSimCard();
      //Sessao.telefone = await getMobileNumber();

      //var statusTelefone = await Permission.phone.status;

      //if (!statusTelefone.isGranted) {
      //statusTelefone = await Permission.phone.request();
      //}

      aparelho = Aparelho.notId(
          idUsuario: Sessao.idUsuario,
          dataHora: DateTime.now().toString(),
          serialAparelho: vId!,
          armazenamento: vStorage,
          camera: vCamera,
          conectividade: vConectividade,
          gps: vGps,
          plataforma: vPlataforma,
          appTrackingTransparency: vAppTrackingTransparency,
          internet: vSiteGoogle,
          site: vSite,
          versaoApp: Util.version(),
          versaoDatabase: Util.databaseVersion,
          informacoes: vInformacoes,
          imei: '',
          telefone: Sessao.telefone,
          enviado: 0);

      if (Sessao.idUsuario > 0) {
        EnviaDados.enviaEquipamentosApi(aparelho);
      }

      return aparelho;
    } on Exception catch (e) {
      TratarErro.gravarLog('permissao.dart: $e', 'ERRO');
      return null;
    }
  }

/*
  Future<String> getMobileNumber() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return 'Sem Permissão';
    }
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      return (await MobileNumber.mobileNumber)!;
    } on PlatformException catch (e) {
      TratarErro.gravarLog('permissao.dart: $e', 'ERRO');
      return 'getMobileNumber(): $e';
    }
  }

  Future<String> getSimCard() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return 'Sem Permissão';
    }
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      List<SimCard> simCards = (await MobileNumber.getSimCards)!;
      // Convert the list of SimCard objects to a single formatted string
      String simCardsInfo = simCards.map((SimCard sim) =>
      'Telefone: (${sim.countryPhonePrefix}) - ${sim.number}\n'
          'Nome da Operadora: ${sim.carrierName}\n'
          'Nome Exibido: ${sim.displayName}\n'
          'Índice do Slot: ${sim.slotIndex}\n\n'
      ).join();
      return simCardsInfo;
    } on PlatformException catch (e) {
      TratarErro.gravarLog('permissao.dart: $e', 'ERRO');
      return 'getSimCard(): $e';
    }
  }*/
}