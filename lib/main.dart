import 'package:flutter/material.dart';
import 'dbhelper.dart';
import 'ListDetailPage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  //Initialisierung des Notification-Plugin (awesome_notification)
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'default',
            channelName: 'Default Notifications',
            channelDescription:
            'Default Notification Channel for General Information',
            defaultColor: Colors.redAccent,
            ledColor: Colors.white)
      ],
      debug: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Lern-Erinnerungs-App',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

const List<Widget> prio = <Widget>[Text('Grün'), Text('Gelb'), Text('Rot')];

class _HomePageState extends State<HomePage> {
  // alle Erinnerungen initialisieren
  List<Map<String, dynamic>> _exams = [];

  //Toggle-Button Vorauswahl
  final List<bool> _selected = <bool>[true, false, false];

  // "aktualisieren"/holen der Erinnerungen
  void _refreshLists() async {
    final data = await SQLHelper.getLists();
    setState(() {
      _exams = data;
    });
  }

  // Laden der Erinnerungen beim Start der App
  @override
  void initState() {
    super.initState();
    _refreshLists();
  }

  //Controller für Titel, Datum, ...
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late final TextEditingController _prioController = TextEditingController();
  final TextEditingController _artController = TextEditingController();
  final TextEditingController _ectsController = TextEditingController();

//Ausgabe des Formulars zum Anlegen einer Erinnerung
  Future<void> _showForm(int? id) async {
    //Abfrage, ob Erinnerung bereits existiert
    if (id != null) {
      //laden der vorhandenen Inhalte der Erinnerung
      final existingLists = _exams.firstWhere((element) => element['id'] == id);
      _nameController.text = existingLists['name'];
      _dateController.text = existingLists['date'];
      _prioController.text = existingLists['prio'];
      _artController.text = existingLists['art'];
      _ectsController.text = existingLists['ects'];
    }

    //Aufbau Formular zum Erstellen und Bearbeiten
    showModalBottomSheet(
        backgroundColor: const Color(0xFF1C1C1C),
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 50,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          //Textfelder mit Eingabe
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Name',
                  ),
                ),
                //Eingabe des Datums mit DatePicker, jedoch nicht funktionsfähig
                /*TextField(
                    readOnly: true,
                    controller: _dateController,
                    decoration: const InputDecoration(hintText: 'Wähle das Datum'),
                    onTap: () async {
                      var date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100));
                    },
                  ),*/
                TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Datum (YYYY-MM-DD)',
                  ),
                ),
                TextField(
                  controller: _artController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Art der Prüfungsleistung',
                  ),
                ),
                TextField(
                  controller: _ectsController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Ects',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Potentielle Schwierigkeit der Prüfungsleistung:",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //Button mit 3 Möglichkeiten zur Wahl der potentiellen Schwierigkeit
                ToggleButtons(
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < _selected.length; i++) {
                        _selected[i] = i == index;
                        _prioController.text = index.toString();
                      }
                    });
                  },
                  borderRadius:
                  const BorderRadius.all(Radius.circular(15.0)),
                  selectedBorderColor: const Color(0xFF00960a),
                  selectedColor: Colors.white70,
                  fillColor: const Color(0xFF00960a),
                  color: Colors.white70,
                  constraints: const BoxConstraints(
                    minHeight: 40.0,
                    minWidth: 80.0,
                  ),
                  isSelected: _selected,
                  children: prio,
                ),
                const SizedBox(
                  height: 10,
                ),
                //Button, speichern/erstellen
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white70,
                    elevation: 7,
                  ),
                  onPressed: () async {
                    deleteReminder(_nameController.text);

                    // Erinnerung hinzufügen, falls die id noch nicht vorhanden (null) ist
                    if (id == null) {
                      await _addList();
                    }
                    //Erinnerung updaten, falls die id vorhanden (ungleich null) ist
                    if (id != null) {
                      await _updateList(id);
                    }

                    //leeren der Textfelder
                    _nameController.text = '';
                    _dateController.text = '';
                    _prioController.text = '';
                    _artController.text = '';
                    _ectsController.text = '';

                    Navigator.of(context).pop();
                  },
                  //Abfrage, welcher Text der Button anzeigt (wenn die id null ist, wird eine neue Erinnerung erstellt --> "create new"
                  child: Text(id == null ? 'Create New' : 'Update'),
                )
              ],
            ),
          ),
        ));
  }

// Neue Erinnerung zur Datenbank hinzufügen
  Future<void> _addList() async {
    //Erinnerung erstellen mit den EInträgen der Controller
    await SQLHelper.createList(_nameController.text, _dateController.text,
        _prioController.text, _artController.text, _ectsController.text);
    createReminder(_nameController.text, _dateController.text);
    _refreshLists();
  }

// Erinnerung updaten
  Future<void> _updateList(int id) async {
    //Erinnerung mit ausgewählter id updaten
    await SQLHelper.updateList(id, _nameController.text, _dateController.text,
        _prioController.text, _artController.text, _ectsController.text);
    createReminder(_nameController.text, _dateController.text);
    _refreshLists();
  }

// Erinnerung löschen
  void _deleteList(int id) async {
    #
    //Liste mit der ausgewählten id löschen
    await;
    SQLHelper.deleteList(id);
    //SnackBar mit der Nachricht, dass die Liste erfolgreich gelöscht wurde
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Successfully deleted a reminder!'),
    ));
    _refreshLists();
  }

  //Anzeige der Abfrage, ob Erinnerung wirklich gelöscht werden soll
  void _deleteItemConfirmation(int id, String name) async {
    //Dialogbox mit Abfrage
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: const Color(0xFF1C1C1C),
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to delete the reminder?'),
            actions: [
              TextButton(
                //Löschen der Liste und der Notification
                  onPressed: () {
                    _deleteList(id);
                    Navigator.of(context).pop();
                    deleteReminder(name);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00960a), // Text Color
                  ),
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF4646), // Text Color
                  ),
                  child: const Text('No'))
            ],
          );
        });
  }

  //Aufruf der Erinnerungs-Detailseite durch drücken auf die jeweilige card
  void _listTap(BuildContext context, int index) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ListDetailPage(_exams[index]['id'])));
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

  //Aufbau der Erinnerungsanzeige
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      //Appbar
      appBar: AppBar(
        title: const Text('Lern-Erinnerungen'),
        backgroundColor: const Color(0xFF1C1C1C),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        tooltip: 'Add exam',
        backgroundColor: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: const Icon(
          Icons.add,
          size: 34,
        ),
      ),
      body: ListView.builder(
        itemCount: _exams.length,
        itemBuilder: (context, index) => Card(
          color: Color(_colorCard(_exams[index]['prio'])),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.white54,
          margin: const EdgeInsets.all(12),
          child: ListTile(
              title: Text(_exams[index]['name']),
              subtitle: Text(_exams[index]['date']),
              onTap: () => _listTap(context, index),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    //Bearbeiten Button
                    IconButton(
                      tooltip: "Edit Reminder",
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showForm(_exams[index]['id']),
                    ),
                    //Löschen Button
                    IconButton(
                      tooltip: "Delete Reminder",
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteItemConfirmation(
                          _exams[index]['id'], _exams[index]['name']),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  //Erstellung einer Notification, Version bei der nach <Array> Tagen eine Noticication erstellt wird
  /*Future<void> createReminder(String name, String date) async {
    AwesomeNotifications().setChannel(NotificationChannel(
        channelKey: name, channelName: name, channelDescription: name));
    //Array mit Tagen, für wann eine jeweilige Notification erstellt werden soll
    [2, 3, 8, 15]
        .map((counter) => DateTime.parse(date).subtract(Duration(days: counter)))
        .forEach((counter) async => AwesomeNotifications().createNotification(
      //Inhalt Notification
            content: NotificationContent(
                id: counter.hashCode,
                channelKey: name,
                wakeUpScreen: true,
                title: "Klausur: $name",
                body: "Heute schon gelernt?",
                 color: Colors.red),
            //"Antwort" auf Notification (ohne Funktion)
            actionButtons: [
              NotificationActionButton(
                key: 'MARK_DONE',
                label: 'Na klar!',
              )
            ],
            schedule: NotificationCalendar.fromDate(
                date: counter.subtract(const Duration(hours: 5)))));
  }
   */

  //Erstellung einer Notification, Test-Version bei in <Array> Sekunden eine Noticication erstellt wird
  Future<void> createReminder(String name, String date) async {
    AwesomeNotifications().setChannel(NotificationChannel(
        channelKey: name, channelName: name, channelDescription: name));
    //Array mit Tagen, für wann eine jeweilige Notification erstellt werden soll
    [2, 15]
        .map((counter) => DateTime.now().add(Duration(seconds: counter)))
        .forEach((counter) async => AwesomeNotifications().createNotification(
      //Inhalt Notification
        content: NotificationContent(
            id: counter.hashCode,
            channelKey: name,
            wakeUpScreen: true,
            title: "Klausur: $name",
            body: "Heute schon gelernt?",
            backgroundColor: Colors.red),
        //"Antwort" auf Notification (ohne Funktion)
        actionButtons: [
          NotificationActionButton(
            key: 'MARK_DONE',
            label: 'Na klar!',
          )
        ],
        schedule: NotificationCalendar.fromDate(
            date: counter)));
  }
  //Löschen von Notification
  void deleteReminder(String name) {
    AwesomeNotifications().cancelNotificationsByChannelKey(name);
    AwesomeNotifications().removeChannel(name);
  }
}
