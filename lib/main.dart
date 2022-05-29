import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lecteur_musique/musique.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FD Musique',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'FD Musique'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Musique> listeMusique = [
    new Musique('Mise à jour', 'lefa', 'assets/un.jpg', ' assets/avc.mp3'),
    new Musique('AVC', 'lefa', 'assets/un.jpg', ' assets/newLife.mp3'),
  ];
  late Musique maMusique;

  late Duration position = new Duration(seconds: 0);
  late Duration duree = new Duration(seconds: 10);
  late PlayerState statut = PlayerState.stoped;
  late AudioPlayer audioPlayer;
  late StreamSubscription positionSub;
  late StreamSubscription stateSubscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    maMusique = listeMusique[0];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
          backgroundColor: Colors.grey[900]),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: Container(
                width: MediaQuery.of(context).size.height / 3,
                child: new Image.asset(maMusique.imgPath),
              ),
            ),
            textAvecStyle(maMusique.titre, 1.5),
            textAvecStyle(maMusique.artiste, 1.5),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                bouton(Icons.fast_rewind, 30.0, actionMusique.rewind),
                bouton(
                    (statut == PlayerState.playing)
                        ? Icons.pause
                        : Icons.play_arrow,
                    45.0,
                    (statut == PlayerState.playing)
                        ? actionMusique.pause
                        : actionMusique.play),
                bouton(Icons.fast_forward, 30.0, actionMusique.forward),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [textAvecStyle('0:0', 1.0), textAvecStyle('0:0', 1.0)],
            ),
            new Slider(
                value: position.inSeconds.toDouble(),
                inactiveColor: Colors.white,
                activeColor: Colors.blue,
                min: 0.0,
                max: 30.0,
                onChanged: (double d) {
                  setState(() {
                    Duration nouvelleDuration =
                        new Duration(seconds: d.toInt());
                    position = nouvelleDuration;
                  });
                })
          ],
        ),
      ),
    );
  }

  Text textAvecStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
          color: Colors.white, fontSize: 20.0, fontStyle: FontStyle.normal),
    );
  }

  IconButton bouton(IconData icon, double taille, actionMusique action) {
    return new IconButton(
        iconSize: taille,
        color: Colors.white,
        onPressed: () {
          switch (action) {
            case actionMusique.play:
              play();
              break;
            case actionMusique.pause:
              pause();
              break;
            case actionMusique.rewind:
              print('rewind');
              break;
            case actionMusique.forward:
              print('forword');
          }
        },
        icon: new Icon(icon));
  }

  void configurationAudioPlayer() {
    AudioPlayer audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged
        .listen((pos) => setState(() => position = pos));
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        setState(() {
          duree = audioPlayer.getDuration() as Duration;
        });
      } else if (state == PlayerState.stoped) {
        setState(() {
          statut = PlayerState.stoped;
        });
      }
    }, onError: (message) {
      print('message:$message');
      setState(() {
        statut = PlayerState.stoped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(maMusique.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }
}

enum actionMusique { play, pause, rewind, forward }
enum PlayerState { playing, stoped, paused }
