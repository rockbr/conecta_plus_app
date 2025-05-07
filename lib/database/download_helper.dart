import 'package:conecta_plus_app/database/database_helper.dart';
import 'package:conecta_plus_app/model/download.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DownloadHelper extends DatabaseHelper {
  static Future criarDownload(Database db) async {
    try {
      Util.printDebug('criarDownload');

      //#region Download
      await db.execute('''
          CREATE TABLE IF NOT EXISTS $downloadTable  (
          $downloadColId INTEGER PRIMARY KEY,
          $downloadColDataHora TEXT NOT NULL,
          $downloadColDescricao TEXT NOT NULL,
          $downloadColLink TEXT NOT NULL,
          $downloadColIdUsuario INTEGER NOT NULL,
          $downloadColIdUsuarioConecta INTEGER
          )''');
      //#endregion
    } on Exception catch (e) {
      TratarErro.gravarLog('download_helper.dart $e', 'ERRO');
    }
  }

  //#region Download

  Future deleteTodosDownload() async {
    Util.printDebug('deleteTodosDownload');

    Database db = await DatabaseHelper.instance.database;
    await db.delete(downloadTable);
  }

  Future<bool> insertListDownload(List<Download> listaDownload) async {
    try {

      await deleteTodosDownload();

      Util.printDebug('insertListDownload');

      Database db = await DatabaseHelper.instance.database;

      for (var item in listaDownload) {
        db.insert(downloadTable, item.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      return true;
    } on Exception catch (e) {
      TratarErro.gravarLog('download_helper.dart $e', 'ERRO');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getDownloadMapList(int idUsuario) async {
    Util.printDebug('getDownloadMapList');

    Database db = await DatabaseHelper.instance.database;

    var result = await db.query(downloadTable,
        where: '$downloadColIdUsuario = ?',
        whereArgs: [idUsuario],
        orderBy: '$downloadColDataHora DESC');
    return result;
  }

  Future<List<Download>> getDownloadList(int idUsuario) async {
    Util.printDebug('getDownloadList');

    var downloadMapList = await getDownloadMapList(idUsuario);
    int count = downloadMapList.length;

    List<Download> downloadList = [];

    for (int i = 0; i < count; i++) {
      downloadList.add(Download.fromMapObject(downloadMapList[i]));
    }
    return downloadList;
  }

//#endregion
}
