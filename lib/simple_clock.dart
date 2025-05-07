import 'dart:async';
import 'package:conecta_plus_app/util.dart';
import 'package:flutter/material.dart';

class SimpleClock extends StatefulWidget {
  const SimpleClock({super.key});

  @override
  _SimpleClockState createState() => _SimpleClockState();
}

class _SimpleClockState extends State<SimpleClock> {
  String _now = '';

  @override
  void initState() {
    super.initState();
    _now = Util.timeToStringCompleto(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      setState(() {
        _now = Util.timeToStringCompleto(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _now,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 48,
            fontFamily: "Helvetica",
          ),
        ),
        Text(Util.convertDateFromString(DateTime.now().toString()),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: "Helvetica",
            )),
      ],
    );
  }
}