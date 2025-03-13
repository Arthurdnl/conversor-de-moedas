import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const request = 'https://api.hgbrasil.com/finance?key=89953f07';

void main() async{
  runApp(MaterialApp(
    home: Home() ,
  ));
}

Future<Map> getData() async{
  http.Response response = await http.get(Uri.parse(request));
  return jsonDecode(response.body);
}


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }
  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar*this.dolar).toStringAsFixed(2);
    euroController.text = (dolar*this.dolar/euro).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro*this.euro).toStringAsFixed(2);
    dolarController.text = (euro*this.euro/dolar).toStringAsFixed(2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Conversor de moedas'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(future: getData(),
          builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando Dados...",
                  style: TextStyle(color: Colors.amber,
                      fontSize: 25),
                textAlign: TextAlign.center,)
              );
            default:
              if(snapshot.hasError){
                return Center(
                child: Text("Erro ao carregar os dados",
                  style: TextStyle(color: Colors.amber,
                      fontSize: 25),
                  textAlign: TextAlign.center,)
                );
              }else{
                dolar = snapshot.data?['results']['currencies']['USD']['buy'];
                euro = snapshot.data?['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.monetization_on, size: 150, color: Colors.amber),
                      buildTextField("Reais", "R\$ ",realController, _realChanged),
                      Divider(height: 40,),
                      buildTextField("Dólares", "\$ ", dolarController, _dolarChanged),
                      Divider(height: 40,),
                      buildTextField("Euros", "€ ", euroController, _euroChanged),

                    ]
                  ),
                );
              }

          }
          }),
    );
  }
}
Widget buildTextField(String label, String prefix, TextEditingController controller, Function(String) F){
  return  TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber, fontSize: 25),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    onChanged: F,
    keyboardType: TextInputType.number,
  );
}

