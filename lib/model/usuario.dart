//#region Sessoes

import 'package:conecta_plus_app/util.dart';

const String usuariosTable = 'usuarios';
const String usuariosColId = 'id';
const String usuariosColNome = 'nome';
const String usuariosColLogin = 'login';
const String usuariosColBloqueado = 'bloqueado';
const String usuariosColIdEmpresa = 'id_empresa';
const String usuariosColDataNascimento = 'data_nascimento';

//#endregion

class Usuario {
  final int? id;
  final String? nome;
  final String? login;
  final int? bloqueado;
  final int? idEmpresa;
  final String? dataNascimento;

  Usuario(
      {required this.id,
        required this.nome,
        required this.login,
        required this.bloqueado,
        required this.idEmpresa,
        required this.dataNascimento,
      });

  Usuario.notId(
      {this.id,
        required this.nome,
        required this.login,
        required this.bloqueado,
        required this.idEmpresa,
        required this.dataNascimento
      });

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'login': login,
      'bloqueado': bloqueado,
      'id_empresa' : idEmpresa,
      'data_nascimento' : dataNascimento,
    }..removeWhere(
            (dynamic key, dynamic value) => key == null || value == null);
  }

  factory Usuario.fromMapObject(Map<String, dynamic> map) => Usuario(
    id: int.tryParse(map['id'].toString())!,
    nome: Util.stringNull(map['nome']),
    login: Util.stringNull(map['login']),
    bloqueado: int.tryParse(map['bloqueado'].toString())!,
    idEmpresa: Util.intNull(map['id_empresa']),
    dataNascimento: Util.stringNull(map['data_nascimento'])
  );

  factory Usuario.fromMapObjectApi(Map<String, dynamic> map) => Usuario(
    id: int.tryParse(map['id'].toString())!,
    nome: Util.stringNull(map['nome']),
    login: Util.stringNull(map['login']),
    bloqueado: Util.stringNull(map['bloqueado']) == "t" ? 1 : 0,
    idEmpresa: Util.intNull(map['id_empresa']),
    dataNascimento: Util.stringNull(map['data_nascimento'])
  );
}