import 'package:conecta_plus_app/database/database_helper.dart';
import 'package:conecta_plus_app/database/log_helper.dart';
import 'package:conecta_plus_app/model/log.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/util.dart';

class TratarErro {
  static void gravarLog(String mensagem, String tipo) async {
    try {
      Util.printDebug('$tipo: $mensagem');
      final logHelper = LogHelper();

      Log logErro = Log.notId(
          dataHora: DateTime.now().toString(),
          idUsuario: Sessao.idUsuario,
          tipo: tipo,
          mensagem: mensagem);

      try {
        await logHelper.insertLog(logErro);
      } on Exception {

        final databaseHelper = DatabaseHelper();
        //se der erro tenta recirar as tabelas
        await databaseHelper.recriarTabelas();

        try {
          await logHelper.insertLog(logErro);
        } on Exception catch (e) {
          Util.printDebug('ERRO: $e');
        }

      }

    } on Exception catch (e) {
      Util.printDebug('ERRO: $e');
    }
  }
}
