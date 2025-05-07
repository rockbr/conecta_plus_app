
import 'package:conecta_plus_app/api/webService.dart';
import 'package:conecta_plus_app/database/fotos_helper.dart';
import 'package:conecta_plus_app/database/ponto_helper.dart';
import 'package:conecta_plus_app/model/aparelho.dart';
import 'package:conecta_plus_app/model/foto.dart';
import 'package:conecta_plus_app/model/ponto.dart';
import 'package:conecta_plus_app/permissao.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';

class EnviaDados {

  static int enviaPontos = 0;
  static int enviaAparelhos = 0;
  static int enviaFotos = 0;

  static Future<void> enviarTodosDados() async {
    try {

      Permissao().verificaPermissoes();

      await enviaPontosApi();
      await enviaFotosApi();

    } on Exception catch (e) {
      TratarErro.gravarLog('envia_dados.dart $e', 'ERRO');
    }
  }

  static Future<void> enviarTodosDadosAsync() async {
    try {

      Permissao().verificaPermissoes();

      enviaPontosApi();
      enviaFotosApi();

    } on Exception catch (e) {
      TratarErro.gravarLog('envia_dados.dart $e', 'ERRO');
    }
  }

  static enviaPontosApi({bool validarInternet = true}) async {
    try {


      Util.printDebug("enviaPontosApi");
      bool semDadosParaEnviar = true;

      if (enviaPontos == 0) {
        enviaPontos = 1;

        final pontoHelper = PontoHelper();

        //Verifica se tem dados para enviar
        if (validarInternet == false || await Util.validarInternet()) {
          Util.printDebug("enviaDadosApi - Com Internet");
          //Pontos
          List<Ponto> pontosSalvos = await pontoHelper.getPontoNaoEnviada();
          if (pontosSalvos.isNotEmpty) {
            List<Ponto> pontosSalvosWs = await WebService().apiSavePontos(pontosSalvos,
                validarInternet: validarInternet);
            Util.printDebug("Update Pontos");
            pontoHelper.updateListPonto(pontosSalvosWs);

            semDadosParaEnviar = false;
          }

          if (semDadosParaEnviar) {
            enviaPontos = 0;
            throw Exception('OK - Não foi localizado pontos para envio.');
          }
        } else {
          enviaPontos = 0;
          String erro =
              'Não foi possível conectar a internet para enviar pontos.';
          throw Exception(erro);
        }
        enviaPontos = 0;

        verificaDadosNaoEnviadosPontos();
      }
    } on Exception catch (e) {
      enviaPontos = 0;
      TratarErro.gravarLog('envia_dados.dart: enviaPontosApi $e', 'ERRO');
      rethrow;
    }
  }

  static enviaEquipamentosApi(Aparelho aparelho, {bool validarInternet = true}) async {
    try {
      Util.printDebug("enviaEquipamentosApi");

      if (enviaAparelhos == 0) {
        enviaAparelhos = 1;

        if (validarInternet == false || await Util.validarInternet()) {

          Util.printDebug("enviaDadosApi - Com Internet");
          await WebService().apiSaveAparelhos(aparelho, validarInternet: validarInternet);

        } else {
          enviaAparelhos = 0;
          String erro = 'Não foi possível conectar a internet para enviar aparelhos.';
          throw Exception(erro);
        }
        enviaAparelhos = 0;
      }

    } on Exception catch (e) {
      enviaAparelhos = 0;
      TratarErro.gravarLog('envia_dados.dart: enviaEquipamentosApi $e', 'ERRO');
      rethrow;
    }
  }

  static enviaFotosApi({bool validarInternet = true}) async {
    try {

      Util.printDebug("enviaFotosApi");
      bool semDadosParaEnviar = true;

      if (enviaFotos == 0) {
        enviaFotos = 1;

        final fotosHelper = FotosHelper();

        //Verifica se tem dados para enviar
        if (validarInternet == false || await Util.validarInternet()) {
          //Fotos
          List<Foto> midiasSalvas = await fotosHelper.getFotoNaoEnviada();
          if (midiasSalvas.isNotEmpty) {
            List<Foto> midiasSalvasWs = await WebService().apiSaveFotos(midiasSalvas, validarInternet: validarInternet);
            Util.printDebug("Update Foto");
            fotosHelper.updateListFoto(midiasSalvasWs);

            semDadosParaEnviar = false;
          }

          if (semDadosParaEnviar) {
            enviaFotos = 0;
            throw Exception('OK - Não foi localizado fotos para envio.');
          }
        } else {
          enviaFotos = 0;
          String erro =
              'Não foi possível conectar a internet par enviar fotos.';
          throw Exception(erro);
        }
        enviaFotos = 0;

        verificaDadosNaoEnviadosFotos();
      }
    } on Exception catch (e) {
      enviaFotos = 0;
      TratarErro.gravarLog('envia_dados.dart: enviaFotosApi $e', 'ERRO');
      rethrow;
    }
  }

  static verificaDadosNaoEnviadosPontos() async {
    try {

      final pontoHelper = PontoHelper();

      Util.printDebug("verificaDadosNaoEnviadosPontos - Ponto");
      //Pontos
      List<Ponto> pontosSalvos = await pontoHelper.getPontoNaoEnviada();
      if (pontosSalvos.isNotEmpty) {
        Sessao.envioPendentePonto = 1;
      } else {
        Sessao.envioPendentePonto = 0;
      }
    } on Exception catch (e) {
      TratarErro.gravarLog(
          'envia_dados.dart: verificaDadosNaoEnviadosPontos $e', 'ERRO');
      rethrow;
    }
  }

  static verificaDadosNaoEnviadosFotos() async {
    try {

      Util.printDebug("verificaDadosNaoEnviadosFotos - Fotos");

      final fotosHelper = FotosHelper();

      //Fotos
      List<Foto> midiasSalvas = await fotosHelper.getFotoNaoEnviada();
      if (midiasSalvas.isNotEmpty) {
        Sessao.envioPendenteFoto = 1;
      } else {
        Sessao.envioPendenteFoto = 0;
      }
    } on Exception catch (e) {
      TratarErro.gravarLog(
          'envia_dados.dart: verificaDadosNaoEnviadosFotos $e', 'ERRO');
      rethrow;
    }
  }
}