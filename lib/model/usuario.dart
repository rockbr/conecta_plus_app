//#region Sessoes

import 'package:conecta_plus_app/util.dart';

const String usuariosTable = 'usuarios';
const String usuariosColId = 'id';
const String usuariosColNome = 'nome';
const String usuariosColLogin = 'login';
const String usuariosColBloqueado = 'bloqueado';
const String usuariosColIdEmpresa = 'id_empresa';
const String usuariosColIdPessoa = 'id_pessoa';
const String usuariosColIdPessoaConecta = 'id_pessoa_conecta';
const String usuariosColDataNascimento = 'data_nascimento';
const String usuariosColUltimaPonto = 'ultima_ponto';
const String usuariosColUltimaFoto = 'ultima_foto';

//#endregion

class Usuario {
  final int? id;
  final String? nome;
  final String? login;
  final int? bloqueado;
  final int? idEmpresa;
  final int? idPessoa;
  final int? idPessoaConecta;
  final String? dataNascimento;
  final String? ultimaPonto;
  final String? ultimaFoto;

  Usuario(
      {required this.id,
        required this.nome,
        required this.login,
        required this.bloqueado,
        required this.idEmpresa,
        required this.idPessoa,
        required this.idPessoaConecta,
        required this.dataNascimento,
        required this.ultimaPonto,
        required this.ultimaFoto,
      });

  Usuario.withUltimaPonto({
    this.nome,
    this.login,
    this.bloqueado,
    this.idEmpresa,
    this.idPessoa,
    this.idPessoaConecta,
    this.dataNascimento,
    this.ultimaFoto,
    required this.id,
    required this.ultimaPonto});

  Usuario.withUltimaFoto({
    this.nome,
    this.login,
    this.bloqueado,
    this.idEmpresa,
    this.idPessoa,
    this.idPessoaConecta,
    this.dataNascimento,
    this.ultimaPonto,
    required this.id,
    required this.ultimaFoto});

  Usuario.notId(
      {this.id,
        required this.nome,
        required this.login,
        required this.bloqueado,
        required this.idEmpresa,
        required this.idPessoa,
        required this.idPessoaConecta,
        required this.dataNascimento,
        required this.ultimaPonto,
        required this.ultimaFoto,
      });

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'login': login,
      'bloqueado': bloqueado,
      'id_empresa' : idEmpresa,
      'id_pessoa' : idPessoa,
      'id_pessoa_conecta' : idPessoaConecta,
      'data_nascimento' : dataNascimento,
      'ultima_ponto': ultimaPonto,
      'ultima_foto': ultimaFoto,
    }..removeWhere(
            (dynamic key, dynamic value) => key == null || value == null);
  }

  factory Usuario.fromMapObject(Map<String, dynamic> map) => Usuario(
    id: int.tryParse(map['id'].toString())!,
    nome: Util.stringNull(map['nome']),
    login: Util.stringNull(map['login']),
    bloqueado: int.tryParse(map['bloqueado'].toString())!,
    idEmpresa: Util.intNull(map['id_empresa']),
    idPessoa: Util.intNull(map['id_pessoa']),
    idPessoaConecta: Util.intNull(map['id_pessoa_conecta']),
    dataNascimento: Util.stringNull(map['data_nascimento']),
    ultimaPonto: Util.stringNull(map['ultima_ponto']),
    ultimaFoto: Util.stringNull(map['ultima_foto']),
  );

  factory Usuario.fromMapObjectApi(Map<String, dynamic> map) => Usuario(
    id: int.tryParse(map['id'].toString())!,
    nome: Util.stringNull(map['nome']),
    login: Util.stringNull(map['login']),
    bloqueado: Util.stringNull(map['bloqueado']) == "t" ? 1 : 0,
    idEmpresa: Util.intNull(map['id_empresa']),
    idPessoa: Util.intNull(map['id_pessoa']),
    idPessoaConecta: Util.intNull(map['id_pessoa_conecta']),
    dataNascimento: Util.stringNull(map['data_nascimento']),
    ultimaPonto: Util.stringNull(map['ultima_ponto']),
    ultimaFoto: Util.stringNull(map['ultima_foto']),
  );
}