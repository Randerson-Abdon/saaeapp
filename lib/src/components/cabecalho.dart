import 'package:flutter/material.dart';

class Cabecalho extends StatefulWidget {
  @override
  _CabecalhoState createState() => _CabecalhoState();
}

class _CabecalhoState extends State<Cabecalho> {
  //formatação para style de texto
  final textoTitulo = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  final textoSubtitulo = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w300,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      //abre o maximo de espaço possivel entre os componentes
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            Center(
              child: Text(
                'BEM VINDO AO SAAENET MOBILE',
                style: textoTitulo,
              ),
            ),
            SizedBox(height: 10.0)
          ],
        ),
      ],
    );
  }
}
