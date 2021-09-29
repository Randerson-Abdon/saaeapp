import 'dart:convert';
import 'dart:ui';
import 'package:animated_card/animated_card.dart';
import 'package:saaenet/src/components/progressBar.dart';
import 'package:saaenet/src/pages/cadastroPage.dart';
import 'package:saaenet/src/pages/faturaPorUc.dart';
import 'package:saaenet/src/tabs/tabs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saaenet/src/components/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  static String nomeCidade;
  static GlobalKey nomeCidade2;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  ProgressBarHandler _handler;
  bool _toggleVisibility = true; //variavel para mostar ou nao a senha
  String dropdownValue = 'One';

  //VARIAVEIS PARA CONTROLLER DE VALIDAÇÃO
  var cpfTxt = new TextEditingController();
  var senhaTxt = new TextEditingController();
  var cidadeTxt;
  var dados;
  var seguro = true;
  String saae;
  int newVersion = 3;
  int currentVersion = 3;

  var _cidades = [
    'Escolha seu Município',
    'Santa Izabel',
    'Cametá',
    'Quatipurú',
    'Primavera'
  ];
  var _itemSelecionado = 'Escolha seu Município';

  //select cidade
  Widget _cidade() {
    return Container(
      child: Column(
        children: <Widget>[
          DropdownButton<String>(
            autofocus: true,
            items: _cidades.map((String dropDownStringItem) {
              return DropdownMenuItem<String>(
                value: dropDownStringItem,
                child: Text(dropDownStringItem),
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
      cidadeTxt = _itemSelecionado;
    });
  }

  //campo email
  Widget _cpftxt() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: cpfTxt,
      autofocus: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'CPF',
        labelStyle: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
      ),
      style: TextStyle(
        fontSize: 20,
      ),
    );
  }

  //campo senha
  Widget _senhatxt() {
    return TextFormField(
      controller: senhaTxt,
      autofocus: true,
      keyboardType: TextInputType.text,
      //esconde senha
      obscureText: _toggleVisibility,
      decoration: InputDecoration(
        labelText: 'Senha',
        labelStyle: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        suffixIcon: IconButton(
          //mostrar e esconder senha
          onPressed: () {
            setState(() {
              _toggleVisibility = !_toggleVisibility;
            });
          },
          icon: _toggleVisibility
              ? Icon(Icons.visibility_off)
              : Icon(Icons.visibility),
        ),
      ),
      style: TextStyle(
        fontSize: 20,
      ),
    );
  }

  _abrirPlayStore() async {
    const url = 'market://details?id=com.saaenet';
    if (await canLaunch(url)) {
      await launch(url);
      Navigator.of(context).pop();
    } else {
      throw 'Could not launch $url';
    }
  }

//MENSAGEM DE DADOS INCORRETOS
  @override
  Widget build(BuildContext context) {
    Login.nomeCidade = cidadeTxt;
    globals.globalCidade = cidadeTxt;
    globals.globalCpf = cpfTxt.text;

    void mensagemD() async {
      var alert = AlertDialog(
        title: Text('SaaeNet diz:'),
        content: Text('Uma nova versão do App SaaeNet já esta disponive!'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Ver depois'),
          ),
          TextButton(
            onPressed: () => _abrirPlayStore(),
            child: const Text('Atualizar agora'),
          ),
        ],
      );
      showDialog(context: context, builder: (_) => alert);
    }

    //verificação de verção
    Future.delayed(const Duration(milliseconds: 5000), () {
      _handler.dismiss();
      if (newVersion > currentVersion) {
        mensagemD();
      }
    });

    void mensagemDadosIncorretos() {
      var alert = new AlertDialog(
        title: new Text('Não foi possível entrar!!!'),
        content: new Text('Dados Incorretos!'),
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

    void mensagemCidade() {
      var alert = new AlertDialog(
        title: new Text('Não foi possível continuar!!!'),
        content: new Text('Escolha um município!'),
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

    //COMUNICAÇÃO DE LOGIN COM A API
    void login(String cpf, String senha) async {
      if (cidadeTxt == "Santa Izabel") {
        saae = "saaesantaizabel";
      }
      if (cidadeTxt == "Cametá") {
        saae = "saaecameta";
      }
      var response = await http.get(
          Uri.parse(Uri.encodeFull(
              "http://www.$saae.com.br/api/usuarios/login.php?cpf=$cpf&senha=$senha")),
          headers: {"Accept": "application/json"});

      //print(response.body);
      var obj = json.decode(response.body);
      var msg = obj['message'];
      if (msg == 'Dados Incorretos!') {
        mensagemDadosIncorretos();
        _handler.dismiss();
      } else {
        dados = obj['result'];
        globals.globalEmail = dados[0]['email_contato'];

        if (dados[0]['numero_cpf_cnpj'] == cpf &&
            dados[0]['senha_acesso_permanente'] == senha) {
          var route = MaterialPageRoute(
            //passando parametros entre telas
            builder: (BuildContext context) =>
                Tabs(dados[0]['numero_cpf_cnpj'], dados[0]['email_contato']),
          );
          Navigator.of(context).push(route);
        }
      }
    }

    var scaffold = Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fundo.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 20),
        child: AnimatedCard(
          duration: Duration(seconds: 2),
          direction: AnimatedCardDirection.top,
          curve: Curves.bounceOut,
          child: ListView(
            children: <Widget>[
              //mesmo que div
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset('assets/logo.png'),
              ),
              SizedBox(
                height: 20,
              ),
              _cidade(),
              _cpftxt(),
              SizedBox(
                height: 10,
              ),
              _senhatxt(),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                alignment: Alignment.centerLeft,
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
                    onPressed: () {
                      if (cidadeTxt == null) {
                        mensagemCidade();
                      } else {
                        setState(() {
                          _handler.show();
                          login(cpfTxt.text, senhaTxt.text);
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Container(
                          child: SizedBox(
                            child:
                                Image.asset('assets/reset-password-icon.png'),
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Color(0xFF3C5A99),
                  //arredondamento de bordas
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                //colocando botão dentro do container de forma expandida
                child: SizedBox.expand(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue[900]),
                    ),
                    onPressed: () {
                      if (cidadeTxt == null) {
                        mensagemCidade();
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                FaturaPorUc(cidade: cidadeTxt)));
                        print(cidadeTxt);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Quero Pagar uma Tarifa',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Container(
                          child: SizedBox(
                            child: Image.asset('assets/images/pagar.png'),
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Não possui Cadastro?",
                    style: TextStyle(
                        color: Color(0xFF3C5A99),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                  SizedBox(width: 10.0),
                  GestureDetector(
                    onTap: () {
                      if (cidadeTxt == null) {
                        mensagemCidade();
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                CadastroPage(cidade: cidadeTxt)));
                        print(cidadeTxt);
                      }
                    },
                    child: Text(
                      "Cadastre-se",
                      style: TextStyle(
                          color: Color(0xFFF58524),
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Recuperar Senha?",
                    style: TextStyle(
                        color: Color(0xFFF58524),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                ],
              ),
            ],
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
}
