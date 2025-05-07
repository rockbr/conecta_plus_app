import 'package:conecta_plus_app/database/fotos_helper.dart';
import 'package:conecta_plus_app/database/pessoas_helper.dart';
import 'package:conecta_plus_app/database/ponto_helper.dart';
import 'package:conecta_plus_app/model/pessoa_ponto.dart';
import 'package:conecta_plus_app/model/ponto.dart';
import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/simple_clock.dart';
import 'package:conecta_plus_app/tratar_erro.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:conecta_plus_app/widget/principal.dart';
import 'package:flutter/material.dart';

class RelogioPonto extends StatefulWidget {
  const RelogioPonto({super.key});

  @override
  _RelogioPontoState createState() => _RelogioPontoState();
}

class _RelogioPontoState extends State<RelogioPonto> {
  List<Ponto> pontosSalvos = [];
  final String title = Util.appNome;
  final fotoHelper = FotosHelper();
  final pontoHelper = PontoHelper();
  final pessoasHelper = PessoasHelper(); // Certifique-se de ter isso

  List<PessoaPonto> pessoasPonto = [];
  List<PessoaPonto> selecionados = [];
  bool todosSelecionados = false;

  @override
  void initState() {
    super.initState();
    carregarPessoasComPonto();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: AppBar(title: Text('Relógio de Ponto')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                // Título
                Text("Ponto", textScaleFactor: 2),
                const SizedBox(height: 10),
                const SimpleClock(),
                const SizedBox(height: 20),

                // Botão para selecionar/deselecionar todos
                Container(
                  width: double.infinity, // Faz o container ocupar toda a largura
                  color: Colors.blue, // Cor de fundo azul
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Ajusta o padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinha o texto e o botão com espaço entre eles
                    children: [
                      Text(
                        "Selecione os presentes:",
                        style: TextStyle(
                          fontSize: 18, // Aumenta o tamanho da fonte
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Texto branco para contraste
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              todosSelecionados = !todosSelecionados;
                              if (todosSelecionados) {
                                selecionados = List.from(pessoasPonto);
                              } else {
                                selecionados.clear();
                              }
                            });
                          },
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              todosSelecionados ? Icons.check_box : Icons.check_box_outline_blank,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          label: const Text(""),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de pessoas com ponto
                Column(
                  children: pessoasPonto.map((pessoa) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(pessoa.nome),
                                value: selecionados.any((s) => s.idUsuarioConecta == pessoa.idUsuarioConecta),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value ?? false) {
                                      if (!selecionados.any((s) => s.idUsuarioConecta == pessoa.idUsuarioConecta)) {
                                        selecionados.add(pessoa);
                                      }
                                    } else {
                                      selecionados.removeWhere((s) => s.idUsuarioConecta == pessoa.idUsuarioConecta);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0), // Menor espaçamento
                          child: Text(pessoa.ponto, // Horário do ponto dinâmico
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.indigo, // Cor suave para o subtítulo
                            ),
                          ),
                        ),
                        const Divider(height: 0), // Linha de separação
                      ],
                    );
                  }).toList(),
                ),

                // Botão para registrar ponto
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => validarBotaoSalvar(context),
                        child: Text('Registrar Ponto',
                          textScaleFactor: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      TratarErro.gravarLog('relogio_ponto.dart: $e', 'ERRO');
      rethrow;
    }
  }

  Future<void> carregarPessoasComPonto() async {
    try {
      final lista = await pessoasHelper.getPessoaPontoList();
      setState(() {
        pessoasPonto = lista;
      });
    } catch (e) {
      TratarErro.gravarLog('Erro ao carregar pessoas com ponto: $e', 'ERRO');
    }
  }

  void validarBotaoSalvar(BuildContext context) {
    if (selecionados.isEmpty) {
      Util.snackBar("Selecione pelo menos uma pessoa.", context: context);
      return;
    }

    Util.circularProgressIndicator(context, "Salvando");
    _salvarPonto(selecionados, context);
  }

  Future<void> _salvarPonto(List<PessoaPonto> pessoasSelecionados, BuildContext context) async {
    try {
      DateTime agora = DateTime.now();

      for (var item in pessoasSelecionados) {
        Ponto ponto = Ponto.notId(
          data: Util.convertData(agora),
          dataHora: agora.toString(),
          latitude: Sessao.latitude,
          longitude: Sessao.longitude,
          logradouro: Sessao.thoroughfare,
          numero: Sessao.subThoroughfare,
          bairro: Sessao.subLocality,
          cep: Sessao.postalCode,
          cidade: Sessao.subAdministrativeArea,
          idUsuario: Sessao.idUsuario,
          idUsuarioConecta: item.idUsuarioConecta,
          enviado: 0,
          finalizado: 0,
        );

        pontosSalvos.add(ponto);
      }

      await pontoHelper.insertListPonto(pontosSalvos);

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Principal()));
    } catch (e) {
      TratarErro.gravarLog('relogio_ponto.dart: $e', 'ERRO');
    }
  }
}