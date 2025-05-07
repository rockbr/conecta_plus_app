import 'package:conecta_plus_app/database/database_helper.dart';
import 'package:conecta_plus_app/model/pessoa.dart';
import 'package:conecta_plus_app/model/pessoa_ponto.dart';
import 'package:conecta_plus_app/model/ponto.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class PessoasHelper extends DatabaseHelper {

  static Future criarPessoas(Database db) async {
    try {
      Util.printDebug('criarPessoas');

      //#region Pessoas
      await db.execute('''
          CREATE TABLE IF NOT EXISTS $pessoasTable  (
          $pessoasColId INTEGER NOT NULL PRIMARY KEY UNIQUE,
          $pessoasColIdUsuarioConecta INTEGER NOT NULL,          
          $pessoasColNome TEXT NOT NULL
          
          )''');
      //#endregion
    } on Exception catch (e) {
      TratarErro.gravarLog('database_helper.dart $e', 'ERRO');
      rethrow;
    }
  }

  //#region Pessoas

  Future<List<PessoaPonto>> getPessoaPontoList() async {
    try {
      Util.printDebug('getPessoaPontoList');
      TratarErro.gravarLog('pessoas_helper.dart - getPessoaPontoList()', 'INFO');

      Database db = await DatabaseHelper.instance.database;

      var hoje = Util.convertData(DateTime.now()); // Ex: '2025-05-03'

      var result = await db.rawQuery('''
      SELECT 
        p.$pessoasColIdUsuarioConecta, 
        p.$pessoasColNome,
        GROUP_CONCAT(strftime('%H:%M', pt.$pontosColDataHora), ' - ') AS horarios_ponto
      FROM $pessoasTable p
      LEFT JOIN $pontosTable pt ON p.$pessoasColIdUsuarioConecta = pt.$pontosColIdUsuarioConecta
        AND pt.$pontosColData = ?
      GROUP BY p.$pessoasColIdUsuarioConecta, p.$pessoasColNome
      ORDER BY p.$pessoasColNome ASC
    ''', [hoje]);

      return result.map((map) {
        return PessoaPonto(
          idUsuarioConecta: map[pessoasColIdUsuarioConecta] is int
              ? map[pessoasColIdUsuarioConecta] as int
              : int.tryParse(map[pessoasColIdUsuarioConecta].toString()) ?? 0,
          nome: map[pessoasColNome]?.toString() ?? '',
          ponto: map['horarios_ponto']?.toString() ?? '',
        );
      }).toList();

    } on Exception catch (e) {
      TratarErro.gravarLog('pessoas_helper.dart: $e', 'ERRO');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPessoaMapList() async {
    try{
      Util.printDebug('getPessoaMapList');
      TratarErro.gravarLog('pessoas_helper.dart - getPessoaMapList()', 'INFO');

      Database db = await DatabaseHelper.instance.database;

      var result = await db.query(pessoasTable, orderBy: '$pessoasColId ASC');
      return result;
    } on Exception catch (e) {
      TratarErro.gravarLog('pessoas_helper.dart: $e', 'ERRO');
      rethrow;
    }
  }

  Future deletePessoaTodos() async {
    try{
      Util.printDebug('deletePessoaTodos');
      TratarErro.gravarLog('pessoas_helper.dart - deletePessoaTodos()', 'INFO');

      Database db = await DatabaseHelper.instance.database;
      await db.delete(pessoasTable);

    } on Exception catch (e) {
      TratarErro.gravarLog('pessoas_helper.dart: $e', 'ERRO');
      rethrow;
    }
  }

  Future deletePessoa(Pessoa pessoa) async {
    try {
      Util.printDebug('deletePessoa');
      TratarErro.gravarLog('pessoas_helper.dart - deletePessoa()', 'INFO');

      Database db = await DatabaseHelper.instance.database;
      await db.delete(pessoasTable, where: "id = ?", whereArgs: [pessoa.id]);

    } on Exception catch (e) {
      TratarErro.gravarLog('pessoas_helper.dart: $e', 'ERRO');
      rethrow;
    }
  }

  Future<int> upsertPessoa(Pessoa pessoa) async {
    try {

      TratarErro.gravarLog('pessoas_helper.dart - upsertPessoa()', 'INFO');

      //estava duplicando pessoas agora apago e insiro novamente

      if(pessoa.id! > 0) {
        try {
          TratarErro.gravarLog('pessoas_helper.dart - Deletando pessoa antes de inserir um novo', 'INFO');
          await deletePessoaTodos();
        } on Exception catch (e) {
          TratarErro.gravarLog('pessoas_helper.dart: $e', 'ERRO');
        }
      }

      Util.printDebug('upsertPessoa');

      Database db = await DatabaseHelper.instance.database;
      var result = await db.insert(pessoasTable, pessoa.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return result;

    } on Exception catch (e) {
      TratarErro.gravarLog('pessoas_helper.dart: $e', 'ERRO');
      rethrow;
    }
  }

  Future<int> updatePessoa(Pessoa pessoa) async {
    try {

      Util.printDebug('updatePessoa');
      TratarErro.gravarLog('pessoas_helper.dart - updatePessoa()', 'INFO');

      Database db = await DatabaseHelper.instance.database;
      var result = await db.update(pessoasTable, pessoa.toMap(),
          where: "id = ?", whereArgs: [pessoa.id]);
      return result;

    } on Exception catch (e) {
      TratarErro.gravarLog('pessoas_helper.dart: $e', 'ERRO');
      rethrow;
    }
  }

  Future<bool> insertListPessoa(List<Pessoa> listaPessoa) async {
    try {

      await deletePessoaTodos();

      Util.printDebug('insertListCliente');

      Database db = await DatabaseHelper.instance.database;

      for (var item in listaPessoa) {
        db.insert(pessoasTable, item.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      return true;
    } on Exception catch (e) {
      TratarErro.gravarLog('cliente_helper.dart $e', 'ERRO');
      return false;
    }
  }

//#endregion
}