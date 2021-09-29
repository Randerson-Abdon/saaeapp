import 'dart:convert';
import 'package:saaenet/src/components/botao.dart';
import 'package:saaenet/src/components/globals.dart';
import 'package:saaenet/src/components/progressBar.dart';
import 'package:saaenet/src/pages/barcodePage.dart';
import 'package:saaenet/src/pages/login.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class FaturaPorUc extends StatefulWidget {
  final String cidade;
  const FaturaPorUc({Key key, this.cidade}) : super(key: key);

  @override
  _FaturaPorUcState createState() => _FaturaPorUcState();
}

class _FaturaPorUcState extends State<FaturaPorUc> {
  ProgressBarHandler _handler;
  var dados;

  String _matricula;
  String _competencia;
  // String _confirmPassword;

  //VARIAVEIS PARA CONTROLLER DE EDIÇÃO
  var matriculaTxt = new TextEditingController();
  var competenciaTxt = new TextEditingController();
  String saae;

  GlobalKey<FormState> _formKey = GlobalKey();

  final dueDateInputTextController = MaskedTextController(mask: "00/0000");

  Widget _competenciatxt() {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: dueDateInputTextController,
      decoration: InputDecoration(
        hintText: "Competência",
        hintStyle: TextStyle(
          color: Color(0xFFBDC2CB),
          fontSize: 18.0,
        ),
      ),
      onSaved: (String competencia) {
        _competencia = competencia.trim();
      },
      validator: (String competencia) {
        String errorMessage;
        if (competencia.isEmpty) {
          //validação
          errorMessage = "O competência é requerido";
        }
        // if(username.length > 8 ){
        //   errorMessage = "Your username is too short";
        // }
        return errorMessage;
      },
    );
  }

  Widget _matriculatxt() {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: matriculaTxt,
      decoration: InputDecoration(
        hintText: "Matrícula",
        hintStyle: TextStyle(
          color: Color(0xFFBDC2CB),
          fontSize: 18.0,
        ),
      ),
      onSaved: (String matricula) {
        _matricula = matricula.trim();
      },
      validator: (String matricula) {
        String errorMessage;
        if (matricula.isEmpty) {
          //validação
          errorMessage = "O CPF é requerido";
        }
        // if(username.length > 8 ){
        //   errorMessage = "Your username is too short";
        // }
        return errorMessage;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void mensagemDadosIncorretos() {
      var alert = new AlertDialog(
        title: new Text('SAAENET diz:'),
        content: new Text('Fatura Inexistente!'),
        actions: <Widget>[
          new ElevatedButton(
            child: new Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              _handler.dismiss();
            },
          ),
        ],
      );
      showDialog(context: context, builder: (_) => alert);
    }

    //COMUNICAÇÃO DE INSERÇÃO NA API
    void _buscar() async {
      if (globalCidade == "Santa Izabel") {
        saae = "saaesantaizabel";
      }
      if (globalCidade == "Cametá") {
        saae = "saaecameta";
      }
      var uc = matriculaTxt.text;
      var fatura = dueDateInputTextController.text;
      var response = await http.get(
          Uri.parse(Uri.encodeFull(
              "http://www.$saae.com.br/api/matriculas/fatura.php?uc=$uc&fatura=$fatura")),
          headers: {"Accept": "application/json"});

      //print(response.body);
      var obj = json.decode(response.body);
      var msg = obj['message'];
      if (msg == 'Dados Incorretos!') {
        mensagemDadosIncorretos();
      } else {
        dados = obj['result'];
        _handler.dismiss();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => BarcodePage(
                  dados[0]['mes_faturado'],
                  dados[0]['id_unidade_consumidora'],
                  dados[0]['mes_faturado'],
                  dados[0]['id_localidade'],
                  dados[0]['data_vencimento_fatura'],
                  dados[0]['total_geral_faturado'],
                )));
      }
    }

    var scaffold = SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey.shade100,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fundoPages.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage("assets/images/barcode.png"),
                    height: 160.0,
                    width: 300.0,
                  ),
                  SizedBox(height: 20.0),
                  Card(
                    elevation: 5.0,
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          _matriculatxt(),
                          SizedBox(
                            height: 15.0,
                          ),
                          _competenciatxt(),
                          SizedBox(
                            height: 15.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  GestureDetector(
                    child: Button(
                      btnText: "Buscar",
                      onPressed: () {
                        //print(dueDateInputTextController.text);
                        _handler.show();
                        _buscar();
                      },
                    ),
                  ),
                  Divider(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Já possui Cadastro?",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                      SizedBox(width: 10.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (BuildContext context) => Login()));
                        },
                        child: Text(
                          "Logar",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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

  void onSubmit(Function authenticate) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      print("Seu Email: $_matricula, sua senha: $_competencia");
      authenticate(_matricula, _competencia);
    }
  }
}
