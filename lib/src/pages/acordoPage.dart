import 'dart:convert';
import 'dart:ui';
import 'package:animated_card/animated_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:saaenet/src/components/globals.dart';
import 'package:saaenet/src/components/moeda.dart';
import 'package:saaenet/src/pages/finalizarAcordoPage.dart';
import 'package:http/http.dart' as http;
import 'package:saaenet/src/shared/themes/app_text_styles.dart';

// ignore: must_be_immutable
class AcordoPage extends StatefulWidget {
  var _matricula;
  AcordoPage(matricula) {
    this._matricula = matricula;
  }

  @override
  _AcordoPageState createState() => _AcordoPageState();
}

class _AcordoPageState extends State<AcordoPage> {
  var dados;
  var dadosAcordo;
  String saae;
  double total = 0.0;
  var entrada;
  List valorParcelas = ['Carregando'];
  List dataVencimento = [];
  var focusNode = FocusNode();
  List fatura = [];

  //VARIAVEIS PARA CONTROLLER DE VALIDAÇÃO
  var nAcordoTxt = new TextEditingController();
  var parcelaTxt;
  final MoneyMaskedTextController entradaTxt = MoneyMaskedTextController(
      thousandSeparator: '.', decimalSeparator: ',', leftSymbol: 'R\$ ');

  //gera lista automaticamente
  var _parcela = List<int>.generate(12, (i) => i + 01);
  var _itemSelecionado = '1';

  //comunicando com a api
  listarDados(String matricula) async {
    matricula = widget._matricula;
    if (globalCidade == "Santa Izabel") {
      saae = "saaesantaizabel";
    }
    if (globalCidade == "Cametá") {
      saae = "saaecameta";
    }
    var response = await http.get(Uri.parse(
        'http://www.$saae.com.br/api/matriculas/listaFaturasVencidas.php?matricula=$matricula'));
    //print(response.body);
    final map = json.decode(response.body);
    final itens = map["result"];

    setState(() {
      this.dados = itens;
      for (var value in dados) {
        total += double.parse(value['TOTALII']);
        fatura.add(value['COMPETENCIAII']);
      }
    });
  }

  idAcordo() async {
    if (globalCidade == "Santa Izabel") {
      saae = "saaesantaizabel";
    }
    if (globalCidade == "Cametá") {
      saae = "saaecameta";
    }
    var response = await http.get(
        Uri.parse('http://www.$saae.com.br/api/matriculas/numeroAcordo.php'));
    //print(response.body);
    final map = json.decode(response.body);
    final itens = map["result"];

    setState(() {
      this.dadosAcordo = itens;
      //print(dadosAcordo);
    });
  }

  //executando listar dados
  @override
  void initState() {
    super.initState();
    listarDados(widget._matricula);
    idAcordo();
  }

  //calcula parcelas
  double calculaParcelas(double vTotal, double vEntrada, double nParcelamento) {
    double valorEntrada = vTotal - vEntrada;
    double valor =
        double.parse((valorEntrada / nParcelamento).toStringAsFixed(2));

    return double.parse(valor.toStringAsFixed(2));
  }

  void preparaValorparcelas() {
    for (var i = 1; i <= num.parse(parcelaTxt); i++) {
      if (i == num.parse(parcelaTxt)) {
        final m1 = calculaParcelas(total, currencyToDouble(entradaTxt.text),
                double.parse(parcelaTxt)) *
            num.parse(parcelaTxt);
        final m2 = m1 - total + currencyToDouble(entradaTxt.text);
        valorParcelas.add((calculaParcelas(
                    total,
                    currencyToDouble(entradaTxt.text),
                    double.parse(parcelaTxt)) -
                m2)
            .toStringAsFixed(2));
      } else {
        valorParcelas.add(calculaParcelas(total,
                currencyToDouble(entradaTxt.text), double.parse(parcelaTxt))
            .toStringAsFixed(2));
      }
    }
  }

  //select cidade
  Widget _nParcela() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Número de Parcelas: ',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          DropdownButton<String>(
            autofocus: true,
            items: _parcela.map((int dropDownStringItem) {
              return DropdownMenuItem<String>(
                value: dropDownStringItem.toString(),
                child: Text(
                  dropDownStringItem.toString(),
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            onChanged: (String novoItemSelecionado) {
              _dropDownItemSelected(novoItemSelecionado);
              setState(() {
                this._itemSelecionado = novoItemSelecionado;
              });
            },
            value: _itemSelecionado,
          ),
        ],
      ),
    );
  }

  void _dropDownItemSelected(String novoItem) {
    setState(() {
      this._itemSelecionado = novoItem;
      parcelaTxt = _itemSelecionado;
      valorParcelas.clear();
      if (currencyToDouble(entradaTxt.text) == 0.0) {
        focusNode.requestFocus();
      } else {
        preparaValorparcelas();
      }
    });
  }

  //campo entrada
  Widget _entrada() {
    return TextFormField(
      autofocus: true,
      focusNode: focusNode,
      cursorColor: Colors.white,
      controller: entradaTxt,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        enabled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        suffixIcon: Icon(
          Icons.monetization_on_outlined,
          color: Colors.white,
        ),
        labelText: 'Valor Entrada',
        labelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
      ),
      style: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uc = widget._matricula;

    void mensagemAcordo() {
      var alert = new AlertDialog(
        title: new Text('SaaeNet diz:'),
        content: new Text(
          'Você deve gerar seu parcelamento antes de continuar!!!',
          textAlign: TextAlign.justify,
        ),
        actions: <Widget>[
          new ElevatedButton(
            child: new Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
      showDialog(context: context, builder: (_) => alert);
    }

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
                    child: Row(
                      children: [
                        BackButton(
                          color: Colors.white,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'PARCELAMENTO DE DÉBITOS',
                            style: TextStyles.titleRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Faturas Vencidas",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white,
                        ),
                        Text(
                          "Matrícula $uc",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  //arredondamento de bordas
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding:
                    EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 20),
                child: Column(
                  children: [
                    Text(
                      "Acordo N° ${dadosAcordo == null ? 'Carregando..' : dadosAcordo}",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 10.0),
                    _entrada(),
                    SizedBox(height: 10.0),
                    _nParcela(),
                  ],
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  height: 330.0,
                  width: 400.0,
                  //TRAZENDO DADOS
                  child: ListView.builder(
                      itemCount: valorParcelas != [] ? valorParcelas.length : 0,
                      itemBuilder: (context, i) {
                        final item = valorParcelas[i];

                        if (valorParcelas[0] == 'Carregando') {
                          return Container(
                            height: 0,
                            width: 0,
                          );
                        } else {
                          var date = DateTime.now();
                          var newDate = DateTime(
                              date.year, date.month + (i + 1), date.day);

                          return AnimatedCard(
                            direction: AnimatedCardDirection.right,
                            child: Card(
                              child: ListTile(
                                onTap: () {},
                                tileColor: Colors.blue,
                                leading: Text(
                                  'N°: ' + (i + 1).toString(),
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.white),
                                ),
                                title: Text(
                                  'R\$ ' + item.toString().replaceAll('.', ','),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                ),
                                trailing: Text(
                                  DateFormat("'Vencimento:' dd/MM/yyyy")
                                      .format(newDate),
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          // color: Layout.secondary()
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
        ),
        height: 60,
        child: Row(children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width / 2,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    print(dataVencimento);
                    /* setState(() {
                      preparaValorparcelas();
                    }); */
                  },
                  child: Column(children: <Widget>[
                    Text('Gerar', style: TextStyle(color: Colors.white)),
                    Text('Parcelas', style: TextStyle(color: Colors.white)),
                  ]),
                ),
                Container(
                  height: 80.0,
                  width: 1,
                  color: Colors.white,
                ),
                GestureDetector(
                  onTap: () {
                    print(valorParcelas);

                    if (valorParcelas[0] == 'Carregando') {
                      mensagemAcordo();
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              FinalizarAcordoPage(
                                  uc,
                                  total.toStringAsFixed(2),
                                  entradaTxt.text,
                                  dadosAcordo,
                                  parcelaTxt,
                                  valorParcelas,
                                  fatura)));
                    }
                  },
                  child: Column(children: <Widget>[
                    Text('Continuar', style: TextStyle(color: Colors.white)),
                    Text('Acordo', style: TextStyle(color: Colors.white)),
                  ]),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.black12,
            width: MediaQuery.of(context).size.width / 2,
            padding: EdgeInsets.only(left: 10, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Total: ' + doubleToCurrency(total),
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(
                    "Parcelas: ${parcelaTxt == null ? 'Aguardando' : '1 + ' + parcelaTxt}",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))
              ],
            ),
          )
        ]),
      ),
    );
  }
}
