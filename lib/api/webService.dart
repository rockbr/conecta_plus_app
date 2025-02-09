import 'dart:convert';
import 'dart:io';
import 'package:conecta_plus_app/model/usuario.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:conecta_plus_app/model/aparelho.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';

class WebService {

  Future<bool> apiGetLogin(String usuario, String senha,
      {bool validarInternet = true}) async {
    try {
      Util.printDebug('apiGetLoginV4');
      TratarErro.gravarLog('webservice.dart - apiGetLoginV4()', 'INFO');

      if (validarInternet == false || await Util.validarInternet()) {
        final uri = Uri.parse('${Util.appUrlBaseWebservice}/api/getLoginV4');

        Map<String, String> requestHeaders = {
          'Content-Type': 'application/x-www-form-urlencoded',
          //'Accept': 'application/json',
          'Authorization': Util.basicAuth
        };

        var bytes = utf8.encode(senha.trim());
        Digest md5Result = md5.convert(bytes);

        Map body = {
          'login': usuario.toLowerCase().trim(),
          'senha': md5Result.toString()
        };

        final encoding = Encoding.getByName('utf-8');

        Response response = await post(uri,
            headers: requestHeaders, body: body, encoding: encoding).timeout(
            Util.connectivityTimeout);

        Util.printDebug(response.statusCode.toString());
        Util.printDebug('apiGetLoginV4: ${const Utf8Codec().decode(response.bodyBytes)}');

        if (!const Utf8Codec().decode(response.bodyBytes).contains("Erro")) {

          var retono = json.decode(const Utf8Codec().decode(response.bodyBytes));
          var usuario = Usuario.fromMapObjectApi(retono.first);

          Sessao.idUsuario = usuario.id!;
          Sessao.loginUsuario = usuario.login!;
          Sessao.nomeUsuario = usuario.nome!;

          TratarErro.gravarLog('webservice.dart - ${Sessao.idUsuario} - ${Sessao.loginUsuario} - ${Sessao.nomeUsuario}', 'INFO');

          Sessao.idEmpresa = usuario.idEmpresa!;

          return true;
        } else {
          TratarErro.gravarLog('webservice.dart - apiGetLoginV4 ERRO', 'INFO');
          return false;
        }
      } else {
        TratarErro.gravarLog('webservice.dart - apiGetLoginV4 ERRO', 'INFO');
        return false;
      }
    } on Exception catch (e) {
      TratarErro.gravarLog('webservice.dart apiGetLoginV4: $e', 'ERRO');
      rethrow;
    }
  }

  //V4
  Future<bool> apiGetLoginPorId(String usuario, int idUsuario,
      {bool validarInternet = true}) async {
    try {

      if(idUsuario <=0)
      {
        TratarErro.gravarLog('webservice.dart - apiGetLoginPorIdV4() - IdUsuario: 0', 'ERRO');
        return false;
      }

      Util.printDebug('apiGetLoginPorIdV4');
      TratarErro.gravarLog('webservice.dart - apiGetLoginPorIdV4()', 'INFO');

      if (validarInternet == false || await Util.validarInternet()) {
        final uri = Uri.parse('${Util.appUrlBaseWebservice}/api/getLoginPorIdV4');

        Map<String, String> requestHeaders = {
          'Content-Type': 'application/x-www-form-urlencoded',
          //'Accept': 'application/json',
          'Authorization': Util.basicAuth
        };

        Util.printDebug(usuario.toLowerCase().trim());
        Util.printDebug(idUsuario.toString());

        Map body = {
          'login': usuario.toLowerCase().trim(),
          'id': idUsuario.toString()
        };

        final encoding = Encoding.getByName('utf-8');

        Response response = await post(uri,
            headers: requestHeaders, body: body, encoding: encoding).timeout(
            Util.connectivityTimeout);

        Util.printDebug(response.statusCode.toString());
        Util.printDebug(const Utf8Codec().decode(response.bodyBytes));

        if (!const Utf8Codec().decode(response.bodyBytes).contains("Erro")) {
          var retono = json.decode(
              const Utf8Codec().decode(response.bodyBytes));
          var usuario = Usuario.fromMapObjectApi(retono.first);

          Sessao.idUsuario = usuario.id!;
          Sessao.loginUsuario = usuario.login!;
          Sessao.nomeUsuario = usuario.nome!;
          Sessao.idEmpresa = usuario.idEmpresa!;

          return true;
        } else {
          TratarErro.gravarLog('webservice.dart - apiGetLoginPorIdV4 ERRO', 'INFO');
          return false;
        }
      } else {
        TratarErro.gravarLog('webservice.dart - apiGetLoginPorIdV4 ERRO', 'INFO');
        return false;
      }
    } on Exception catch (e) {
      TratarErro.gravarLog('webservice.dart apiGetLoginPorIdV4: $e', 'ERRO');
      rethrow;
    }
  }

  Future<void> apiSaveAparelhos(Aparelho aparelho,
      {bool validarInternet = true}) async {
    try {
      Util.printDebug('apiSaveAparelhosV2');
      TratarErro.gravarLog('webservice.dart - apiSaveAparelhosV2()', 'INFO');

      if (validarInternet == false || await Util.validarInternet()) {
        final uri = Uri.parse('${Util.appUrlBaseWebservice}/api/saveAparelhosV2');

        Map<String, String> requestHeaders = {
          'Content-Type': 'application/x-www-form-urlencoded',
          //'Accept': 'application/json',
          'Authorization': Util.basicAuth
        };

        Map body = {
          'id_usuario': aparelho.idUsuario.toString(),
          'serial_aparelho': aparelho.serialAparelho.toString(),
          'armazenamento': aparelho.armazenamento.toString(),
          'camera': aparelho.camera.toString(),
          'conectividade': aparelho.conectividade.toString(),
          'app_tracking_transparency': aparelho.appTrackingTransparency
              .toString(),
          'gps': aparelho.gps.toString(),
          'plataforma': aparelho.plataforma.toString(),
          'internet': aparelho.internet.toString(),
          'site': aparelho.site.toString(),
          'versao_app': aparelho.versaoApp.toString(),
          'versao_database': aparelho.versaoDatabase.toString(),
          'informacoes': aparelho.informacoes.toString(),
          'imei': aparelho.imei.toString(),
          'telefone': aparelho.telefone.toString(),
        };

        final encoding = Encoding.getByName('utf-8');
        Response response = await post(uri,
            headers: requestHeaders, body: body, encoding: encoding).timeout(
            Util.connectivityTimeout);

        String retorno = const Utf8Codec()
            .decode(response.bodyBytes)
            .toLowerCase();

        Util.printDebug(response.statusCode.toString());
        Util.printDebug('apiSaveAparelhos: $retorno');

        if (retorno.contains("sucesso")) {
          aparelho.Enviado = 1;
        } else {
          TratarErro.gravarLog('webservice.dart: $retorno', 'ERRO');
          aparelho.Enviado = 0;
        }
      }
    } on Exception catch (e) {
      TratarErro.gravarLog('webservice.dart apiSaveAparelhos: $e', 'ERRO');
      rethrow;
    }
  }
}