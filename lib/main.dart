import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as prefix0;
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

 
void main() async {
  runApp(new MaterialApp(
    home: new HomePage(),
  ));
}

class Lugar {
  String nome;
  String endereco;

  Lugar(this.nome, this.endereco);
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controladorTexto = TextEditingController();
  var data;
  String textoDaBusca = "";
  String url = "";
  double latitudeDaBusca = 0;
  double longitudeDaBusca = 0;
  String nome = "";
  String endereco = "";
  List<Lugar> lugares = [];
  //List<String> nomes = [];
  List<Map> nomes = [];
  var rest = [];
  double raioDaBusca = 0;
 Position posicao; 

  Future<Map> posicionar () async{
  posicao = await Geolocator().getCurrentPosition(desiredAccuracy: prefix0.LocationAccuracy.high);
  }
  void inicializarBusca(String texto) {
    textoDaBusca = texto;
    latitudeDaBusca = -9.66625;
    longitudeDaBusca = -35.7351;
  }

  void limparDados() {
    controladorTexto.text = "";
    textoDaBusca = "";
  }

  Future<Map> getData(String texto) async {
    if (texto == null || texto == "") {
      limparDados();
    }
    inicializarBusca(texto);
    url =
        "https://api.tomtom.com/search/2/search/$textoDaBusca.json?key=6qI4CVhqm42mHhfwCQke1U5LgYOFAVOA&lat=$latitudeDaBusca&lon=$longitudeDaBusca&radius=$raioDaBusca";
    http.Response resposta = await http.get(url);
    return json.decode(resposta.body);
  }

  @override
  void initState() {
    super.initState();
    controladorTexto.addListener(_imprimirUltmoValor);
  }

  @override
  void dispose() {
    controladorTexto.addListener(_imprimirUltmoValor);
    controladorTexto.dispose();
    super.dispose();
  }

  _imprimirUltmoValor() {
    return controladorTexto.text;
  }

  void _setRaio(double valor) => setState(() => raioDaBusca = valor);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Navegar'),
        backgroundColor: Colors.orangeAccent,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpar dados',
            onPressed: () {
              limparDados();
              posicionar();
              print(posicao.latitude.toString());
              
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'O que você quer buscar?',
              ),
              controller: controladorTexto,
            ),
            RaisedButton(
                padding: const EdgeInsets.all(10.0),
                child: new Text("Buscar"),
                color: Colors.orangeAccent,
                onPressed: () {
                  getData(controladorTexto.text);
                  setState(() {});
                }),
            Text(
              "Você pesquisou por: ",
              style: TextStyle(color: Colors.black, fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            Text(
              "${controladorTexto.text}:",
              style: TextStyle(color: Colors.orangeAccent, fontSize: 22.0),
            ),
            Slider(
              activeColor: Colors.orangeAccent,
              min: 0.0,
              max: 10000.0,
              value: raioDaBusca.roundToDouble(),
              onChanged: _setRaio,
              label: "Raio",
            ),
            Text("${raioDaBusca.round()} m"),
            Divider(),
            Divider(),
           
            FutureBuilder<Map>(
              
              future: getData(controladorTexto.text),
              builder: (context, AsyncSnapshot<Map> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return new Container(
                      height: 100,
                      width: 100,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            backgroundColor: Colors.black,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.orangeAccent),
                            strokeWidth: 6,
                          ),
                          Divider(),
                          Text("Carregando..."),
                        ],
                      ),
                    );

                  default:
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Erro ao Carregar Dados... ",
                          style: TextStyle(
                              color: Colors.orangeAccent, fontSize: 20.0),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                }
                ;
                List<String> nomes = [];
                List<String> enderecos = [];
                List<String> categorias = [];

                String strNome = "";
                String strEnd = "";
                String categoria = "";

                // print(snapshot.data["results"][0]["poi"]);
                if (controladorTexto.text != "") {
                  for (int i = 1; i < snapshot.data["results"].length; i++) {
                    if (snapshot.data["results"][i]["poi"] != null) {
                      strNome = snapshot.data['results'][i]['poi']['name'];
                      strEnd = snapshot.data["results"][i]["address"]
                              ["freeformAddress"]
                          .toString();
                      categoria = snapshot.data["results"][i]["poi"]
                              ["categories"][0]
                          .toString();
                      enderecos.add(strEnd);
                      nomes.add(strNome);
                    }
                    if (categoria != null || categoria != "") {
                      categorias.add(categoria);
                    }
                  }


                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[valores(nomes, enderecos, categorias)],
                    ),
                  );
                } // IF end
                else {
                  return Text(
                      "Não foi encontrado nada para ${controladorTexto.text}");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget valores(
    List<String> nomes, List<String> enderecos, List<String> categorias) {
  List<Widget> cartoes = new List<Widget>();
  for (var i = 0; i < nomes.length; i++) {
    //estilo da view
    cartoes.add(
      Card(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
              Text(
                "${nomes[i]}",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.orangeAccent,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.wavy),
              ),
              Text(
                "Endereço: ${enderecos[i]}\n" + "Categoria: ${categorias[i]}",
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              )
            ],
          ),
        ),
      ),
    );
  }
  return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, children: cartoes);
}
