
import 'package:conecta_plus_app/database/database_helper.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseUpgrade extends DatabaseHelper {

  Future<void> upgradeToVersion(Database db, int version) async {
    switch (version) {
      case 1:
        await versao0001(db, true);
        break;
      default:
        throw Exception('Versão desconhecida: $version');
    }
  }


  Future _execute(Database db, String sql, bool gravarLog) async {
    try {
      Util.printDebug('<-- versaoTodos');

      Util.printDebug(sql);

      await db.execute(sql);
    } on Exception catch (e) {
      if (gravarLog) {
        TratarErro.gravarLog('database_helper.dart $e', 'ERRO');
      }
    }
  }

  Future versaoTodos(Database db, bool gravarLog) async {
    try {
      Util.printDebug('<-- versaoTodos');

      await versao0001(db, gravarLog);

      Util.printDebug('versaoTodos -->');
    } on Exception catch (e) {
      TratarErro.gravarLog('database_upgrade.dart $e', 'ERRO');
    }
  }

  Future versao0001(Database db, bool gravarLog) async {
    try {
      Util.printDebug('versao0001');
    } on Exception catch (e) {
      if (gravarLog) {
        TratarErro.gravarLog('database_upgrade.dart $e', 'ERRO');
      }
    }
  }
  }