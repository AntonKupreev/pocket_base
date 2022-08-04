import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter_pocket_base/config.dart' as config;
import 'package:flutter_pocket_base/sdk/pocketdb/PocketBase.dart';
import 'package:flutter_pocket_base/sdk/pocketdb/protocol.dart';
import 'package:flutter_pocket_base/ui/screen/video_file.dart';

class MainScreen extends StatefulWidget {
  final PocketBase _client;

  const MainScreen(this._client, {super.key});

  @override
  State<MainScreen> createState() => _MainScreen(_client);
}

class _MainScreen extends State<MainScreen> {
  final PocketBase _client;
  final List<MediaFile> _mediaFiles = [];

  _MainScreen(this._client);

  @override
  void initState() {
    super.initState();
    _fetchFileList().then((value) => {setState(() {})});

    _client.subscribe(
        config.collectionName,
        () => {
              _fetchFileList().then((value) => {setState(() {})})
            });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              onTap: (index) {
                if (index == 0) {
                  _openFilePickerAnUploadFile();
                }
              },
              tabs: [
                Tab(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: const Text(
                      'DownLoad',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            centerTitle: true,
            title: const Text('Pocket base'),
          ),
          body: _BodyList(_client, _mediaFiles),
        ),
      ),
    );
  }

  Future<void> _fetchFileList() async {
    final result = await _client.list(config.collectionName);
    _mediaFiles.clear();
    for (final item in result.items) {
      _mediaFiles.add(MediaFile(
          _client.filePath(config.collectionName, item), item.name, item.id));
    }
  }

  _openFilePickerAnUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      withReadStream: true,
      withData: false,
      allowedExtensions: config.uploadFilesExtensions,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      await _client.upload(config.collectionName, file);
    }
  }
}

class _BodyList extends StatelessWidget {
  final PocketBase _client;
  final List<MediaFile> _mediaFiles;

  const _BodyList(this._client, this._mediaFiles, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _mediaFiles.length,
      itemBuilder: ((context, index) {
        return InkWell(
          onTap: () {
            Route route = MaterialPageRoute(
                builder: (context) => VideoFile(_client, _mediaFiles[index]));
            Navigator.push(context, route);
          },
          child: Card(
            child: ListTile(
              title: Text(
                _mediaFiles[index].name,
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              leading: const Icon(
                Icons.video_camera_front,
              ),
            ),
          ),
        );
      }),
    );
  }
}
