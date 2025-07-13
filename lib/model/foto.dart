//#region Midias

import 'package:conecta_plus_app/util.dart';

const String fotosTable = 'fotos';
const String fotosColId = 'id';
const String fotosColDataHora = 'data_hora';
const String fotosColIdUsuario = 'id_usuario';
const String fotosColArquivo = 'arquivo';
const String fotosColEnviado = 'enviado';
const String fotosColFinalizado = 'finalizado';
const String fotosColFotoDeletada = 'foto_deletada';
const String fotosColIdUsuarioConecta = 'id_usuario_conecta';
const String fotosColTipo = 'tipo';
const String fotosColNomeCliente = 'nome_cliente';

//#endregion

class Foto {
  final int? id;
  final String dataHora;
  final int idUsuario;
  final String arquivo;
  final String nomeCliente;
  int enviado;
  int finalizado;
  int fotoDeletada;
  String tipo;

  get Tipo => tipo;
  set Tipo(n) => tipo = n;

  get Enviado => enviado;
  set Enviado(n) => enviado = n;

  get Finalizado => finalizado;
  set Finalizado(n) => finalizado = n;

  get FotoDeletada => fotoDeletada;
  set FotoDeletada(n) => fotoDeletada = n;

  Foto(
      {required this.id,
        required this.dataHora,
        required this.idUsuario,
        required this.arquivo,
        required this.nomeCliente,
        required this.enviado,
        required this.finalizado,
        required this.fotoDeletada,
        required this.tipo,
      });

  Foto.notId({this.id,
    required this.dataHora,
    required this.idUsuario,
    required this.arquivo,
    required this.nomeCliente,
    required this.enviado,
    required this.finalizado,
    required this.fotoDeletada,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data_hora': dataHora,
      'id_usuario': idUsuario,
      'arquivo': arquivo,
      'nome_cliente': nomeCliente,
      'enviado': enviado,
      'finalizado': finalizado,
      'foto_deletada': fotoDeletada,
      'tipo': tipo,
    }..removeWhere(
            (dynamic key, dynamic value) => key == null || value == null);
  }

  factory Foto.fromMapObject(Map<String, dynamic> map) => Foto(
    id: int.tryParse(map['id'].toString())!,
    dataHora: map['data_hora'],
    idUsuario: int.tryParse(map['id_usuario'].toString())!,
    arquivo: Util.stringNull(map['arquivo']),
    nomeCliente: Util.stringNull(map['nome_cliente']),
    enviado: int.tryParse(map['enviado'].toString())!,
    finalizado: Util.intNull(map['finalizado']),
    fotoDeletada: Util.intNull(map['foto_deletada']),
    tipo: Util.stringNull(map['tipo']),
  );

  Map toJson() {
    return {
      'id': id,
      'data_hora': dataHora,
      'id_usuario': idUsuario,
      'arquivo': arquivo,
      'nome_cliente': nomeCliente,
      'enviado': enviado,
      'finalizado': finalizado,
      'foto_deletada': fotoDeletada,
      'tipo': tipo,
    };
  }
}
