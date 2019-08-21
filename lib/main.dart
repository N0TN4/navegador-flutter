import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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
  FocusNode _focoBusca = new FocusNode();
  var data;
  String textoDaBusca = "";
  String url = "";
  double latitudeDaBusca = 0;
  double longitudeDaBusca = 0;
  String nome = "";
  String endereco = "";
  List<Lugar> lugares = [];
  List<Map> nomes = [];
  var rest = [];
  String mensagemDaBusca = "";
  List<double> distancias = [];
  double latitude, longitude;

  var geolocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

  Future<Position> posicionar() async {
    StreamSubscription<Position> positionStream = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      latitude = position.latitude;
      longitude = position.longitude;
    });
    if(latitude != null || longitude != null ){
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title:  new Text("Ponto Certo"),
            content: new Text("A localização do dispositivo está atiavada!\nLatitude: $latitude, \nLongitude: $longitude"),
            actions: <Widget>[
              new FlatButton(
                child: Text("Fechar"),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      );
    }
    print(latitude);
    print(longitude);
  }

  Future<double> distanciaEntreDoisPontos(double latitudeDoItem, double longitudeDoItem) async {
    print(await Geolocator()
        .distanceBetween(latitude, longitude, latitudeDoItem, longitudeDoItem));
    distancias.add(await Geolocator()
        .distanceBetween(latitude, longitude, latitudeDoItem, longitudeDoItem));
    return await Geolocator()
        .distanceBetween(latitude, longitude, latitudeDoItem, longitudeDoItem);
  }

  void limparDados() {
    controladorTexto.text = "";
    textoDaBusca = "";
  }

  Future<Map> getData(String texto) async {
    if (texto == null || texto == "") {
      limparDados();
    }
    textoDaBusca = texto;
    latitudeDaBusca = latitude;
    longitudeDaBusca = longitude;

    url =
        "https://api.tomtom.com/search/2/search/$textoDaBusca.json?key=6qI4CVhqm42mHhfwCQke1U5LgYOFAVOA&lat=$latitudeDaBusca&lon=$longitudeDaBusca";
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.orangeAccent,
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    size: 32,
                  ),
                  tooltip: 'Limpar dados',
                  onPressed: () {
                    limparDados();
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text("Ponto Certo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w800,
                        ),
                      ),
                  background: Image.network(
                    "https://www.muypymes.com/wp-content/uploads/2018/09/marketinggeolocalizaci%C3%B3n-canariasdigital-660x330.gif",
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              TextField(
                focusNode: _focoBusca,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(28.0)),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),

                  labelText: 'O que você quer buscar?',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                  hintText: "Digite aqui",
                  hintStyle: TextStyle(fontSize: 20.0, color: Colors.black38),
                ),
                controller: controladorTexto,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container( 
                     child: Column(children: <Widget>[
                       IconButton(
                           icon: Icon(Icons.gps_fixed),
                        tooltip: 'Sua localização:',
                        onPressed: () {
                          posicionar();
                        },
                       ),
                       Text("Clique para ativar a localização",style: TextStyle(fontSize: 10),),
                       ],
                      ),  
                  ),
                  Divider(),
                   Container( 
                     child: Column(children: <Widget>[
                     IconButton(
                        icon: Icon(Icons.search, color: Colors.orangeAccent, size: 40,),
                        onPressed: () {
                            getData(controladorTexto.text);
                            _focoBusca.unfocus();
                            setState(() {});
                          }
                     ),
                       Text("Buscar", style: TextStyle(fontSize: 10, color: Colors.orangeAccent,)),
                       ],
                      ),  
                  ),
                ],
              ),
              Divider(),
              Text(
                "$mensagemDaBusca",
                style: TextStyle(color: Colors.black, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              Text(
                "${controladorTexto.text}...",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Divider(),
              Divider(),
              
              FutureBuilder<Map>(
                future: getData(controladorTexto.text),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    mensagemDaBusca = "Você pesquisou por: ${controladorTexto.text}";
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
                  List<double> latitudes = [];
                  List<double> longitudes = [];

                  String strNome = "";
                  String strEnd = "";
                  String categoria = "";
                  double latitudeDoItem = 0;
                  double longitudeDoItem = 0;

                  if (controladorTexto.text != "") {
                    for (int i = 0; i < snapshot.data["results"].length; i++) {
                      if (snapshot.data["results"][i]["poi"] != null) {
                        strNome = snapshot.data['results'][i]['poi']['name'];
                        strEnd = snapshot.data["results"][i]["address"]
                            ["freeformAddress"];
                        categoria =
                            snapshot.data["results"][i]["poi"]["categories"][0];
                        latitudeDoItem =
                            snapshot.data["results"][i]["position"]["lat"];
                        longitudeDoItem =
                            snapshot.data["results"][i]["position"]["lon"];
                        enderecos.add(strEnd);
                        nomes.add(strNome);
                        latitudes.add(latitudeDoItem);
                        longitudes.add(longitudeDoItem);
                      }

                      distanciaEntreDoisPontos(latitudeDoItem, longitudeDoItem);

                      

                      if (categoria != null || categoria != "") {
                        categorias.add(categoria);
                      }
                    }

                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          valores(nomes, enderecos, categorias, latitudes,
                              longitudes, distancias)
                        ],
                      ),
                    );
                  } // IF end
                  else  {
                    return Text(
                        "Não foi encontrado nada para ${controladorTexto.text} :(");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


Widget valores(
    List<String> nomes,
    List<String> enderecos,
    List<String> categorias,
    List<double> latitudes,
    List<double> longitudes,
    List<double> distancias
    )
    {
  List<Widget> cartoes = new List<Widget>();

  for (var i = 0; i < nomes.length; i++) {
    cartoes.add(
      Card(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
              Text(
                "${nomes[i]}",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Endereço: ${enderecos[i]}\n" +
                    "Categoria: ${categorias[i]} \nDistância: aprox. ${distancias[i].round() / 1000} Km.",
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
