import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const req = "https://api.hgbrasil.com/finance";

void main() {
  runApp(MaterialApp(
      home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    if (text != "") {
      double real = double.parse(text);
      dolarController.text = (real/dolar).toStringAsFixed(2);
      euroController.text = (real/euro).toStringAsFixed(2);
    }
    else {
      dolarController.text = "0.00";
      euroController.text = "0.00";
    }
  }

  void _dolarChanged(String text) {
    if (text != "") {
      double dolar = double.parse(text);
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroController.text = (dolar * this.dolar/euro).toStringAsFixed(2);
    }
    else {
      realController.text = "0.00";
      euroController.text = "0.00";
    }
  }

  void _euroChanged(String text) {
    if (text != "") {
      double euro = double.parse(text);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro/dolar).toStringAsFixed(2);
    }
    else {
      realController.text = "0.00";
      dolarController.text = "0.00";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor"),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white,),
            onPressed: () {
              realController.text = "0.00";
              dolarController.text = "0.00";
              euroController.text = "0.00";
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      "Carregando dados",
                      style:
                          TextStyle(color: Colors.lightGreen, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                default:
                  if (snapshot.hasError)
                    return Center(
                      child: Text(
                        "Erro ao carregar dados",
                        style:
                            TextStyle(color: Colors.lightGreen, fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ),
                    );
                  else

                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];

                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.attach_money,
                        size: 120.0,
                        color: Colors.lightGreen,
                      ),
                      getTextField("Reais", "R\$ ", realController, _realChanged),
                      Divider(),
                      getTextField("Dólares", "US\$ ", dolarController, _dolarChanged),
                      Divider(),
                      getTextField("Euros", "€ ", euroController, _euroChanged),
                    ],
                  );
              }
            }),
      ),
    );
  }
}

getTextField(String labelText, String prefixText, TextEditingController controller, Function changed) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightGreen)
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightGreen)
        ),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.lightGreen),
        prefixStyle: TextStyle(color: Colors.lightGreen),
        prefixText: prefixText),
    style: TextStyle(color: Colors.lightGreen, fontSize: 25.0),
    controller: controller,
    onChanged: changed,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(req);
  return json.decode(response.body);
}
