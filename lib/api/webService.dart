import 'dart:convert';
import 'dart:io';
import 'package:conecta_plus_app/database/pessoas_helper.dart';
import 'package:conecta_plus_app/database/usuarios_helper.dart';
import 'package:conecta_plus_app/model/foto.dart';
import 'package:conecta_plus_app/model/pessoa.dart';
import 'package:conecta_plus_app/model/ponto.dart';
import 'package:conecta_plus_app/model/usuario.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:conecta_plus_app/model/aparelho.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';

class WebService {

  final usuariosHelper = UsuariosHelper();

  Future<List<Foto>> apiSaveFotos(List<Foto> listMidia,
      {bool validarInternet = true}) async {
    try {
      Util.printDebug('apiSaveFotosV2');
      TratarErro.gravarLog('webservice.dart - apiSaveFotosV2()', 'INFO');

      if (validarInternet == false || await Util.validarInternet()) {
        final uri = Uri.parse('${Util.appUrlBaseWebservice}/api/saveFotosV2');

        Map<String, String> requestHeaders = {
          'Content-Type': 'application/x-www-form-urlencoded',
          //'Accept': 'application/json',
          'Authorization': Util.basicAuth
        };

        for (var item in listMidia) {
          String nomeArquivo = item.arquivo;

          if (await File(nomeArquivo).exists()) {
            List<int> fileBytes = File(nomeArquivo).readAsBytesSync();

            String base64Image = base64.encode(fileBytes);

            Map body = {
              'data_hora_app': item.dataHora.toString(),
              'id_usuario': item.idUsuario.toString(),
              'img_base64': base64Image,
            };

            final encoding = Encoding.getByName('utf-8');
            Response response = await post(uri,
                headers: requestHeaders, body: body, encoding: encoding)
                .timeout(Util.connectivityTimeout);

            String retorno = const Utf8Codec()
                .decode(response.bodyBytes)
                .toLowerCase();

            Util.printDebug(response.statusCode.toString());
            Util.printDebug('apiSaveFotos: $retorno');

            if (retorno.contains("sucesso")) {

              Usuario usuario = Usuario.withUltimaFoto(
                  id: Sessao.idUsuario, ultimaFoto: Sessao.ultimoEnvioFoto);
              await usuariosHelper.updateUsuario(usuario);

              item.Enviado = 1;
            } else {
              TratarErro.gravarLog('webservice.dart: $retorno', 'ERRO');
              item.Enviado = 0;
            }
          } else {
            item.fotoDeletada = 1;

            TratarErro.gravarLog(
                'webservice.dart fotoDeletada: $nomeArquivo', 'INFO');
          }
        }
      }
      return listMidia;
    } on Exception catch (e) {
      TratarErro.gravarLog('webservice.dart apiSaveFotos: $e', 'ERRO');
      rethrow;
    }
  }

  Future<bool> apiGetLogin(String usuario, String senha,
      {bool validarInternet = true}) async {
    try {
      Util.printDebug('apiGetLogin');
      TratarErro.gravarLog('webservice.dart - apiGetLogin()', 'INFO');

      if (validarInternet == false || await Util.validarInternet()) {
        final uri = Uri.parse('${Util.appUrlBaseWebservice}/api/getLogin');

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
        Util.printDebug('apiGetLogin: ${const Utf8Codec().decode(response.bodyBytes)}');

        if (!const Utf8Codec().decode(response.bodyBytes).contains("Erro")) {

          var retono = json.decode(const Utf8Codec().decode(response.bodyBytes));
          var usuario = Usuario.fromMapObjectApi(retono.first);

          Util.printDebug('apiGetLogin: $retono');

          Sessao.idUsuario = usuario.id!;
          Sessao.loginUsuario = usuario.login!;
          Sessao.nomeUsuario = usuario.nome!;
          Sessao.idEmpresa = usuario.idEmpresa!;
          Sessao.idPessoa = usuario.idPessoa!;
          Sessao.idPessoaConecta = usuario.idPessoaConecta!;

          TratarErro.gravarLog('webservice.dart - ${Sessao.idUsuario} - ${Sessao.loginUsuario} - ${Sessao.nomeUsuario} - ${Sessao.idPessoa} - ${Sessao.idPessoaConecta}', 'INFO');

          return true;
        } else {
          TratarErro.gravarLog('webservice.dart - apiGetLogin ERRO', 'INFO');
          return false;
        }
      } else {
        TratarErro.gravarLog('webservice.dart - apiGetLogin ERRO', 'INFO');
        return false;
      }
    } on Exception catch (e) {
      TratarErro.gravarLog('webservice.dart apiGetLogin: $e', 'ERRO');
      rethrow;
    }
  }

  Future<bool> apiGetLoginPorId(String usuario, int idUsuario,
      {bool validarInternet = true}) async {
    try {

      if(idUsuario <=0)
      {
        TratarErro.gravarLog('webservice.dart - apiGetLoginPorId() - IdUsuario: 0', 'ERRO');
        return false;
      }

      Util.printDebug('apiGetLoginPorId');
      TratarErro.gravarLog('webservice.dart - apiGetLoginPorId()', 'INFO');

      if (validarInternet == false || await Util.validarInternet()) {
        final uri = Uri.parse('${Util.appUrlBaseWebservice}/api/getLoginPorId');

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
          Sessao.idPessoa = usuario.idPessoa!;
          Sessao.idPessoaConecta = usuario.idPessoaConecta!;

          return true;
        } else {
          TratarErro.gravarLog('webservice.dart - apiGetLoginPorId ERRO', 'INFO');
          return false;
        }
      } else {
        TratarErro.gravarLog('webservice.dart - apiGetLoginPorId ERRO', 'INFO');
        return false;
      }
    } on Exception catch (e) {
      TratarErro.gravarLog('webservice.dart apiGetLoginPorId: $e', 'ERRO');
      rethrow;
    }
  }

  Future<bool> apiGetIntegraUsuarios(int idUsuario, int idPessoaConecta,
      {bool validarInternet = true}) async {
    try {
      if (idUsuario <= 0) {
        TratarErro.gravarLog(
            'webservice.dart - apiGetIntegraUsuarios() - IdUsuario: 0', 'ERRO');
        return false;
      }

      Util.printDebug('apiGetIntegraUsuarios');
      TratarErro.gravarLog('webservice.dart - apiGetIntegraUsuarios()', 'INFO');

      if (!validarInternet || await Util.validarInternet()) {
        final uri = Uri.parse(
          '${Util.appUrlBaseWebservice}/api/getIntegraUsuarios'
              '?id_pessoa_lider_conecta=$idPessoaConecta&id_usuario=$idUsuario',
        );

        Map<String, String> requestHeaders = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': Util.basicAuth
        };

        Util.printDebug('idPessoaConecta: $idPessoaConecta');
        Util.printDebug('idUsuario: $idUsuario');

        final response = await get(uri, headers: requestHeaders)
            .timeout(Util.connectivityTimeout);

        final bodyDecoded = const Utf8Codec().decode(response.bodyBytes);
        Util.printDebug('Status: ${response.statusCode}');
        Util.printDebug('Body: $bodyDecoded');

        if (!bodyDecoded.contains("Erro")) {
          final parsedJson = json.decode(bodyDecoded);

          if (parsedJson is List && parsedJson.isNotEmpty) {
            List<Pessoa> pessoas = parsedJson
                .map<Pessoa>((e) => Pessoa.fromMapObjectApi(e))
                .toList();

            final pessoasHelper = PessoasHelper();

            if (pessoas.isNotEmpty) {
              await pessoasHelper.insertListPessoa(pessoas);
            }
            return true;
          } else {
            TratarErro.gravarLog(
                'webservice.dart - apiGetIntegraUsuarios() - Lista vazia', 'INFO');
            return false;
          }
        } else {
          TratarErro.gravarLog(
              'webservice.dart - apiGetIntegraUsuarios() - Erro no retorno', 'INFO');
          return false;
        }
      } else {
        TratarErro.gravarLog(
            'webservice.dart - apiGetIntegraUsuarios() - Sem internet', 'INFO');
        return false;
      }
    } on Exception catch (e) {
      TratarErro.gravarLog('webservice.dart - apiGetIntegraUsuarios: $e', 'ERRO');
      rethrow;
    }
  }

  Future<void> apiSaveAparelhos(Aparelho aparelho,
      {bool validarInternet = true}) async {
    try {
      Util.printDebug('apiSaveAparelhos');
      TratarErro.gravarLog('webservice.dart - apiSaveAparelhos()', 'INFO');

      if (validarInternet == false || await Util.validarInternet()) {
        final uri = Uri.parse('${Util.appUrlBaseWebservice}/api/saveAparelhos');

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
          'app_tracking_transparency': aparelho.appTrackingTransparency.toString(),
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

  Future<List<Ponto>> apiSavePontos(List<Ponto> listPonto,
      {bool validarInternet = true}) async {
    try {
      Util.printDebug('apiSavePontosV2');
      TratarErro.gravarLog('webservice.dart - saveIntegraUsuariosPontos()', 'INFO');

      if (validarInternet == false || await Util.validarInternet()) {
        final uri = Uri.parse('${Util.appUrlBaseWebservice}/api/saveIntegraUsuariosPontos');

        Map<String, String> requestHeaders = {
          'Content-Type': 'application/x-www-form-urlencoded',
          //'Accept': 'application/json',
          'Authorization': Util.basicAuth
        };

        for (var item in listPonto) {
          Map body = {
            'data_ponto': item.dataHora.toString(),
            'id_usuario': item.idUsuario.toString(),
            'id_usuario_conecta': item.idUsuarioConecta.toString(),
            'latitude': item.latitude,
            'longitude': item.longitude,
            'observacao': "",
            'endereco': "${item.logradouro!}, ${item.numero!} - ${item.bairro!} - ${item.cep!} / ${item.cidade!}",
          };

          final encoding = Encoding.getByName('utf-8');
          Response response = await post(uri,
              headers: requestHeaders, body: body, encoding: encoding).timeout(
              Util.connectivityTimeout);

          String retorno = const Utf8Codec()
              .decode(response.bodyBytes)
              .toLowerCase();

          Util.printDebug(response.statusCode.toString());
          Util.printDebug('apiSavePontos: $retorno');

          if (retorno.contains("sucesso")) {
            Sessao.ultimoEnvioPonto =
                DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

            Usuario usuario = Usuario.withUltimaPonto(
                id: Sessao.idUsuario, ultimaPonto: Sessao.ultimoEnvioPonto);
            await usuariosHelper.updateUsuario(usuario);

            item.Enviado = 1;
          } else {
            TratarErro.gravarLog('webservice.dart: $retorno', 'ERRO');
            item.Enviado = 0;
          }

        }
      }
      return listPonto;
    } on Exception catch (e) {
      TratarErro.gravarLog('webservice.dart saveIntegraUsuariosPontos: $e', 'ERRO');
      rethrow;
    }
  }
}