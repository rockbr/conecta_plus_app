import 'package:conecta_plus_app/database/database_helper.dart';
import 'package:conecta_plus_app/model/ocorrencia.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';


class OcorrenciasHelper extends DatabaseHelper{

  static Future criarOcorrencias(Database db) async {
    try {
      Util.printDebug('criarOcorrencias');

      //#region Ocorrencias
      await db.execute('''
          CREATE TABLE IF NOT EXISTS $ocorrenciasTable  (
          $ocorrenciasColId INTEGER PRIMARY KEY,          
          $ocorrenciasColDataHora TEXT NOT NULL,
          $ocorrenciasColIdUsuario INTEGER NOT NULL,
          $ocorrenciasColIdUsuarioConecta INTEGER ,
          $ocorrenciasColOcorrencia TEXT NOT NULL,
          $ocorrenciasColCaminhoArquivo TEXT,     
          $ocorrenciasColExtensao TEXT,         
          $ocorrenciasColRecebida INTEGER,          
          $ocorrenciasColEnviado INTEGER NOT NULL,
          $ocorrenciasColFinalizado INTEGER NOT NULL DEFAULT(0)
          )''');
      //#endregion
    } on Exception catch (e) {
      TratarErro.gravarLog('database_helper.dart $e', 'ERRO');
    }
  }

  //#region Ocorrencias

  Future<List<Ocorrencia>> getOcorrenciaNaoEnviada() async {
    Util.printDebug('getOcorrenciaNaoEnviada');

    Database db = await DatabaseHelper.instance.database;
    var ocorrenciasMapList = await db
        .rawQuery('''SELECT * FROM $ocorrenciasTable WHERE $ocorrenciasColEnviado=0 AND $ocorrenciasColRecebida !=1''');

    int count = ocorrenciasMapList
        .length; // Count the number of map entries in db table

    List<Ocorrencia> ocorrenciasList = [];
    for (int i = 0; i < count; i++) {
      ocorrenciasList.add(Ocorrencia.fromMapObject(ocorrenciasMapList[i]));
    }

    return ocorrenciasList;
  }

  Future<bool> updateListOcorrencia(List<Ocorrencia> ocorrencia) async {
    Util.printDebug('updateListOcorrencia');

    Database db = await DatabaseHelper.instance.database;

    for (var item in ocorrencia) {
      db.update(ocorrenciasTable, item.toMap(),
          where: "id = ?", whereArgs: [item.id]);
    }

    return true;
  }

  Future<int> insertOcorrencia(Ocorrencia ocorrencia) async {
    Util.printDebug('insertOcorrencia');

    Database db = await DatabaseHelper.instance.database;
    var result = await db.insert(ocorrenciasTable, ocorrencia.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  Future<bool> insertListOcorrencia(List<Ocorrencia> ocorrencia) async {
    Util.printDebug('insertListOcorrencia');

    Database db = await DatabaseHelper.instance.database;

    for (var item in ocorrencia) {
      db.insert(ocorrenciasTable, item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    return true;
  }

  Future<List<Map<String, dynamic>>> getOcorrenciaMapList(
      int idUsuario, int idCliente) async {
    Util.printDebug('getOcorrenciaMapList');

    Database db = await DatabaseHelper.instance.database;

    var result = await db.query(ocorrenciasTable,
        where: '$ocorrenciasColIdUsuario = ? AND $ocorrenciasColIdUsuarioConecta = ?',
        whereArgs: [idUsuario, idCliente],
        orderBy: '$ocorrenciasColDataHora ASC');
    return result;
  }

  Future<List<Ocorrencia>> getOcorrenciaList(
      int idUsuario, int idCliente) async {
    Util.printDebug('getOcorrenciaList');

    var ocorrenciaMapList = await getOcorrenciaMapList(idUsuario, idCliente);
    int count = ocorrenciaMapList.length;

    List<Ocorrencia> ocorrenciaList = [];

    for (int i = 0; i < count; i++) {
      ocorrenciaList.add(Ocorrencia.fromMapObject(ocorrenciaMapList[i]));
    }
    return ocorrenciaList;
  }

  Future<bool> updateOcorrenciasFinalizado() async {
    Util.printDebug('updateOcorrenciasFinalizado');

    Database db = await DatabaseHelper.instance.database;
    await db.rawUpdate(
        '''UPDATE $ocorrenciasTable SET $ocorrenciasColFinalizado = ? WHERE $ocorrenciasColFinalizado = ? AND $ocorrenciasColRecebida != ?''',
        [1, 0, 1]);

    return true;
  }

  Future<String> getUltimaMensagemRecebida() async {
    try {
      Util.printDebug('getUltimaMensagemRecebida');

      Database db = await DatabaseHelper.instance.database;

      var result = await db.query(ocorrenciasTable,
          where: "$ocorrenciasColRecebida = ?",
          orderBy: '$ocorrenciasColDataHora DESC',
          whereArgs: [1],
          limit: 1);

      if (result.isNotEmpty) {
        // Se houver uma mensagem encontrada, retorne a data formatada como string
        String data = (result.first[ocorrenciasColDataHora] ?? '').toString();
        if (data.isNotEmpty) {
          return data;
        }
      }

      // Caso contrário, retorne uma data com horário 00:00:00
      DateTime now = DateTime.now();
      DateTime dataZeroHora = DateTime(now.year, now.month, now.day);
      return dataZeroHora.toIso8601String();

    } on Exception catch (e) {
      TratarErro.gravarLog('ocorrencias_helper.dart $e', 'ERRO');

      // Caso contrário, retorne uma data com horário 00:00:00
      DateTime now = DateTime.now();
      DateTime dataZeroHora = DateTime(now.year, now.month, now.day);
      return dataZeroHora.toIso8601String();
    }
  }

//#endregion

}
