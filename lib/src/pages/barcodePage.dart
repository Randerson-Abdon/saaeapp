import 'package:saaenet/src/components/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class BarcodePage extends StatefulWidget {
  var _competencia, _uc, _mesfaturado, _idlocalidade, _vencimento, _valor;
  BarcodePage(competencia, uc, mesfaturado, idlocalidade, vencimento, valor) {
    this._competencia = competencia;
    this._uc = uc;
    this._mesfaturado = mesfaturado;
    this._idlocalidade = idlocalidade;
    this._vencimento = vencimento;
    this._valor = valor;
  }

  @override
  _BarcodePageState createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  /* ProgressBarHandler _handler; */
  var dados;
  String saae;

  //comunicando com a api exibe codigo de barras
  listarDados(String matricula, String mesfaturado, String vencimento,
      String idlocalidade) async {
    matricula = widget._uc;
    mesfaturado = widget._mesfaturado;
    vencimento = widget._vencimento;
    idlocalidade = widget._idlocalidade;
    if (globalCidade == "Santa Izabel") {
      saae = "saaesantaizabel";
    }
    if (globalCidade == "Cametá") {
      saae = "saaecameta";
    }

    var response = await http.get(
        Uri.parse(Uri.encodeFull(
            "http://www.$saae.com.br/api/barcode.php?uc=$matricula&mesfaturado=$mesfaturado&vencimento=$vencimento&idlocalidade=$idlocalidade")),
        headers: {"Accept": "application/json"});

    //print(response.body);
    var obj = response.body.toString();

    setState(() {
      this.dados = obj.substring(20, 75);
    });
  }

  //executando listar dados
  @override
  void initState() {
    super.initState();
    listarDados(widget._uc, widget._mesfaturado, widget._vencimento,
        widget._idlocalidade);
  }

  @override
  Widget build(BuildContext context) {
    var competencia = widget._competencia;
    var vencimento = widget._vencimento;
    var valor = widget._valor;

    if (dados == null) {
      dados = "Carregando...";
    }

    var dataFatura = competencia.split("/");
    var dataVencimento = vencimento.split("-");
    var dataValor = valor.replaceAll('.', ',');

    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text("Dados da Fatura"),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: Column(
              children: [
                SizedBox(height: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, right: 15.0, left: 15.0),
                      child: Text(
                        "Competência: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, right: 15.0, left: 15.0),
                      child: Text(
                        dataFatura[1] + "/" + dataFatura[0],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "Vencimento: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        dataVencimento[2] +
                            "/" +
                            dataVencimento[1] +
                            "/" +
                            dataVencimento[0],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.grey[600]),
                      ),
                    )
                  ],
                ),
                Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width * 0.95,
                  color: Colors.grey[400],
                ),
                Container(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "R\$ $dataValor",
                      style: TextStyle(fontSize: 60.0, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "Código de Barras:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(new ClipboardData(text: dados));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("Copiado para área de transferência!"),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.copy,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.93,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          dados,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.grey[600]),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width * 0.95,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
          Container(
            child: Image(
              image: AssetImage("assets/images/barcode.png"),
              height: 160.0,
              width: 300.0,
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: <Widget>[
        scaffold,
      ],
    );
  }
}
