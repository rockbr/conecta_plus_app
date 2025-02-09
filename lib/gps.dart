import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Gps {

  static Future<void> carregaEndereco() async {
    try {
      Util.printDebug('carregaEndereco');

      Position? currentPosition = await _verificaLocal();

      if (currentPosition != null && await Util.validarInternetWifi()) {
        Util.printDebug('carregaEndereco - OK - Internet OK');

        List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition.latitude,
          currentPosition.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];

          Sessao.latitude = currentPosition.latitude.toString();
          Sessao.longitude = currentPosition.longitude.toString();
          Sessao.thoroughfare = place.thoroughfare ?? '';
          Sessao.subThoroughfare = place.subThoroughfare ?? '';
          Sessao.subLocality = place.subLocality ?? '';
          Sessao.postalCode = place.postalCode ?? '';
          Sessao.subAdministrativeArea = place.subAdministrativeArea ?? '';
        }
      }
    } on Exception catch (e) {
      TratarErro.gravarLog('gps.dart: $e', 'ERRO');
    }
  }


  static Future<Position?> _verificaLocal() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      Util.printDebug('Geolocator.isLocationServiceEnabled()');
      Util.printDebug(serviceEnabled.toString());
      Util.printDebug('------------------');

      if (serviceEnabled) {
        LocationPermission? permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          permission = await Geolocator.requestPermission();
        }

        permission = await Geolocator.checkPermission();

        Util.printDebug('Geolocator.checkPermission()');
        Util.printDebug(permission.toString());
        Util.printDebug('------------------');

        if (serviceEnabled && permission == LocationPermission.deniedForever) {
          Util.printDebug('LocationPermission.deniedForever');
        } else {
          if (serviceEnabled &&
              (permission != LocationPermission.denied &&
                  permission != LocationPermission.deniedForever)) {
            Util.printDebug('isGpsEnabled');

            return await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: Util.connectivityTimeout,
            );
          }
        }
      }
    } on Exception catch (e) {
      TratarErro.gravarLog('gps.dart: $e', 'ERRO');
    }
    return null; // Adicionado retorno nulo caso a execução não obtenha resultados
  }

}