import 'package:conecta_plus_app/database/database_upgrade.dart';
import 'package:conecta_plus_app/database/fotos_helper.dart';
import 'package:conecta_plus_app/database/log_helper.dart';
import 'package:conecta_plus_app/database/pessoas_helper.dart';
import 'package:conecta_plus_app/database/ponto_helper.dart';
import 'package:conecta_plus_app/database/usuarios_helper.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';


class DatabaseHelper {
  static final _databaseName = Util.databaseName;
  static final _databaseVersion = Util.databaseVersion;

  DatabaseHelper();

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;

  Future<Database> get database async {

    if (_database != null) {
      Util.printDebug('Retornando_database');
      return _database!;
    }

    Util.printDebug('Inicializando _database');
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      Util.printDebug('_initDatabase');

      return await open();
    } on Exception catch (e) {
      TratarErro.gravarLog('database_helper.dart $e', 'ERRO');
      rethrow;
    }
  }


  open() async {
    Util.printDebug('open');

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  close() async {
    Util.printDebug('close');

    _database!.close();
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      Util.printDebug('<-- _onUpgrade: newVersion $newVersion - oldVersion $oldVersion');

      DatabaseUpgrade databaseUpgrade = DatabaseUpgrade();

      for (var version = oldVersion + 1; version <= newVersion; version++) {
        await databaseUpgrade.upgradeToVersion(db, version);
      }

      Util.printDebug('_onUpgrade: newVersion $newVersion - oldVersion $oldVersion -->');
    } on Exception catch (e) {
      TratarErro.gravarLog('database_helper.dart $e', 'ERRO');
    }
  }

  Future _onCreate(Database db, int version) async {
    try {

      Util.printDebug('<-- _onCreate');

      LogHelper.criarLog(db);
      UsuariosHelper.criarUsuarios(db);
      PessoasHelper.criarPessoas(db);
      FotosHelper.criarFotos(db);
      PontoHelper.criarPontos(db);

      Util.printDebug('_onCreate -->');
    } on Exception catch (e) {
      TratarErro.gravarLog('database_helper.dart $e', 'ERRO');
      rethrow;
    }
  }

  Future altenaNome() async {
    Util.printDebug('<-- altenaNome');

    String data = Util.dataHoraLog;

    Database db = await instance.database;


    await _onCreate(db, _databaseVersion);

    Util.printDebug('altenaNome -->');
  }

  Future recriarTabelas() async {
    try {
      Util.printDebug('<-- recriarTabelas');

      Database db = await instance.database;

      LogHelper.criarLog(db);
      UsuariosHelper.criarUsuarios(db);

      await DatabaseUpgrade().versaoTodos(db, false);

      Util.printDebug('recriarTabelas -->');

    } on Exception catch (e) {
      TratarErro.gravarLog('database_helper.dart $e', 'ERRO');
      rethrow;
    }
  }

  Future dropTable() async {
    Database db = await instance.database;

    await _initDatabase();
  }

}
