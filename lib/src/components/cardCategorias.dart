import 'package:flutter/material.dart';

class CardCategoria extends StatelessWidget {
  final String nomeCat;
  final String imgCat;
  final String totalProd;

  CardCategoria({this.nomeCat, this.imgCat, this.totalProd});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20.0),
      child: Card(
        child: Padding(
          //tudo que for na horizantal tem 20 e vertical tem 10
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Row(
            children: <Widget>[
              Container(
                child: Image.network(
                    'http://www.saaesantaizabel.com.br/santaizabel/web/home/images/' +
                        imgCat),
                height: 65.0,
                width: 65.0,
              ),
              SizedBox(width: 20.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    nomeCat,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                  ),
                  Text(
                    '$totalProd Produtos',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
