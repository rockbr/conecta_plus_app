import 'package:conecta_plus_app/sessao.dart';
import 'package:conecta_plus_app/size_config.dart';
import 'package:conecta_plus_app/util.dart';
import 'package:flutter/material.dart';

class Rodape extends StatefulWidget {
  const Rodape({super.key});

  @override
  _RodapeState createState() => _RodapeState();
}

class _RodapeState extends State<Rodape> {
  String _now = '';

  @override
  void initState() {
    super.initState();
    _now = Util.timeToStringCompleto(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Visibility(
                        visible: Sessao.nomeUsuario.isNotEmpty,
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text("Usuário: ${Sessao.nomeUsuario}",
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      fontSize: SizeConfig.of(context)
                                          .dynamicScaleSize(
                                          size: 15,
                                          scaleFactorTablet: 1,
                                          scaleFactorMini: 0),
                                      color: Colors.white)),
                            ))),
                  ],
                )
              ],
            )),
        Container(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Column(
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child:
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Centraliza o conteúdo horizontalmente
                      children: [
                        Text(
                          'Versão: ${Util.version()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.of(context).dynamicScaleSize(
                              size: 15,
                              scaleFactorTablet: 1,
                              scaleFactorMini: 0,
                            ),
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ' | ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.of(context).dynamicScaleSize(
                              size: 15,
                              scaleFactorTablet: 1,
                              scaleFactorMini: 0,
                            ),
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "${Util.convertDateFromString(DateTime.now().toString())} $_now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.of(context).dynamicScaleSize(
                              size: 15,
                              scaleFactorTablet: 1,
                              scaleFactorMini: 0,
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        )
      ],
    );
  }
}