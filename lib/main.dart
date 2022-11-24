//e09f1aa3 - Chave de API
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

String ponto = '?';

//const request = "https://api.hgbrasil.com/finance?format=json-cors&key=e09f1aa3";
var request = Uri.https(
    "api.hgbrasil.com", "/finance", {"format=json-cors&key": "e09f1aa3"});

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          hintStyle: TextStyle(
            color: Colors.amber,
          ),
        ),
      ),
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              realController.clear();
              dolarController.clear();
              euroController.clear();
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: const Text(
          '\$ Conversor de Moeda \$',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  'Carregando Dados',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Erro ao carregar dados',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!['results']['currencies']['USD']['buy'];
                euro = snapshot.data!['results']['currencies']['EUR']['buy'];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                        'Reais',
                        'R\$',
                        realController,
                        onRealChanged,
                      ),
                      const Divider(),
                      buildTextField(
                        'Dolares',
                        'US\$',
                        dolarController,
                        onDolarChange,
                      ),
                      const Divider(),
                      buildTextField(
                        'Euros',
                        'e',
                        euroController,
                        onEuroChange,
                      ),
                      const Divider(),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  void onRealChanged(String text) {
    if (realController.text.isNotEmpty) {
      double dolarCalc = double.parse(realController.text) * dolar;
      double euroCalc = double.parse(realController.text) * euro;
      dolarController.text = dolarCalc.toStringAsFixed(2);
      euroController.text = euroCalc.toStringAsFixed(2);
    } else {
      dolarController.clear();
      euroController.clear();
    }
  }

  void onDolarChange(String text) {
    if (dolarController.text.isNotEmpty) {
      double realCalc = double.parse(dolarController.text) / dolar;
      double euroCalc = double.parse(dolarController.text) / dolar * euro;
      realController.text = realCalc.toStringAsFixed(2);
      euroController.text = euroCalc.toStringAsFixed(2);
    } else {
      realController.clear();
      euroController.clear();
    }
  }

  void onEuroChange(String text) {
    if (euroController.text.isNotEmpty) {
      double realCalc = double.parse(euroController.text) / euro;
      double dolarCalc = double.parse(euroController.text) / euro * dolar;
      realController.text = realCalc.toStringAsFixed(2);
      dolarController.text = dolarCalc.toStringAsFixed(2);
    } else {
      realController.clear();
      dolarController.clear();
    }
  }
}

Widget buildTextField(
  String label,
  String prefix,
  TextEditingController controller,
  Function(String) f,
) {
  return TextField(
    keyboardType: TextInputType.number,
    controller: controller,
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: f,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.amber,
        ),
        border: const OutlineInputBorder(),
        prefixText: prefix),
  );
}
