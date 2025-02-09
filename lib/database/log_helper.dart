
import 'package:conecta_plus_app/database/database_helper.dart';
import 'package:conecta_plus_app/model/log.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:sqflite/sqlite_api.dart';

class LogHelper extends DatabaseHelper{

  static Future criarLog(Database db) async {
    try {
      Util.printDebug('criarLog');

      //#region Log
      await db.execute('''
          CREATE TABLE IF NOT EXISTS $logTable  (
          $logColId INTEGER PRIMARY KEY,
          $logColDataHora TEXT NOT NULL,
          $logColIdUsuario INTEGER NOT NULL,
          $logColTipo TEXT NOT NULL,
          $logColMensagem TEXT NOT NULL
          )''');
      //#endregion
    } on Exception catch (e) {
      TratarErro.gravarLog('database_helper.dart $e', 'ERRO');
    }
  }

  //#region Log

  Future<int> insertLog(Log log) async {
    Util.printDebug('insertLog');

    Database db = await DatabaseHelper.instance.database;
    var result = await db.insert(logTable, log.toMap());
    return result;
  }

//#endregion Log

}