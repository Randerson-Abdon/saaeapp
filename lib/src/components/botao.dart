import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String btnText;
  final VoidCallback onPressed;

  Button({this.btnText, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          //onde unicia
          begin: Alignment.topLeft,
          //onde termina
          end: Alignment.bottomRight,
          //onde inicia as cores do gradiente e ate onde vai
          stops: [0.3, 1],
          colors: [
            Color(0xFFF58524),
            Color(0xFFF92B7F),
          ],
        ),
        //arredondamento de bordas
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      //colocando botão dentro do container de forma expandida
      child: SizedBox.expand(
        child: ElevatedButton(
          style: ButtonStyle(
            //fundo transparente
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.transparent,
            ),
          ),
          onPressed: onPressed,
          child: Text(
            '$btnText',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
