
import 'package:conecta_plus_app/api/webService.dart';
import 'package:conecta_plus_app/model/aparelho.dart';
import 'package:conecta_plus_app/permissao.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';

class EnviaDados {

  static int enviaAparelhos = 0;

  //Verifica

  // Envio


  //Todos

  static Future<void> enviarTodosDados() async {
    try {

      Permissao().verificaPermissoes();

    } on Exception catch (e) {
      TratarErro.gravarLog('envia_dados.dart $e', 'ERRO');
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

  static Future<void> enviarTodosDadosAsync() async {
    try {

      Permissao().verificaPermissoes();


    } on Exception catch (e) {
      TratarErro.gravarLog('envia_dados.dart $e', 'ERRO');
    }
  }

}