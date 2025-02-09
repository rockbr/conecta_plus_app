//#region Log

const String logTable = 'log';
const String logColId = 'id';
const String logColDataHora = 'data_hora';
const String logColIdUsuario = 'id_usuario';
const String logColTipo = 'tipo';
const String logColMensagem = 'mensagem';

//#endregion

class Log {
  final int? id;
  final String dataHora;
  final int idUsuario;
  final String tipo;
  final String mensagem;


  Log(
      {required this.id,
        required this.dataHora,
        required this.idUsuario,
        required this.tipo,
        required this.mensagem
      });

  Log.notId({this.id,
    required this.dataHora,
    required this.idUsuario,
    required this.tipo,
    required this.mensagem
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data_hora': dataHora,
      'id_usuario': idUsuario,
      'tipo': tipo,
      'mensagem': mensagem,
    }..removeWhere(
            (dynamic key, dynamic value) => key == null || value == null);
  }

  factory Log.fromMapObject(Map<String, dynamic> map) => Log(
    id: int.tryParse(map['id'].toString())!,
    dataHora: map['data_hora'],
    idUsuario: int.tryParse(map['id_usuario'].toString())!,
    tipo: map['tipo'],
    mensagem: map['mensagem'],
  );

  Map toJson() {
    return {
      'id': id,
      'data_hora': dataHora,
      'id_usuario': idUsuario,
      'tipo': tipo,
      'mensagem': mensagem,
    };
  }

}
