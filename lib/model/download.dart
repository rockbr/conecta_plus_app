//#region Download

import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/util.dart';

const String downloadTable = 'download';
const String downloadColId = 'id';
const String downloadColDataHora = 'data_hora';
const String downloadColDescricao = 'descricao';
const String downloadColLink = 'link';
const String downloadColIdUsuario = 'id_usuario';
const String downloadColIdUsuarioConecta = 'id_usuario_conecta';

//#endregion

class Download {
  final int? id;
  final String dataHora;
  final String descricao;
  final String link;
  final int idUsuario;
  final int? idUsuarioConecta;

  Download(
      {required this.id,
        required this.dataHora,
        required this.descricao,
        required this.link,
        required this.idUsuario,
        required this.idUsuarioConecta});
  Download.notId(
      {this.id,
        required this.dataHora,
        required this.descricao,
        required this.link,
        required this.idUsuario,
        required this.idUsuarioConecta});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data_hora': dataHora,
      'descricao': descricao,
      'link': link,
      'id_usuario': idUsuario,
      'id_usuario_conecta': idUsuarioConecta,
    }..removeWhere(
            (dynamic key, dynamic value) => key == null || value == null);
  }

  factory Download.fromMapObject(Map<String, dynamic> map) => Download(
    id: Util.intNull(map['id']),
    dataHora: Util.stringNull(map['data_hora']),
    descricao: Util.stringNull(map['descricao']),
    link: map['link'],
    idUsuario: Util.intNull(map['id_usuario']) == 0
        ? Sessao.idUsuario
        : Util.intNull(map['id_usuario']),
    idUsuarioConecta: Util.intNull(map['id_usuario_conecta']),
  );

  Map toJson() {
    return {
      'id': id,
      'data_hora': dataHora,
      'descricao': descricao,
      'link': link,
      'id_usuario': idUsuario,
      'id_usuario_conecta': idUsuarioConecta,
    };
  }
}
