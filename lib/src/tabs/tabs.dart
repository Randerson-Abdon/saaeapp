import 'package:saaenet/src/pages/Telainicial.dart';
import 'package:saaenet/src/pages/cadastroPage.dart';
import 'package:saaenet/src/pages/servicosPage.dart';
import 'package:saaenet/src/pages/configPage.dart';
import 'package:saaenet/src/pages/login.dart';
import 'package:saaenet/src/pages/acordosPage.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Tabs extends StatefulWidget {
  //variaves vindas de outras telas
  // ignore: non_constant_identifier_names
  var _numero_cpf_cnpj, _email_contato;
  Tabs(cpf, email) {
    this._numero_cpf_cnpj = cpf;
    this._email_contato = email;
  }

  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  var dados;
  var seguro = true;

  //criando recepção de outras telas
  var cpfuser, emailuser;

  int abaAtual = 0;

  TelaInicial telaInicial;
  AcordosPage acordos;
  ServicoPage servico;
  ConfigPage config;

  List<Widget> pages;
  Widget pagAtual;

  @override
  void initState() {
    telaInicial = TelaInicial(widget._numero_cpf_cnpj);
    acordos = AcordosPage(widget._numero_cpf_cnpj);
    servico = ServicoPage();
    config = ConfigPage();

    pages = [telaInicial, acordos, servico, config];
    pagAtual = telaInicial;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //variaves vindas de outras telas
    cpfuser = widget._numero_cpf_cnpj;
    emailuser = widget._email_contato;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            abaAtual == 0
                ? emailuser
                : abaAtual == 1
                    ? 'Acordos'
                    : abaAtual == 2
                        ? 'Serviços'
                        : 'Configurações',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => Login()));
              },
            ),
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),

        //MENU DRAWER
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => CadastroPage()));
                },
                leading: Icon(
                  Icons.people_alt,
                  color: Colors.blue,
                ),
                title: Text(
                  'Usuários',
                  style: TextStyle(fontSize: 16.0, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: abaAtual,
          onTap: (index) {
            setState(() {
              abaAtual = index;
              pagAtual = pages[index];
            });
          },
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.wash_outlined,
              ),
              label: 'Acordos',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_library,
              ),
              label: 'Serviços',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
              ),
              label: 'Configurações',
            ),
          ],
        ),

        //CONTEUDO DA PAGINA INICIAL HOME
        body: pagAtual,
      ),
    );
  }
}
