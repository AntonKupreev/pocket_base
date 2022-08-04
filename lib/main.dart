import 'package:flutter/material.dart';
import 'package:flutter_pocket_base/sdk/pocketdb/PocketBase.dart';
import 'package:flutter_pocket_base/ui/screen/main_screen.dart';
import 'package:flutter_pocket_base/config.dart' as config;

void main() {
  final client = PocketBase(config.databaseUrl);

  client
      .authByEmail(config.email, config.password)
      .then((value) => {runApp(MyApp(client))});
}

class MyApp extends StatelessWidget {
  final PocketBase _client;

  const MyApp(this._client, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(_client),
    );
  }
}
