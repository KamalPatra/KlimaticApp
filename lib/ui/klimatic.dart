import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../util/utils.dart' as util;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  String _cityEntered;

  Future _gotoNextScreen(BuildContext context) async {
    Map result = await Navigator.of(context)
        .push(MaterialPageRoute<Map>(builder: (BuildContext context) {
      return ChangeCity();
    }));
    
    if (result != null && result.containsKey("enter")){
      _cityEntered = result["enter"];
    }else {
      print("nothing");
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Klimatic",
          style: TextStyle(color: Colors.red, fontSize: 30.0),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            onPressed: () => _gotoNextScreen(context),
            icon: Icon(
              Icons.menu,
              color: Colors.red,
            ),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset("images/umbrella_snow.jpg",
                width: 490.0, height: 1000.0, fit: BoxFit.fill),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: Text(
              "${_cityEntered == null ? util.defaultCity : _cityEntered}",
              style: cityStyle(),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset("images/light_rain.png"),
          ),
          Container(
              margin: const EdgeInsets.fromLTRB(20.0, 450.0, 0.0, 0.0),
              child: updateTempWidget(_cityEntered)),
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiUrl =
        "http://api.openweathermap.org/data/2.5/weather?q=$city&appid=${util.appId}&units=metric";

    http.Response response = await http.get(apiUrl);

    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return FutureBuilder(
        future: getWeather(util.appId, city == null ? util.defaultCity : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            Map content = snapshot.data;
            return new Container(
              child: new Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "${content["main"]["temp"]}".toString() + "ºC",
                      style: tempStyle(),
                    ),
                    subtitle:
                    ListTile(
                    title: Text(
                      "Humidity: ${content["main"]["humidity"].toString()}\n"
                          "Min: ${content["main"]["temp_min"].toString()}ºC\n"
                          "Max: ${content["main"]["temp_min"].toString()}ºC",
                      style: tempMinMaxStyle(),
                    ),
                    ),
                  ),

                ],
              ),
            );
          } else {
            return Container(
              alignment: Alignment.bottomLeft,
            );
          }
        });
  }
}

class ChangeCity extends StatelessWidget {
//  final String name;
//  ChangeCity (Key key, this.name) : super(key : key);
  @override
  Widget build(BuildContext context) {
    var _cityFieldController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Change city",
            style: TextStyle(color: Colors.white, fontSize: 30.0)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              "images/umbrella_rain.jpg",
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          ListView(
            children: <Widget>[
              ListTile(
                title: TextField(
                  style: TextStyle(color: Colors.white, fontSize: 14.9),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.white, fontSize: 30.0),
                    hintStyle: TextStyle(color: Colors.white),
                      labelText: "Enter City", hintText: "Delhi"),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: RaisedButton(
                  child: Text("Check weather"),
                    onPressed: (){
                    Navigator.pop(context, {
                      "enter": _cityFieldController.text
    });
    },
              )
              )
            ],
          ),
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return TextStyle(
      fontSize: 25.0, color: Colors.red, fontStyle: FontStyle.italic,);
}

TextStyle tempStyle() {
  return TextStyle(
      fontSize: 50.0,
      color: Colors.white,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w800);
}

TextStyle tempMinMaxStyle() {
  return TextStyle(
      fontSize: 20.0,
      color: Colors.white,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w800);
}