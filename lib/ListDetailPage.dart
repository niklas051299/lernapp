import 'package:flutter/material.dart';
import 'dbhelper.dart';

class ListDetailPage extends StatefulWidget {
  final int id;

  const ListDetailPage(this.id, {Key? key}) : super(key: key);

  @override
  _ListDetailPageState createState() => _ListDetailPageState(id);
}

class _ListDetailPageState extends State<ListDetailPage> {
  final int id;

  _ListDetailPageState(this.id);

  List<Map<String, dynamic>> _exams = [];

  // "aktualisieren" der Erinnerungen
  void _refreshLists() async {
    //holen der Erinnerungen
    final data = await SQLHelper.getList(id);
    setState(() {
      _exams = data;
    });
  }

  // laden der Erinnerungen beim Start der App
  @override
  void initState() {
    super.initState();
    _refreshLists();
  }

  //Farben für Ausgabe der Cards mit der jeweiligen gewählten Schwierigkeit/Farbe
  int _colorCard(String prio) {
    if (prio.contains('0')) {
      return 0xFF00960a;
    } else if (prio.contains('1')) {
      return 0xFFFFC300;
    } else {
      return 0xFFFF4646;
    }
  }

  //Aufbau der Ausgabe der gespeichertten Informationen einer Erinnerung
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text(_exams[0]['name']),backgroundColor: Color(_colorCard(_exams[0]['prio']))),
      body: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            //Ausgabe der gespeicherten Informationen in Tabellenform
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(120),
                1: FixedColumnWidth(500),
              },
              children: [
                TableRow(children: [
                  const Text("Datum: ", textScaleFactor: 1.6, style: TextStyle(color: Colors.white),),
                  Text(_exams[0]['date'], textScaleFactor: 1.6, style: const TextStyle(color: Colors.white),),
                ]),
                TableRow(children: [
                  const Text("Art: ", textScaleFactor: 1.6, style: TextStyle(color: Colors.white),),
                  Text(_exams[0]['art'], textScaleFactor: 1.6, style: const TextStyle(color: Colors.white),),
                ]),
                TableRow(children: [
                  const Text("ECTS: ", textScaleFactor: 1.6, style: TextStyle(color: Colors.white),),
                  Text(_exams[0]['ects'], textScaleFactor: 1.6, style: const TextStyle(color: Colors.white),),
                ]),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
