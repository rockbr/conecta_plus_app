import 'package:conecta_plus_app/database/database_helper.dart';
import 'package:conecta_plus_app/model/usuario.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class UsuariosHelper extends DatabaseHelper {

  static Future criarUsuarios(Database db) async {
    try {
      Util.printDebug('criarUsuarios');

      //#region Usuarios
      await db.execute('''
          CREATE TABLE IF NOT EXISTS $usuariosTable  (
          $usuariosColId INTEGER NOT NULL PRIMARY KEY UNIQUE,          
          $usuariosColNome TEXT NOT NULL,
          $usuariosColLogin TEXT NOT NULL,
          $usuariosColBloqueado INTEGER NOT NULL,
          $usuariosColIdEmpresa INTEGER,
          $usuariosColIdPessoa INTEGER,
          $usuariosColIdPessoaConecta INTEGER,
          $usuariosColDataNascimento TEXT,
          $usuariosColUltimaPonto TEXT,
          $usuariosColUltimaFoto TEXT
          )''');
      //#endregion
    } on Exception catch (e) {
      TratarErro.gravarLog('database_helper.dart $e', 'ERRO');
      rethrow;
    }
  }

  //#region Usuarios

  Future<Usuario?> getUsuario() async {
    try {
      Util.printDebug('getUsuario');
      TratarErro.gravarLog('usuarios_helper.dart - getUsuario()', 'INFO');

      Database db = await DatabaseHelper.instance.database;

      var result = await db.query(usuariosTable,
          where: "bloqueado = ? AND id > ?", whereArgs: [0, 0], limit: 1);

      return result.isNotEmpty && result.isNotEmpty
          ? Usuario.fromMapObject(result.first)
          : null;
    } on Exception catch (e) {
      TratarErro.gravarLog('usuarios_helper.dart $e', 'ERRO');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getUsuarioMapList() async {
    try{
      Util.printDebug('getUsuarioMapList');
      TratarErro.gravarLog('usuarios_helper.dart - getUsuarioMapList()', 'INFO');

      Database db = await DatabaseHelper.instance.database;

      var result = await db.query(usuariosTable, orderBy: '$usuariosColId ASC');
      return result;
    } on Exception catch (e) {
      TratarErro.gravarLog('usuarios_helper.dart: $e', 'ERRO');
      rethrow;
    }
  }

  Future deleteUsuarioTodos() async {
    try{
      Util.printDebug('deleteUsuarioTodos');
      TratarErro.gravarLog('usuarios_helper.dart - deleteUsuarioTodos()', 'INFO');

      Database db = await DatabaseHelper.instance.database;
      await db.delete(usuariosTable);

    } on Exception catch (e) {
      TratarErro.gravarLog('usuarios_helper.dart: $e', 'ERRO');
      rethrow;
    }
  }

  Future deleteUsuario(Usuario usuario) async {
    try {
      Util.printDebug('deletetUsuario');
      TratarErro.gravarLog('usuarios_helper.dart - deleteUsuario()', 'INFO');

      Database db = await DatabaseHelper.instance.database;
      await db.delete(usuariosTable, where: "id = ?", whereArgs: [usuario.id]);

    } on Exception catch (e) {
      TratarErro.gravarLog('usuarios_helper.dart: $e', 'ERRO');
      rethrow;
    }
  }

  Future<int> upsertUsuario(Usuario usuario) async {
    try {

      TratarErro.gravarLog('usuarios_helper.dart - upsertUsuario()', 'INFO');

      //estava duplicando usuario agora apago e insiro novamente

      if(usuario.id! > 0) {
        try {
          TratarErro.gravarLog('usuarios_helper.dart - Deletando usuario antes de inserir um novo', 'INFO');
          await deleteUsuarioTodos();
        } on Exception catch (e) {
          TratarErro.gravarLog('usuarios_helper.dart: $e', 'ERRO');
        }
      }

      Util.printDebug('upsertUsuario');

      Database db = await DatabaseHelper.instance.database;
      var result = await db.insert(usuariosTable, usuario.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return result;

    } on Exception catch (e) {
      Sessao.idUsuario = 0;
      Sessao.loginUsuario = '';
      TratarErro.gravarLog('usuarios_helper.dart: $e', 'ERRO');
      rethrow;
    }
  }

  Future<int> updateUsuario(Usuario usuario) async {
    try {

      Util.printDebug('updateUsuario');
      TratarErro.gravarLog('usuarios_helper.dart - updateUsuario()', 'INFO');

      Database db = await DatabaseHelper.instance.database;
      var result = await db.update(usuariosTable, usuario.toMap(),
          where: "id = ?", whereArgs: [usuario.id]);
      return result;

    } on Exception catch (e) {
      TratarErro.gravarLog('usuarios_helper.dart: $e', 'ERRO');
      rethrow;
    }
  }

//#endregion
}