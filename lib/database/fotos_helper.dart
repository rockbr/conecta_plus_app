import 'package:conecta_plus_app/database/database_helper.dart';
import 'package:conecta_plus_app/model/foto.dart';
import 'package:conecta_plus_app/model/pessoa.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class FotosHelper extends DatabaseHelper{

  static Future criarFotos(Database db) async {
    try {
      Util.printDebug('criarFotos');

      //#region Fotos
      await db.execute('''
          CREATE TABLE IF NOT EXISTS $fotosTable  (
          $fotosColId INTEGER PRIMARY KEY,          
          $fotosColDataHora TEXT NOT NULL,
          $fotosColIdUsuario INTEGER NOT NULL,
          $fotosColIdUsuarioConecta INTEGER ,              
          $fotosColArquivo TEXT NOT NULL,          
          $fotosColEnviado INTEGER NOT NULL,
          $fotosColFinalizado INTEGER NOT NULL DEFAULT(0),          
          $fotosColFotoDeletada INTEGER
          )''');
      //#endregion
    } on Exception catch (e) {
      TratarErro.gravarLog('database_helper.dart $e', 'ERRO');
    }
  }

  //#region Fotos

  Future<List<Foto>> getFotoNaoEnviada() async {
    Util.printDebug('getFotoNaoEnviada');

    Database db = await DatabaseHelper.instance.database;
    var fotoMapList = await db.rawQuery(
        '''SELECT * FROM $fotosTable WHERE $fotosColEnviado = 0 AND ($fotosColFotoDeletada IS NULL OR $fotosColFotoDeletada=0)''');

    int count =
        fotoMapList.length; // Count the number of map entries in db table

    List<Foto> fotoList = [];
    for (int i = 0; i < count; i++) {
      fotoList.add(Foto.fromMapObject(fotoMapList[i]));
    }

    return fotoList;
  }

  Future<bool> updateListFoto(List<Foto> foto) async {
    Util.printDebug('updateListFoto');

    Database db = await DatabaseHelper.instance.database;

    for (var item in foto) {
      db.update(fotosTable, item.toMap(),
          where: "id = ?", whereArgs: [item.id]);
    }

    return true;
  }

  Future<List<Foto>> getFotoDoDia(
      int idUsuario, int idCliente, String data) async {
    Util.printDebug('getFotoDoDia');

    Database db = await DatabaseHelper.instance.database;
    var fotoMapList = await db.rawQuery('''
                      SELECT * FROM $fotosTable 
                      WHERE $fotosColIdUsuario = $idUsuario AND            
                            DATE($fotosColDataHora) = DATE('$data') AND 
                            $fotosColFinalizado = 0 
                      ORDER BY $fotosColDataHora DESC
                    ''');

    int count =
        fotoMapList.length; // Count the number of map entries in db table

    List<Foto> fotoList = [];
    for (int i = 0; i < count; i++) {
      fotoList.add(Foto.fromMapObject(fotoMapList[i]));
    }

    return fotoList;
  }

  Future<bool> insertListFoto(List<Foto> foto) async {
    Util.printDebug('insertListFoto');

    Database db = await DatabaseHelper.instance.database;

    for (var item in foto) {
      db.insert(fotosTable, item.toMap());
    }

    return true;
  }

  Future<int> insertFoto(Foto foto) async {
    Util.printDebug('insertFoto');

    Database db = await DatabaseHelper.instance.database;
    var result = await db.insert(fotosTable, foto.toMap());
    return result;
  }

  Future<bool> updateFotoFinalizado() async {
    Util.printDebug('updateFotoFinalizado');

    Database db = await DatabaseHelper.instance.database;
    await db.rawUpdate(
        '''UPDATE $fotosTable SET $fotosColFinalizado = ? WHERE $fotosColFinalizado = ?''',
        [1, 0]);

    return true;
  }


//#endregion

}