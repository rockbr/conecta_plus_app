import 'package:conecta_plus_app/database/database_helper.dart';
import 'package:conecta_plus_app/model/ponto.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';


class PontoHelper extends DatabaseHelper {
  static Future criarPontos(Database db) async {
    try {
      Util.printDebug('criarPontos');

      //#region Pontos
      await db.execute('''
          CREATE TABLE IF NOT EXISTS $pontosTable (
          $pontosColId INTEGER PRIMARY KEY,
          $pontosColData TEXT NOT NULL,
          $pontosColDataHora TEXT NOT NULL,          
          $pontosColLatitude TEXT NOT NULL,
          $pontosColLongitude TEXT NOT NULL,
          $pontosColLogradouro TEXT,
          $pontosColNumero TEXT,
          $pontosColBairro TEXT,
          $pontosColCep TEXT,
          $pontosColCidade TEXT,
          $pontosColIdUsuario INTEGER,          
          $pontosColIdUsuarioConecta INTEGER,
          $pontosColEnviado INTEGER NOT NULL,
          $pontosColFinalizado INTEGER NOT NULL DEFAULT(0)
          )''');
      //#endregion
    } on Exception catch (e) {
      TratarErro.gravarLog('ponto_helper.dart $e', 'ERRO');
    }
  }

  Future<List<Ponto>> getPontoNaoEnviada() async {
    Util.printDebug('getPontoNaoEnviada');

    Database db = await DatabaseHelper.instance.database;

    var pontosMapList =
    await db.rawQuery('''SELECT * FROM $pontosTable WHERE enviado = 0''');

    int count =
        pontosMapList.length; // Count the number of map entries in db table

    List<Ponto> pontosList = [];
    for (int i = 0; i < count; i++) {
      pontosList.add(Ponto.fromMapObject(pontosMapList[i]));
    }

    return pontosList;
  }

  Future<bool> updateListPonto(List<Ponto> ponto) async {
    Util.printDebug('updateListPonto');

    Database db = await DatabaseHelper.instance.database;

    for (var item in ponto) {
      db.update(pontosTable, item.toMap(),
          where: "id = ?", whereArgs: [item.id]);
    }

    return true;
  }

  Future<bool> updatePontoFinalizado() async {
    Util.printDebug('updatePontoFinalizado');

    Database db = await DatabaseHelper.instance.database;

    await db.rawUpdate(
        '''UPDATE $pontosTable SET $pontosColFinalizado = ? WHERE $pontosColFinalizado = ?''',
        [1, 0]);

    return true;
  }

  Future<List<Ponto>> getPontoTipo(
      String tipo, int idUsuario, String data) async {
    Util.printDebug('getPontoTipo');

    Database db = await DatabaseHelper.instance.database;

    var result = await db.query(pontosTable,
        where: "tipo = ? AND id_usuario = ? AND data = ? AND finalizado = ?",
        whereArgs: [tipo, idUsuario, data, 0],
        orderBy: '$pontosColData DESC',
        limit: 1);

    int count = result.length; // Count the number of map entries in db table

    List<Ponto> pontoList = [];
    // For loop to create a 'ponto List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      pontoList.add(Ponto.fromMapObject(result[i]));
    }

    return pontoList;
  }

  Future<List<Ponto>> getPontoDoDia(
      int idUsuario, String data) async {
    Util.printDebug('getPontoDoDia');

    Database db = await DatabaseHelper.instance.database;

    String sql =
        "SELECT * FROM $pontosTable WHERE $pontosColIdUsuario = $idUsuario AND $pontosColData = '$data' AND $pontosColFinalizado = 0 ORDER BY $pontosColData desc";

    Util.printDebug(sql);

    var pontoMapList = await db.rawQuery(sql);

    int count =
        pontoMapList.length; // Count the number of map entries in db table

    List<Ponto> pontoList = [];
    // For loop to create a 'ponto List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      pontoList.add(Ponto.fromMapObject(pontoMapList[i]));
    }

    return pontoList;
  }

  Future<List<Map<String, dynamic>>> getPontoMapList() async {
    Util.printDebug('getPontoMapList');

    Database db = await DatabaseHelper.instance.database;

    var result = await db.query(pontosTable, orderBy: '$pontosColId DESC');
    return result;
  }

  Future<int> insertPonto(Ponto ponto) async {
    Util.printDebug('insertPonto');

    Database db = await DatabaseHelper.instance.database;

    var result = await db.insert(pontosTable, ponto.toMap());
    return result;
  }

  Future<bool> insertListPonto(List<Ponto> ponto) async {
    try {
      Util.printDebug('insertListPonto');

      Database db = await DatabaseHelper.instance.database;

      for (var item in ponto) {
        db.insert(pontosTable, item.toMap());
      }

      return true;
    } on Exception catch (e) {
      TratarErro.gravarLog('ponto_helper.dart $e', 'ERRO');
      return false;
    }
  }

  Future<List<Ponto>> getPontoList() async {
    Util.printDebug('getPontoList');

    Database db = await DatabaseHelper.instance.database;

    var pontoMapList = await getPontoMapList(); // Get 'Map List' from database
    int count =
        pontoMapList.length; // Count the number of map entries in db table

    List<Ponto> pontoList = [];
    // For loop to create a 'ponto List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      pontoList.add(Ponto.fromMapObject(pontoMapList[i]));
    }

    return pontoList;
  }
}