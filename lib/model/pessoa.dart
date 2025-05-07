//#region Sessoes

import 'package:conecta_plus_app/util.dart';

const String pessoasTable = 'pessoas';
const String pessoasColId = 'id';
const String pessoasColIdUsuarioConecta = 'id_usuario_conecta';
const String pessoasColNome = 'nome';

//#endregion

class Pessoa {
  final int? id;
  final int? idUsuarioConecta;
  final String? nome;

  Pessoa(
      {required this.id,
        required this.idUsuarioConecta,
        required this.nome,
      });

  Pessoa.notId(
      {this.id,
        required this.idUsuarioConecta,
        required this.nome,
      });

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_usuario_conecta': idUsuarioConecta,
      'nome': nome,
    }..removeWhere(
            (dynamic key, dynamic value) => key == null || value == null);
  }

  factory Pessoa.fromMapObject(Map<String, dynamic> map) => Pessoa(
    id: int.tryParse(map['id'].toString())!,
    idUsuarioConecta: int.tryParse(map['id_usuario_conecta'].toString())!,
    nome: Util.stringNull(map['nome']),
  );

  factory Pessoa.fromMapObjectApi(Map<String, dynamic> map) => Pessoa(
    id: int.tryParse(map['id'].toString())!,
    idUsuarioConecta: int.tryParse(map['id_usuario_conecta'].toString())!,
    nome: Util.stringNull(map['nome']),
  );
}