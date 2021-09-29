import 'dart:convert';
import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:saaenet/src/components/botao.dart';
import 'package:saaenet/src/components/globals.dart';
import 'package:saaenet/src/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CadastroPage extends StatefulWidget {
  final String cidade;
  const CadastroPage({Key key, this.cidade}) : super(key: key);

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  bool _toggleVisibility = true;
  bool isCheckedZap = false;
  bool isCheckedMail = false;

  String _email;
  String _data;
  String _senha;
  String _cpf;
  String _telefone;
  // String _confirmPassword;

  //VARIAVEIS PARA CONTROLLER DE EDIÇÃO
  var dataTxt = new MaskedTextController(mask: '00/00/0000');
  var emailTxt = new TextEditingController();
  var senhaTxt = new TextEditingController();
  var cpfTxt = new MaskedTextController(mask: '000.000.000-00');
  var telefoneTxt = new MaskedTextController(mask: '(00) 00000-0000');
  var codigoTxt = new TextEditingController();
  String saae;

  GlobalKey<FormState> _formKey = GlobalKey();

  Widget _emailtxt() {
    return TextFormField(
      controller: emailTxt,
      decoration: InputDecoration(
        hintText: "Email",
        hintStyle: TextStyle(
          color: Color(0xFFBDC2CB),
          fontSize: 18.0,
        ),
      ),
      onSaved: (String email) {
        _email = email;
      },
      validator: (String email) {
        String errorMessage;
        if (!email.contains("@")) {
          //validação
          errorMessage = "Seu email está incorreto";
        }
        if (email.isEmpty) {
          errorMessage = "O campo email é requerido";
        }

        return errorMessage;
      },
    );
  }

  Widget _datatxt() {
    return TextFormField(
      controller: dataTxt,
      decoration: InputDecoration(
        hintText: "Data de Nascimento",
        hintStyle: TextStyle(
          color: Color(0xFFBDC2CB),
          fontSize: 18.0,
        ),
      ),
      onSaved: (String data) {
        _data = data.trim();
      },
      validator: (String data) {
        String errorMessage;
        if (data.isEmpty) {
          //validação
          errorMessage = "O nome é requerido";
        }
        // if(username.length > 8 ){
        //   errorMessage = "Your username is too short";
        // }
        return errorMessage;
      },
    );
  }

  Widget _cpftxt() {
    return TextFormField(
      controller: cpfTxt,
      decoration: InputDecoration(
        hintText: "CPF",
        hintStyle: TextStyle(
          color: Color(0xFFBDC2CB),
          fontSize: 18.0,
        ),
      ),
      onSaved: (String cpf) {
        _cpf = cpf.trim();
      },
      validator: (String cpf) {
        String errorMessage;
        if (cpf.isEmpty) {
          //validação
          errorMessage = "O CPF é requerido";
        }
        if (cpf.length < 11) {
          errorMessage = "CPF Invalido";
        }
        return errorMessage;
      },
    );
  }

  Widget _telefonetxt() {
    return TextFormField(
      controller: telefoneTxt,
      decoration: InputDecoration(
        hintText: "Celular",
        hintStyle: TextStyle(
          color: Color(0xFFBDC2CB),
          fontSize: 18.0,
        ),
      ),
      onSaved: (String telefone) {
        _telefone = telefone.trim();
      },
      validator: (String telefone) {
        String errorMessage;
        if (telefone.isEmpty) {
          //validação
          errorMessage = "O telefone é requerido";
        }
        // if(username.length > 8 ){
        //   errorMessage = "Your username is too short";
        // }
        return errorMessage;
      },
    );
  }

  // ignore: unused_element
  Widget _senhatxt() {
    return TextFormField(
      controller: senhaTxt,
      decoration: InputDecoration(
        hintText: "Senha",
        hintStyle: TextStyle(
          color: Color(0xFFBDC2CB),
          fontSize: 18.0,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              //visibilidade da senha
              _toggleVisibility = !_toggleVisibility;
            });
          },
          icon: _toggleVisibility
              ? Icon(Icons.visibility_off)
              : Icon(Icons.visibility),
        ),
      ),
      obscureText: _toggleVisibility,
      onSaved: (String password) {
        _senha = password;
      },
      validator: (String password) {
        String errorMessage;

        if (password.isEmpty) {
          errorMessage = "O campo senha é requerido";
        }
        return errorMessage;
      },
    );
  }

  Widget _codigo() {
    return TextFormField(
      controller: codigoTxt,
      decoration: InputDecoration(
        hintText: "Código",
        hintStyle: TextStyle(
          color: Color(0xFFBDC2CB),
          fontSize: 18.0,
        ),
      ),
      onSaved: (String codigo) {
        _data = codigo.trim();
      },
      validator: (String codigo) {
        String errorMessage;
        if (codigo.isEmpty) {
          //validação
          errorMessage = "O código é requerido";
        }
        // if(username.length > 8 ){
        //   errorMessage = "Your username is too short";
        // }
        return errorMessage;
      },
    );
  }

  mensagem(res) {
    var alert = new AlertDialog(
      title: new Text('SaaeNet diz:'),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text(res),
          ],
        ),
      ),
      actions: <Widget>[
        new ElevatedButton(
          child: new Text('OK'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
        ),
      ],
    );
    showDialog(context: context, builder: (_) => alert);

    if (res == 'Cadastrado com Sucesso!') {
      dataTxt.text = '';
      emailTxt.text = '';
      telefoneTxt.text = '';
      cpfTxt.text = '';
      senhaTxt.text = '';
    }
  }

  mensagemErro() {
    var alert = new AlertDialog(
      title: new Text('SaaeNet diz:'),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text('Código Incorreto!'),
          ],
        ),
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

  //COMUNICAÇÃO DE INSERÇÃO NA API
  void _inserir() async {
    if (globalCidade == "Santa Izabel") {
      saae = "saaesantaizabel";
    }
    if (globalCidade == "Cametá") {
      saae = "saaecameta";
    }

    var response = await http.post(
        Uri.parse('http://www.$saae.com.br/api/usuarios/inserir.php'),
        body: {
          'data': dataTxt.text,
          'email': emailTxt.text,
          'cpf': cpfTxt.text,
          'telefone': telefoneTxt.text,
          'senha': senhaTxt.text,
        });

    //recuperação de validação da api
    final map = json.decode(response.body);
    final res = map["mensagem"];

    mensagem(res);
  }

  mensagemApiZap(resZap) {
    var alert = new AlertDialog(
      title: new Text('SaaeNet diz:'),
      content: new SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            Text('Digite o código recebido'),
            _codigo(),
          ],
        ),
      ),
      actions: <Widget>[
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  child: new Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  child: new Text('OK'),
                  onPressed: () {
                    if (codigoTxt.text == resZap) {
                      _inserir();
                      Navigator.of(context).pop();
                    } else {
                      mensagemErro();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
    showDialog(context: context, builder: (_) => alert);
  }

  mensagemApiMail(resMail) {
    var alert = new AlertDialog(
      title: new Text('SaaeNet diz:'),
      content: new SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            Text('Digite o código recebido'),
            _codigo(),
          ],
        ),
      ),
      actions: <Widget>[
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  child: new Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  child: new Text('OK'),
                  onPressed: () {
                    if (codigoTxt.text == resMail) {
                      _inserir();
                      Navigator.of(context).pop();
                    } else {
                      mensagemErro();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
    showDialog(context: context, builder: (_) => alert);
  }

  //ENVIO DE CODIGO VIA ZAP
  void _apiZapMobile() async {
    if (globalCidade == "Santa Izabel") {
      saae = "saaesantaizabel";
    }
    if (globalCidade == "Cametá") {
      saae = "saaecameta";
    }

    var response = await http.post(
        Uri.parse('http://www.$saae.com.br/api/api_zap_mobile.php'),
        body: {
          'fone_movel': telefoneTxt.text,
        });

    //recuperação de validação da api
    final map = json.decode(response.body);
    final resZap = map["mensagem"];

    mensagemApiZap(resZap);
  }

  //ENVIO DE CODIGO VIA EMAIL
  void _apiMailMobile() async {
    var response = await http.post(
        Uri.parse('http://datapremium.com.br/api_email_mobile.php'),
        body: {
          'email': emailTxt.text,
        });

    //recuperação de validação da api
    final map = json.decode(response.body);
    final resMail = map["mensagem"];

    mensagemApiMail(resMail);
  }

  mensagemValidaCpf() {
    var alert = new AlertDialog(
      title: new Text('App Diz:'),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text('CPF Invalido. Verifique os dados digitados!'),
          ],
        ),
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

  mensagemCodigo() {
    var alert = new AlertDialog(
      title: new Text('SaaeNet diz:'),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text('Selecione a forma para receber seu código!'),
          ],
        ),
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
    return SafeArea(
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
                    image: AssetImage("assets/images/cadastroLogo.png"),
                    height: 120.0,
                    width: 260.0,
                  ),
                  SizedBox(height: 10),
                  Card(
                    elevation: 5.0,
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          _datatxt(),
                          SizedBox(
                            height: 15.0,
                          ),
                          _cpftxt(),
                          SizedBox(
                            height: 15.0,
                          ),
                          _telefonetxt(),
                          SizedBox(
                            height: 15.0,
                          ),
                          _emailtxt(),
                          SizedBox(
                            height: 15.0,
                          ),
                          _senhatxt(),
                          SizedBox(height: 15.0),
                          Text(
                            'Obs.: Escolha a baixo a forma para receber seu código de confirmação.',
                            style: TextStyle(color: Colors.orange[900]),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                value: isCheckedZap,
                                focusColor: Colors.orange,
                                onChanged: (bool value) {
                                  setState(() {
                                    isCheckedZap = value;
                                    isCheckedMail = false;
                                  });
                                },
                              ),
                              Text('Por Whatsapp'),
                              SizedBox(width: 40),
                              Checkbox(
                                checkColor: Colors.white,
                                value: isCheckedMail,
                                focusColor: Colors.orange,
                                onChanged: (bool value) {
                                  setState(() {
                                    isCheckedMail = value;
                                    isCheckedZap = false;
                                  });
                                },
                              ),
                              Text('Por Email'),
                            ],
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
                      btnText: "Cadastrar",
                      onPressed: () {
                        final bool validCpf =
                            AllValidations.isCpf(cpfTxt.text) ? true : false;
                        if (validCpf == false) {
                          mensagemValidaCpf();
                        } else if (isCheckedZap == false &&
                            isCheckedMail == false) {
                          mensagemCodigo();
                        } else if (isCheckedZap == true) {
                          _apiZapMobile();
                        } else if (isCheckedMail == true) {
                          _apiMailMobile();
                        }
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
  }

  void onSubmit(Function authenticate) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      print("Seu Email: $_email, sua senha: $_senha");
      authenticate(_email, _cpf, _data, _telefone, _senha);
    }
  }
}
