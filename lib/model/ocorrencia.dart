//#region Midias


import 'package:conecta_plus_app/util.dart';

const String ocorrenciasTable = 'ocorrencias';
const String ocorrenciasColId = 'id';
const String ocorrenciasColDataHora = 'data_hora';
const String ocorrenciasColIdUsuario = 'id_usuario';
const String ocorrenciasColIdUsuarioConecta = 'id_usuario_conecta';
const String ocorrenciasColOcorrencia = 'ocorrencia';
const String ocorrenciasColCaminhoArquivo = 'caminho_arquivo';
const String ocorrenciasColExtensao = 'extensao';
const String ocorrenciasColRecebida = 'recebida';
const String ocorrenciasColEnviado = 'enviado';
const String ocorrenciasColFinalizado = 'finalizado';

//#endregion

class Ocorrencia {
  final int? id;
  final String dataHora;
  final int idUsuario;
  final int? idUsuarioConecta;
  final String ocorrencia;
  final String caminhoArquivo;
  final String extensao;
  final int recebida;
  int enviado;
  int finalizado;

  get Enviado => enviado;
  set Enviado(n) => enviado = n;

  get Finalizado => finalizado;
  set Finalizado(n) => finalizado = n;

  Ocorrencia(
      {required this.id,
        required this.dataHora,
        required this.idUsuario,
        required this.idUsuarioConecta,
        required this.ocorrencia,
        required this.caminhoArquivo,
        required this.extensao,
        required this.recebida,
        required this.enviado,
        required this.finalizado
      });

  Ocorrencia.notId(
      {this.id,
        required this.dataHora,
        required this.idUsuario,
        required this.idUsuarioConecta,
        required this.ocorrencia,
        required this.caminhoArquivo,
        required this.extensao,
        required this.recebida,
        required this.enviado,
        required this.finalizado
      });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data_hora': dataHora,
      'id_usuario': idUsuario,
      'id_usuario_conecta': idUsuarioConecta,
      'ocorrencia': ocorrencia,
      'caminho_arquivo': caminhoArquivo,
      'extensao': extensao,
      'recebida': recebida,
      'enviado': enviado,
      'finalizado': finalizado,
    }..removeWhere(
            (dynamic key, dynamic value) => key == null || value == null);
  }

  factory Ocorrencia.fromMapObject(Map<String, dynamic> map) => Ocorrencia(
    id: int.tryParse(map['id'].toString())!,
    dataHora: map['data_hora'],
    idUsuario: int.tryParse(map['id_usuario'].toString())!,
    idUsuarioConecta: int.tryParse(map['id_usuario_conecta'].toString())!,
    ocorrencia: Util.stringNull(map['ocorrencia']),
    caminhoArquivo: Util.stringNull(map['caminho_arquivo']),
    extensao: Util.stringNull(map['extensao']),
    recebida: Util.intNull(map['recebida']),
    enviado: int.tryParse(map['enviado'].toString())!,
    finalizado: Util.intNull(map['finalizado']),
  );

  Map toJson() {
    return {
      'id': id,
      'data_hora': dataHora,
      'id_usuario': idUsuario,
      'id_usuario_conecta': idUsuarioConecta,
      'ocorrencia': ocorrencia,
      'caminho_arquivo': caminhoArquivo,
      'extensao': extensao,
      'recebida': recebida,
      'enviado': enviado,
      'finalizado': finalizado,
    };
  }
}
