//#region Pontos

import 'package:conecta_plus_app/util.dart';

const String pontosTable = 'pontos';
const String pontosColId = 'id';
const String pontosColData = 'data';
const String pontosColDataHora = 'data_hora';
const String pontosColLatitude = 'latitude';
const String pontosColLongitude = 'longitude';
const String pontosColLogradouro = 'logradouro';
const String pontosColNumero = 'numero';
const String pontosColBairro = 'bairro';
const String pontosColCep = 'cep';
const String pontosColCidade = 'cidade';
const String pontosColIdPessoa = 'id_pessoa';
const String pontosColIdUsuario = 'id_usuario';
const String pontosColIdUsuarioConecta = 'id_usuario_conecta';
const String pontosColNomeCliente = 'nome_cliente';
const String pontosColEnviado = 'enviado';
const String pontosColFinalizado = 'finalizado';

//#endregion

class Ponto {
  final int? id;
  final String data;
  final String dataHora;
  final String? latitude;
  final String? longitude;
  final String? logradouro;
  final String? numero;
  final String? bairro;
  final String? cep;
  final String? cidade;
  final int idPessoa;
  final int idUsuario;
  final int idUsuarioConecta;
  final String nomeCliente;
  int enviado;
  int? finalizado;

  get Enviado => enviado;
  set Enviado(n) => enviado = n;

  get Finalizado => finalizado;
  set Finalizado(n) => finalizado = n;

  Ponto(
      {required this.id,
        required this.data,
        required this.dataHora,
        required this.latitude,
        required this.longitude,
        required this.logradouro,
        required this.numero,
        required this.bairro,
        required this.cep,
        required this.cidade,
        required this.idPessoa,
        required this.idUsuario,
        required this.idUsuarioConecta,
        required this.nomeCliente,
        required this.enviado,
        required this.finalizado});

  Ponto.naoEnviados(
      {required this.id,
        required this.data,
        required this.dataHora,
        this.latitude,
        this.longitude,
        this.logradouro,
        this.numero,
        this.bairro,
        this.cep,
        this.cidade,
        required this.idPessoa,
        required this.idUsuario,
        required this.idUsuarioConecta,
        required this.nomeCliente,
        required this.enviado,
        this.finalizado});

  Ponto.notId(
      {this.id,
        required this.data,
        required this.dataHora,
        required this.latitude,
        required this.longitude,
        required this.logradouro,
        required this.numero,
        required this.bairro,
        required this.cep,
        required this.cidade,
        required this.idPessoa,
        required this.idUsuario,
        required this.idUsuarioConecta,
        required this.nomeCliente,
        required this.enviado,
        required this.finalizado});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'data_hora': dataHora,
      'latitude': latitude,
      'longitude': longitude,
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'cep': cep,
      'cidade': cidade,
      'id_pessoa': idPessoa,
      'id_usuario': idUsuario,
      'id_usuario_conecta': idUsuarioConecta,
      'nome_cliente': nomeCliente,
      'enviado': enviado,
      'finalizado': finalizado,
    }..removeWhere(
            (dynamic key, dynamic value) => key == null || value == null);
  }

  factory Ponto.fromMapObjectNaoEnviados(Map<String, dynamic> map) => Ponto.naoEnviados(
    id: int.tryParse(map['id'].toString())!,
    data: map['data'],
    dataHora: map['data_hora'],
    idPessoa: int.tryParse(map['id_pessoa'].toString())!,
    idUsuario: int.tryParse(map['id_usuario'].toString())!,
    idUsuarioConecta: int.tryParse(map['id_usuario_conecta'].toString())!,
    nomeCliente: map['nome_cliente'].toString(),
    enviado: int.tryParse(map['enviado'].toString())!,
  );

  factory Ponto.fromMapObject(Map<String, dynamic> map) => Ponto(
    id: int.tryParse(map['id'].toString())!,
    data: map['data'],
    dataHora: map['data_hora'],
    latitude: map['latitude'],
    longitude: map['longitude'],
    logradouro: map['logradouro'],
    numero: map['numero'],
    bairro: map['bairro'],
    cep: map['cep'],
    cidade: map['cidade'],
    idPessoa: int.tryParse(map['id_pessoa'].toString())!,
    idUsuario: int.tryParse(map['id_usuario'].toString())!,
    idUsuarioConecta: int.tryParse(map['id_usuario_conecta'].toString())!,
    nomeCliente: map['nome_cliente'].toString(),
    enviado: int.tryParse(map['enviado'].toString())!,
    finalizado: Util.intNull(map['finalizado']),
  );

  Map toJson() {
    return {
      'id': id,
      'data': data,
      'data_hora': dataHora,
      'latitude': latitude,
      'longitude': longitude,
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'cep': cep,
      'cidade': cidade,
      'id_pessoa': idPessoa,
      'id_usuario': idUsuario,
      'id_usuario_conecta': idUsuarioConecta,
      'nome_cliente': nomeCliente,
      'enviado': enviado,
      'finalizado': finalizado,
    };
  }
}