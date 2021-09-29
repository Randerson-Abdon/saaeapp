import 'package:flutter/material.dart';

class Buscar extends StatefulWidget {
  @override
  _BuscarState createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  var txtbuscar = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      //elevation: 5.0,

      child: TextFormField(
        controller: txtbuscar,
        style: TextStyle(color: Colors.black, fontSize: 16.0),
        cursorColor: Colors.blue,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 32.0, vertical: 14.0),
          suffixIcon: Material(
            //elevation: 5.0,
            child: Icon(
              Icons.search,
              color: Colors.black,
            ),
          ),
          //border: InputBorder.none, //borda parte inferior
          hintText: 'Buscar Fatura',
        ),
      ),
    );
  }
}
