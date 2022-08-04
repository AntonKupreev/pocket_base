import 'dart:convert';
import 'package:flutter_pocket_base/sdk/pocketdb/protocol.dart';
import 'package:http/http.dart' as http;

class SseClient {
  final String _url;
  final Map<String, String> _headers;
  String _lastId = '';

  SseClient(this._url, this._headers);

  subscribe(String collection, Function callback) async {
    print("Start SSE");

    final url = Uri.parse('$_url/api/realtime');
    final request = http.Request("GET", url);

    final response = await http.Client().send(request);

    if (response.statusCode >= 400) {
      final responseStr = await response.stream.bytesToString();
      final responseData = responseStr != "" ? jsonDecode(responseStr) : null;
      throw Exception('Failed to subscribe to PocketBase: $responseData');
    }

    String? id;
    String? event;
    String? data;

    response.stream
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())
        .listen((line) {
      if (line.isEmpty) {
        return;
      }
      final protocol = _parseSseProtocol(line);
      final type = protocol.key;
      final data = protocol.value;

      if (type == 'data') {
        final sseEvent = SseEvent(id, event, data);
        _onReceiveSseEvent(sseEvent, collection, callback);
      } else if (type == 'id') {
        _lastId = data;
        id = data;
      } else if (type == 'event') {
        event = data;
      }
      print('Received line:$line');
    });
    print("All ok");
  }

  _onReceiveSseEvent(SseEvent event, String collection, Function callback) {
    print('Receive sse event:$event');

    if (event.event == 'PB_CONNECT') {
      _sendSubscription(_lastId, [collection]);
    } else {
      try {
        //final data = SubscriptionEventData.fromJson(event.data);
        callback();
      } catch (e) {
        print('Something wrong with data: $e');
      }
    }
  }

  _sendSubscription(String clientId, List<String> subscribers) async {
    final api = Uri.parse('$_url/api/realtime');
    final request = SubscriptionRequest(clientId, subscribers);

    final response = await http.post(api,
        headers: _headers, body: jsonEncode(request.toJson()));

    print(response.statusCode);

    if (response.statusCode != 204) {
      throw Exception("Failed to auth");
    }

    print("Subscribed");
  }

  SseProtocol _parseSseProtocol(String line) {
    int idx = line.indexOf(":");
    return SseProtocol(line.substring(0, idx), line.substring(idx + 1));
  }
}
