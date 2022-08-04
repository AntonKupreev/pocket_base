import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_pocket_base/sdk/pocketdb/PocketBase.dart';
import 'package:flutter_pocket_base/sdk/pocketdb/protocol.dart';
import 'package:flutter_pocket_base/ui/screen/main_screen.dart';

import 'package:video_player/video_player.dart';
import 'package:flutter_pocket_base/config.dart' as config;

class VideoFile extends StatelessWidget {
  final PocketBase _client;
  final MediaFile _mediaFile;

  const VideoFile(this._client, this._mediaFile, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Video'),
        ),
        body: _VideoWidget(_client, _mediaFile),
      ),
    );
  }
}

class _VideoWidget extends StatefulWidget {
  final PocketBase _client;
  final MediaFile _mediaFile;

  const _VideoWidget(this._client, this._mediaFile, {Key? key})
      : super(key: key);

  @override
  State<_VideoWidget> createState() => __VideoWidgetState(_client, _mediaFile);
}

class __VideoWidgetState extends State<_VideoWidget> {
  final PocketBase _client;
  final MediaFile _mediaFile;
  late VideoPlayerController _videoController;

  __VideoWidgetState(this._client, this._mediaFile);

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.network(_mediaFile.url)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            width: 350,
            height: 250,
            //color: Colors.amber,
            child: _createVideoWidget(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              iconSize: 80,
              onPressed: () async {
                await _showTextInputDialog(context);
              },
              icon: const Icon(
                Icons.create,
              ),
            ),
            const SizedBox(
              width: 30,
            ),
            IconButton(
              iconSize: 80,
              onPressed: () {
                _videoController.value.isPlaying
                    ? _videoController.pause()
                    : _videoController.play();
                setState(() {});
              },
              icon: Icon(_videoController.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow),
            ),
            const SizedBox(
              width: 30,
            ),
            IconButton(
              iconSize: 80,
              onPressed: () async {
                Navigator.pop(
                  context,
                  MainScreen(_client),
                );
                await _client.delete(config.collectionName, _mediaFile.id);
                setState(() {});
              },
              icon: const Icon(
                Icons.delete_forever,
              ),
            ),
          ],
        )
      ],
    );
  }

  final _textFieldController = TextEditingController();
  Future<String?> _showTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Изменить название видео'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: _mediaFile.name),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("Отмена"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                  child: const Text('Сохранить'),
                  onPressed: () async {
                    Navigator.pop(context, _textFieldController.text);
                    await _client.update(config.collectionName, _mediaFile.id,
                        _textFieldController.text);
                    setState(() {});
                  }),
            ],
          );
        });
  }

  Widget _createVideoWidget() {
    final controller = _videoController;
    if (controller != null) {
      if (controller.value.isInitialized) {
        return AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        );
      }
    }
    return Container();
  }
}
