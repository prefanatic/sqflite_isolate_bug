import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart' as sql;

Future<void> createInsertAndQuery() async {
  final isolateId = Service.getIsolateID(Isolate.current);

  print('running on $isolateId');

  sql.Sqflite.setDebugModeOn(true);
  final database = await sql.openDatabase(
    sql.inMemoryDatabasePath,
    version: 1,
    onCreate: (database, ver) async {
      print('opened version: $ver');

      await database
          .execute('CREATE TABLE test(id int primary key, blob text);');
    },
  );

  final currentTime = DateTime.now();
  await database.insert(
    'test',
    {'id': 0, 'blob': '${currentTime.toIso8601String()}'},
    conflictAlgorithm: sql.ConflictAlgorithm.replace,
  );

  final message = await database.query('test');
  final blob = message.first['blob'];
  assert(blob == currentTime.toIso8601String());

  print('success, $blob');
}

void backgroundEntrypoint() {
  WidgetsFlutterBinding.ensureInitialized();

  createInsertAndQuery();
}

const _methodChannel = MethodChannel('com.example.sqflite/backgrounded');
Future<void> backgroundedCreateAndInsertQuery() {
  final CallbackHandle handle =
      PluginUtilities.getCallbackHandle(backgroundEntrypoint);

  return _methodChannel.invokeMethod('', [handle.toRawHandle()]);
}

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Foreground Isolate'),
              onPressed: () async {
                await createInsertAndQuery();
              },
            ),
            const SizedBox(height: 24.0),
            RaisedButton(
              child: Text('Background Isolate'),
              onPressed: () async {
                await backgroundedCreateAndInsertQuery();
              },
            )
          ],
        ),
      ),
    );
  }
}
