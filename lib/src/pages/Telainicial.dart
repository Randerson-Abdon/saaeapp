import 'dart:convert';
import 'package:animated_card/animated_card.dart';
import 'package:saaenet/src/components/globals.dart';
import 'package:saaenet/src/pages/listaFaturaPage.dart';
import 'package:http/http.dart' as http;
import 'package:saaenet/src/components/cabecalho.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TelaInicial extends StatefulWidget {
  var _cpf;
  TelaInicial(cpf) {
    this._cpf = cpf;
  }

  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  var dados;
  String saae;

  int diffInDays(DateTime date1, DateTime date2) {
    return ((date1.difference(date2) -
                    Duration(hours: date1.hour) +
                    Duration(hours: date2.hour))
                .inHours /
            24)
        .round();
  }

  //comunicando com a api
  _listarDados(String cpf) async {
    cpf = widget._cpf;
    if (globalCidade == "Santa Izabel") {
      saae = "saaesantaizabel";
    }
    if (globalCidade == "Cametá") {
      saae = "saaecameta";
    }
    var response = await http.get(Uri.parse(
        'http://www.$saae.com.br/api/matriculas/listar.php?cpf=$cpf'));
    final map = json.decode(response.body);
    final itens = map["result"];

    setState(() {
      this.dados = itens;
    });
  }

  //executando listar dados
  @override
  void initState() {
    super.initState();
    _listarDados(widget._cpf);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fundoPages.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                //arredondamento de bordas
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    child: Cabecalho(),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                              ),
                              Text(
                                'Ativa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.red,
                              ),
                              Text(
                                'Inativa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white,
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Unidades consumidoras\n",
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: "vinculadas ao seu CPF",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            SizedBox(height: 20.0), //espaçamento
            Column(
              children: <Widget>[
                Container(
                  height: 230.0,
                  width: 400.0,
                  //TRAZENDO DADOS
                  child: ListView.builder(
                      itemCount: this.dados != null ? this.dados.length : 0,
                      itemBuilder: (context, i) {
                        final item = this.dados[i];
                        var icone;
                        if (item['status_ligacao'] == 'A') {
                          icone = Colors.green[800];
                        } else {
                          icone = Colors.red[800];
                        }

                        return AnimatedCard(
                          direction: AnimatedCardDirection.right,
                          child: Card(
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ListaFaturaPage(
                                            item['id_unidade_consumidora'])));
                              },
                              tileColor: Colors.blue,
                              leading:
                                  Image.asset('assets/images/matricula.png'),
                              title: Text(
                                item['id_unidade_consumidora'],
                                style: TextStyle(color: Color(0xFFFFFFFF)),
                              ),
                              subtitle: Text(
                                'NOME: ' + item['nome_razao_social'],
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF), fontSize: 12.5),
                              ),
                              trailing: Icon(
                                Icons.check_circle_rounded,
                                color: icone,
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
