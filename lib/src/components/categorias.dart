import 'dart:convert';
import 'package:saaenet/src/components/cardCategorias.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AreaCategorias extends StatefulWidget {
  @override
  _AreaCategoriasState createState() => _AreaCategoriasState();
}

class _AreaCategoriasState extends State<AreaCategorias> {
  var carregando = false;
  var dados;

  //comunicando com a api
  _listarDados() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.105/flutter/produtos/listarCategorias.php'));
    final map = json.decode(response.body);
    final itens = map["result"];

    setState(() {
      carregando = true;
      this.dados = itens;
    });
  }

  //executando listar dados
  @override
  void initState() {
    super.initState();
    _listarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      margin: EdgeInsets.only(top: 10.0),
      child: !carregando
          ? new LinearProgressIndicator()
          : new ListView.builder(
              //scroll na horizontal
              scrollDirection: Axis.horizontal,
              itemCount: this.dados != null ? this.dados.length : 0,
              itemBuilder: (context, i) {
                final item = this.dados[i];
                return CardCategoria(
                  nomeCat: item['nome'],
                  totalProd: item['produtos'],
                  imgCat: item['imagem'],
                );
              },
            ),
    );
  }
}
