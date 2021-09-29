import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saaenet/src/components/globals.dart';
import 'package:saaenet/src/components/moeda.dart';
import 'package:saaenet/src/components/progressBar.dart';
import 'package:saaenet/src/shared/themes/app_text_styles.dart';
import 'package:saaenet/src/tabs/tabs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class FinalizarAcordoPage extends StatefulWidget {
  var _matricula,
      _total,
      _entrada,
      _dadosAcordo,
      _nParcelas,
      _parcelas,
      _fatura;
  FinalizarAcordoPage(
      matricula, total, entrada, dadosAcordo, nParcelas, parcelas, fatura) {
    this._matricula = matricula;
    this._total = total;
    this._entrada = entrada;
    this._dadosAcordo = dadosAcordo;
    this._nParcelas = nParcelas;
    this._parcelas = parcelas;
    this._fatura = fatura;
  }

  @override
  _FinalizarAcordoPageState createState() => _FinalizarAcordoPageState();
}

class _FinalizarAcordoPageState extends State<FinalizarAcordoPage> {
  bool checkedValue = false;
  String saae;
  ProgressBarHandler _handler;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    final uc = widget._matricula;
    final total = widget._total;
    final entrada = widget._entrada;
    final dadosAcordo = widget._dadosAcordo;
    final nParcelas = widget._nParcelas;
    final parcelas = widget._parcelas;
    final fatura = widget._fatura;
    DateTime dataEntrada = DateTime.now();

    var date = DateTime.now();
    var newDate = DateTime(date.year, date.month, date.day);

    final data = DateFormat("yyyy-MM-dd").format(newDate);

    void mensagemAcordo() {
      var alert = new AlertDialog(
        title: new Text('SaaeNet diz:'),
        content: new Text(
          'Você deve concordar com os termos do Contrato de Parcelamento e Confição de Dívida para continuar!!!',
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

    //COMUNICAÇÃO A API PARA GERAR BOLETO PDF
    void geraAcordo() async {
      if (globalCidade == "Santa Izabel") {
        saae = "saaesantaizabel";
      }
      if (globalCidade == "Cametá") {
        saae = "saaecameta";
      }
      await http.get(
          Uri.parse(Uri.encodeFull(
              "http://www.$saae.com.br/api/matriculas/insertAcordo.php?uc=$uc&dadosAcordo=$dadosAcordo&nParcelas=$nParcelas&data=$data&parcelas=$parcelas&fatura=$fatura")),
          headers: {"Accept": "application/json"});
    }

    //COMUNICAÇÃO A API PARA GERAR BOLETO PDF
    void geraPdf() async {
      final valorEntrada = currencyToDouble(entrada);

      if (globalCidade == "Santa Izabel") {
        saae = "saaesantaizabel";
      }
      if (globalCidade == "Cametá") {
        saae = "saaecameta";
      }
      await http.get(
          Uri.parse(Uri.encodeFull(
              "http://www.$saae.com.br/api/boleto_entrada_acordo.php?uc=$uc&dadosAcordo=$dadosAcordo&valorEntrada=$valorEntrada")),
          headers: {"Accept": "application/json"});
    }

    //COMUNICAÇÃO A API PARA GERAR BOLETO PDF
    void geraContratoPdf() async {
      if (globalCidade == "Santa Izabel") {
        saae = "saaesantaizabel";
      }
      if (globalCidade == "Cametá") {
        saae = "saaecameta";
      }
      await http.get(
          Uri.parse(Uri.encodeFull(
              "http://www.$saae.com.br/api/geraContratoPdf.php?uc=$uc&total=$total&entrada=$entrada&parcelas=$parcelas&nParcelas=$nParcelas")),
          headers: {"Accept": "application/json"});
    }

    Future<void> abrirUrlEntrada() async {
      var dia = DateFormat("yyyyMMdd").format(dataEntrada);
      if (globalCidade == "Santa Izabel") {
        saae = "saaesantaizabel";
      }
      if (globalCidade == "Cametá") {
        saae = "saaecameta";
      }
      final url =
          "http://www.$saae.com.br/api/$uc-entradaAcordo-$dadosAcordo-$dia.pdf";
      if (await canLaunch(url)) {
        await launch(
          url,
          forceSafariVC: true,
          enableJavaScript: true,
        );
      } else {
        throw 'Could not launch $url';
      }
    }

    Future<void> abrirContratoPdf() async {
      var dia = DateFormat("yyyyMMdd").format(dataEntrada);
      if (globalCidade == "Santa Izabel") {
        saae = "saaesantaizabel";
      }
      if (globalCidade == "Cametá") {
        saae = "saaecameta";
      }
      final url = "http://www.$saae.com.br/api/$uc-acordo-$dia.pdf";
      if (await canLaunch(url)) {
        await launch(
          url,
          forceSafariVC: true,
          enableJavaScript: true,
        );
      } else {
        throw 'Could not launch $url';
      }
    }

    if (globalCidade == "Santa Izabel") {
      saae = "saaesantaizabel";
    }
    if (globalCidade == "Cametá") {
      saae = "saaecameta";
    }

    var scaffold = Scaffold(
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
                            'CONTRATO ACORDO N° $dadosAcordo',
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
                          DateFormat("'Data:' dd/MM/yyyy").format(newDate),
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
              padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 480.0),
                child: WebView(
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer(),
                    ),
                  },
                  initialUrl:
                      "http://www.$saae.com.br/api/usuarios/contrato.php?uc=$uc&total=$total&entrada=$entrada&parcelas=$parcelas&nParcelas=$nParcelas",
                ),
              ),
            ),
            Container(
                child: CheckboxListTile(
              title: Text(
                "Declaro que li e concordo com este Contrato de Parcelamento e Confição de Dívida.",
                style: TextStyle(fontSize: 14.0),
              ),
              value: checkedValue,
              onChanged: (newValue) {
                setState(() {
                  checkedValue = newValue;
                });
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            )),
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
                    geraContratoPdf();
                    _handler.show();
                    Future.delayed(const Duration(milliseconds: 7000), () {
                      _handler.dismiss();
                      abrirContratoPdf();
                    });
                  },
                  child: Column(children: <Widget>[
                    Text('Imprimir', style: TextStyle(color: Colors.white)),
                    Text('Contrato', style: TextStyle(color: Colors.white)),
                  ]),
                ),
                Container(
                  height: 80.0,
                  width: 1,
                  color: Colors.white,
                ),
                GestureDetector(
                  onTap: () {
                    if (checkedValue == false) {
                      mensagemAcordo();
                    } else {
                      print(checkedValue);
                      geraAcordo();
                      geraPdf();
                      _handler.show();
                      Future.delayed(const Duration(milliseconds: 10000), () {
                        _handler.dismiss();
                        abrirUrlEntrada();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Tabs(globalCpf, globalEmail)));
                      });
                    }
                  },
                  child: Column(children: <Widget>[
                    Text('Finalizar', style: TextStyle(color: Colors.white)),
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
                Text('Entrada: $entrada',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Parcelas: 1 + $nParcelas",
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

    var progressBar = ModalRoundedProgressBar(
      handleCallback: (handler) {
        _handler = handler;
      },
    );

    return Stack(
      children: <Widget>[
        scaffold,
        progressBar,
      ],
    );
  }
}
