import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CardMatriculas extends StatefulWidget {
  //variaves vindas de outras telas
  var _cpf;
  CardMatriculas(cpf) {
    this._cpf = cpf;
  }

  @override
  _CardMatriculasState createState() => _CardMatriculasState();
}

class _CardMatriculasState extends State<CardMatriculas> {
  var dados;
  var cpfuser;
  var carregando = false;

  @override
  Widget build(BuildContext context) {
    //variaves vindas de outras telas
    cpfuser = widget._cpf;

    //comunicando com a api
    _listarDados(String cpf) async {
      cpf = cpfuser;
      var response = await http.get(Uri.parse(
          'http://www.saaesantaizabel.com.br/api/matriculas/listar.php?cpf=$cpf'));
      final map = json.decode(response.body);
      final itens = map["result"];

      setState(() {
        carregando = true;
        this.dados = itens;
      });
    }

    //executando listar dados
    @override
    // ignore: unused_element
    Future<void> initState() async {
      super.initState();
      _listarDados(cpfuser);
    }

    return ClipRRect(
      //elemento retangulo
      borderRadius: BorderRadius.all(
        //com borda arredondada
        Radius.circular(10.0),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            height: 230.0,
            width: 340.0,
            //TRAZENDO DADOS
            child: new ListView.builder(
              itemCount: this.dados != null ? this.dados.length : 0,
              itemBuilder: (context, i) {
                final item = this.dados[i];
                return new Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        //posicionamentos
                        left: 0.0,
                        bottom: 0.0,
                        width: 340.0,
                        height: 60.0,
                        child: Container(
                          //area de baixo
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black, Colors.black12])),
                        ),
                      ),
                      Positioned(
                        left: 10.0,
                        bottom: 10.0,
                        right: 10.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item['id_unidade_consumidora'],
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.star,
                                      color: Theme.of(context).primaryColor,
                                      size: 16.0,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Theme.of(context).primaryColor,
                                      size: 16.0,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Theme.of(context).primaryColor,
                                      size: 16.0,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Theme.of(context).primaryColor,
                                      size: 16.0,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Theme.of(context).primaryColor,
                                      size: 16.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      "Avaliação 5",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  'Competências',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent),
                                ),
                                Text("Add",
                                    style: TextStyle(color: Colors.grey))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
