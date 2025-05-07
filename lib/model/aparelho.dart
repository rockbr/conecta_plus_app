import 'package:conecta_plus_app/util.dart';

class Aparelho {
  final int? id;
  final int idUsuario;
  final String dataHora;
  final String serialAparelho;
  final String armazenamento;
  final String camera;
  final String conectividade;
  final String gps;
  final String plataforma;
  final String appTrackingTransparency;
  final String internet;
  final String site;
  final String versaoApp;
  final int versaoDatabase;
  final String informacoes;
  final String imei;
  final String telefone;
  int enviado;

  get Enviado => enviado;
  set Enviado(n) => enviado = n;

  Aparelho({
    required this.id,
    required this.idUsuario,
    required this.dataHora,
    required this.serialAparelho,
    required this.armazenamento,
    required this.camera,
    required this.conectividade,
    required this.gps,
    required this.plataforma,
    required this.appTrackingTransparency,
    required this.internet,
    required this.site,
    required this.versaoApp,
    required this.versaoDatabase,
    required this.informacoes,
    required this.imei,
    required this.telefone,
    required this.enviado,
  });

  Aparelho.notId({
    this.id,
    required this.idUsuario,
    required this.dataHora,
    required this.serialAparelho,
    required this.armazenamento,
    required this.camera,
    required this.conectividade,
    required this.gps,
    required this.plataforma,
    required this.appTrackingTransparency,
    required this.internet,
    required this.site,
    required this.versaoApp,
    required this.versaoDatabase,
    required this.informacoes,
    required this.imei,
    required this.telefone,
    required this.enviado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'data_hora': dataHora,
      'serial_aparelho': serialAparelho,
      'armazenamento': armazenamento,
      'camera': camera,
      'conectividade': conectividade,
      'gps': gps,
      'plataforma': plataforma,
      'app_tracking_transparency': appTrackingTransparency,
      'internet': internet,
      'site': site,
      'versao_app': versaoApp,
      'versao_database': versaoDatabase,
      'informacoes': informacoes,
      'imei': imei,
      'telefone': telefone,
      'enviado': enviado,
    }..removeWhere(
            (dynamic key, dynamic value) => key == null || value == null);
  }

  factory Aparelho.fromMapObject(Map<String, dynamic> map) => Aparelho(
    id: int.tryParse(map['id'].toString())!,
    idUsuario: map['id_usuario'],
    dataHora: map['data_hora'],
    serialAparelho: map['serial_aparelho'],
    armazenamento: map['armazenamento'],
    camera: map['camera'],
    conectividade: map['conectividade'],
    gps: map['gps'],
    plataforma: map['plataforma'],
    appTrackingTransparency: map['app_tracking_transparency'],
    internet: map['internet'],
    site: map['site'],
    versaoApp: map['versao_app'],
    versaoDatabase: map['versao_database'],
    informacoes: map['informacoes'],
    imei: Util.stringNull(map['imei']),
    telefone: Util.stringNull(map['telefone']),
    enviado: int.tryParse(map['enviado'].toString())!,
  );

  Map toJson() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'data_hora': dataHora,
      'serial_aparelho': serialAparelho,
      'armazenamento': armazenamento,
      'camera': camera,
      'conectividade': conectividade,
      'gps': gps,
      'plataforma': plataforma,
      'app_tracking_transparency': appTrackingTransparency,
      'internet': internet,
      'site': site,
      'versao_app': versaoApp,
      'versao_database': versaoDatabase,
      'informacoes': informacoes,
      'imei': imei,
      'telefone': telefone,
      'enviado': enviado,
    };
  }
}
