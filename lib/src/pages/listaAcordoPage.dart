import 'dart:convert';
import 'dart:ui';
import 'package:animated_card/animated_card.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saaenet/src/components/globals.dart';
import 'package:saaenet/src/components/moeda.dart';
import 'package:saaenet/src/components/progressBar.dart';
import 'package:saaenet/src/shared/themes/app_text_styles.dart';
import 'package:saaenet/src/tabs/tabs.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ListaAcordosPage extends StatefulWidget {
  var _matricula;
  ListaAcordosPage(matricula) {
    this._matricula = matricula;
  }

  @override
  _ListaAcordosPageState createState() => _ListaAcordosPageState();
}

class _ListaAcordosPageState extends State<ListaAcordosPage> {
  ProgressBarHandler _handler;
  var result;
  var msg = 'no';
  var dados;
  double total = 0.0;
  double avulso = 0.0;
  String saae;
  var teste;
  Map<int, bool> selectedFlag = {};
  bool isSelectionMode = false;
  TextEditingController checkbox = TextEditingController();
  List competencia = [];
  bool isSelected;
  DateTime data = DateTime.now();
  bool acordo = false;

  int diffInDays(DateTime date1, DateTime date2) {
    return ((date1.difference(date2) -
                    Duration(hours: date1.hour) +
                    Duration(hours: date2.hour))
                .inHours /
            24)
        .round();
  }

  void mensagemDadosIncorretos() {
    var alert = new AlertDialog(
      title: new Text('SaaeNet diz:'),
      content: new Text('Não há acordos abertos para esta matrícula.'),
      actions: <Widget>[
        new ElevatedButton(
          child: new Text('OK'),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    Tabs(globalCpf, globalEmail)));
          },
        ),
      ],
    );
    showDialog(context: context, builder: (_) => alert);
  }

  void mensagemIndisponivel() {
    var alert = new AlertDialog(
      title: new Text('SaaeNet diz:'),
      content: new Text('Indispinível no momento, aguarde novas atualizações.'),
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
        'http://www.$saae.com.br/api/matriculas/listarAcordos.php?matricula=$matricula'));
    //print(response.body);
    final map = json.decode(response.body);
    final itens = map["result"];
    var msg = map['message'];

    setState(() {
      this.dados = itens;
      if (msg != 'Dados Incorretos!') {
        /* for (var value in dados) {
          total += double.parse(value['TOTALII']);
        } */
      } else {
        mensagemDadosIncorretos();
      }
    });
  }

  //executando listar dados
  @override
  void initState() {
    super.initState();
    listarDados(widget._matricula);
  }

  //COMUNICAÇÃO A API PARA GERAR BOLETO PDF
  void geraPdf() async {
    var id = widget._matricula;
    if (globalCidade == "Santa Izabel") {
      saae = "saaesantaizabel";
    }
    if (globalCidade == "Cametá") {
      saae = "saaecameta";
    }
    teste = await http.get(
        Uri.parse(Uri.encodeFull(
            "http://www.$saae.com.br/api/boleto_avulso.php?id=$id&competencia=$competencia")),
        headers: {"Accept": "application/json"});
  }

  Future<void> abrirUrl() async {
    var id = widget._matricula;
    var dia = DateFormat("yyyyMMdd").format(data);
    if (globalCidade == "Santa Izabel") {
      saae = "saaesantaizabel";
    }
    if (globalCidade == "Cametá") {
      saae = "saaecameta";
    }
    final url = "http://www.$saae.com.br/api/$id-avulso-$dia.pdf";
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

  //COMUNICAÇÃO COM A API PARA VERIFICAÇÃO DE ARQUIVO
  void verificacao() async {
    var id = widget._matricula;
    var dia = DateFormat("yyyyMMdd").format(data);
    var nome = "$id-avulso-$dia";
    if (globalCidade == "Santa Izabel") {
      saae = "saaesantaizabel";
    }
    if (globalCidade == "Cametá") {
      saae = "saaecameta";
    }
    var response = await http.get(
        Uri.parse(Uri.encodeFull(
            "http://www.$saae.com.br/api/verificacao.php?nome=$nome")),
        headers: {"Accept": "application/json"});

    print(response.body);
    var obj = json.decode(response.body);
    setState(() {
      msg = obj['message'];
      while (msg != 'ok') {
        print(msg);
      }
      _handler.dismiss();
      abrirUrl();
    });
  }

  void mensagemCompetenciaVazia() {
    var alert = new AlertDialog(
      title: new Text('SaaeNet diz:'),
      content: new Text(
        'Nenhuma fatura selecionada! Utilize o clique longo para abrir a seleção de faturas.',
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

  void mensagemCompetenciaminima() {
    var alert = new AlertDialog(
      title: new Text('SaaeNet diz:'),
      content: new Text(
        'Se você deseja imprimir apenas uma fatura, clique na mesma para visualizar!',
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

  void mensagemSemVencidas() {
    var alert = new AlertDialog(
      title: new Text('SaaeNet diz:'),
      content: new Text(
        'Não há competências vencidas!',
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

  @override
  Widget build(BuildContext context) {
    final uc = widget._matricula;
    final size = MediaQuery.of(context).size;
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
                  Row(
                    children: [
                      BackButton(
                        color: Colors.white,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          'ACORDOS EM ABERTO',
                          style: TextStyles.titleRegular,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: Text(
                      "MATRÍCULA $uc",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            SizedBox(height: 10.0), //espaçamento
            Column(
              children: <Widget>[
                Container(
                  height: size.height * 0.70,
                  width: 400.0,
                  //TRAZENDO DADOS
                  child: ListView.builder(
                      itemCount: this.dados != null ? this.dados.length : 0,
                      itemBuilder: (context, i) {
                        final item = this.dados[i];
                        selectedFlag[i] = selectedFlag[i] ?? false;
                        bool isSelected = selectedFlag[i];

                        void onLongPress(bool isSelected, int i) {
                          setState(() {
                            selectedFlag[i] = !isSelected;
                            // If there will be any true in the selectionFlag then
                            // selection Mode will be true
                            isSelectionMode = selectedFlag.containsValue(false);

                            competencia.add(item['COMPETENCIAII']);
                            avulso += double.parse(item['TOTALII']);
                          });
                        }

                        Widget _buildSelectIcon(bool isSelected, Map item) {
                          if (isSelectionMode) {
                            return Checkbox(
                              key: Key(item['COMPETENCIAII']),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (isSelected == false) {
                                    onTap(isSelected, i);
                                    competencia.add(item['COMPETENCIAII']);
                                    avulso += double.parse(item['TOTALII']);
                                  } else {
                                    onTap(isSelected, i);
                                    competencia.remove(item['COMPETENCIAII']);
                                    avulso -= double.parse(item['TOTALII']);
                                  }
                                });
                              },
                            );
                          } else {
                            return Image.asset('assets/images/matricula.png');
                          }
                        }

                        return AnimatedCard(
                          direction: AnimatedCardDirection.right,
                          child: Card(
                            child: ListTile(
                              onLongPress: () => onLongPress(isSelected, i),
                              onTap: () {
                                mensagemIndisponivel();
                                /* Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        BoletoPage(
                                            item['COMPETENCIA'],
                                            item['ID_UC'],
                                            item['COMPETENCIAII'],
                                            item['ID_LOC'],
                                            item['VENCTO'],
                                            item['TOTAL']))); */
                              },
                              tileColor: isSelected != true
                                  ? Colors.blue
                                  : Colors.amber,
                              leading: _buildSelectIcon(isSelected, item),
                              title: Text(
                                item['N.º PARC.'],
                                style: TextStyle(color: Color(0xFFFFFFFF)),
                              ),
                              subtitle: Text(
                                'VENCIMENTO: ' + item['VENCTO'],
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF), fontSize: 12.5),
                              ),
                              trailing: Text(
                                item['VALOR'],
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
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
                    mensagemIndisponivel();

                    /* if (competencia.length == 0) {
                      mensagemCompetenciaVazia();
                    } else if (competencia.length == 1) {
                      mensagemCompetenciaminima();
                    } else {
                      geraPdf();

                      _handler.show();
                      Future.delayed(const Duration(milliseconds: 10000), () {
                        verificacao();
                      });
                    } */
                  },
                  child: Column(children: <Widget>[
                    Text('Boleto', style: TextStyle(color: Colors.white)),
                    Text('Avulso', style: TextStyle(color: Colors.white)),
                  ]),
                ),
                Container(
                  height: 80.0,
                  width: 1,
                  color: Colors.white,
                ),
                GestureDetector(
                  onTap: () {
                    mensagemIndisponivel();

                    /* if (acordo) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => AcordoPage(uc)));
                    } else {
                      mensagemSemVencidas();
                    } */
                  },
                  child: Column(children: <Widget>[
                    Text('Gerar', style: TextStyle(color: Colors.white)),
                    Text('Novo', style: TextStyle(color: Colors.white)),
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
                Text('Avulso: ' + doubleToCurrency(avulso),
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

  void onTap(bool isSelected, int i) {
    if (isSelectionMode) {
      setState(() {
        selectedFlag[i] = !isSelected;
        isSelectionMode = selectedFlag.containsValue(true);
      });
    } else {
      // Open Detail Page
    }
  }
}
