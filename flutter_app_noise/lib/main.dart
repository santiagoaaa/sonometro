import 'dart:ffi';

import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isRecording = false;
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter;
  int DB = 0;
  int contador=0;
  String DBstring = "0";
  int cantMedi = 20;
  var lista = new List();

  @override
  void initState() {
    super.initState();
  }

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }
    });

      DB = noiseReading.db.toInt();
      DBstring = '$DB';
      lista.add(DBstring);
      //print(DB);
      contador++;
      //print ('iteraciones $contador');

      if (contador == cantMedi){
        //print("Llegamos a 10!!!!!!!!!");
        print("Lecturas obtenidas");
        print (lista);
        stopRecorder();
      }
  }

  void startRecorder() async {
    print('***NEW RECORDING***');
    try {
      _noiseMeter = new NoiseMeter();
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } on NoiseMeterException catch (exception) {
      print(exception);
    }
  }

  void stopRecorder() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  /*Cosas que van en la interfaz*/
  final logo = Hero(
    tag: 'hero',
    child: CircleAvatar(
      backgroundColor: Colors.lightGreen,
      radius: 48.0,
      child: Image.asset("img/logo.png")
    ),
  );


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              logo,
              SizedBox(height: 90),
              Text(
                'Estación de Medición de Ruido',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 30),
              Text(
                  '$DBstring dBA',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 30),
              FAProgressBar(
                //animatedDuration: Duration(milliseconds: 500),
                maxValue: 100,
                currentValue: DB.toInt(),
                displayText: ' dBA',
                changeColorValue: 70,
                changeProgressColor: Colors.red,
                progressColor: Colors.green,
              ),



            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightGreen,
            onPressed: () {
              contador = 0;
              lista.clear();
              if (!this._isRecording) { //NO verdadero = falso, NO falso = verdadero
                return this.startRecorder();
              }

              this.stopRecorder();


            },
            child: Icon(this._isRecording ? Icons.stop : Icons.mic)),
      ),
    );
  }
}