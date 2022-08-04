import 'package:file_picker/file_picker.dart';
import 'package:flutter_pocket_base/sdk/pocketdb/SseClient.dart';
import 'package:flutter_pocket_base/sdk/pocketdb/protocol.dart';
import 'package:http/http.dart' as http;

import 'dart:convert' as json;

class PocketBase {
  final _headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': ''
  };
  final String _url;

  PocketBase(this._url);

  authByToken(String token) {
    _headers["Authorization"] = token;
  }

  Future<void> authByEmail(String email, String password) async {
    final api = Uri.parse('$_url/api/users/auth-via-email');
    final request = AuthRequest(email, password);

    final response = await http.post(api,
        headers: _headers, body: json.jsonEncode(request.toJson()));

    if (response.statusCode != 200) {
      throw Exception("Failed to auth");
    }

    final result = AuthResponse.fromJson(json.jsonDecode(response.body));

    _headers["Authorization"] = result.token;
  }

  Future<ListResponse> list(String collection) async {
    final url = Uri.parse('$_url/api/collections/$collection/records');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Invalid request');
    }

    final result = ListResponse.fromJson(json.jsonDecode(response.body));
    return result;
  }

  upload(String collection, PlatformFile file) async {
    final url = Uri.parse('$_url/api/collections/$collection/records');

    final fileReadStream = file.readStream;
    if (fileReadStream == null) {
      throw Exception('Cannot read file from null stream');
    }
    final stream = http.ByteStream(fileReadStream);

    final request = http.MultipartRequest('POST', url);
    final multipartFile = http.MultipartFile(
      'file',
      stream,
      file.size,
      filename: file.name,
    );

    request.headers.addAll(_headers);
    request.fields.addAll(<String, String>{'name': file.name});
    request.files.add(multipartFile);

    final httpClient = http.Client();
    final response = await httpClient.send(request);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final body = await response.stream.transform(json.utf8.decoder).join();
    print(body);
  }

  subscribe(String collection, Function callback) async {
    final sseClient = SseClient(_url, _headers);
    sseClient.subscribe(collection, callback);
  }

  delete(String collection, String recordId) async {
    final url =
        Uri.parse('$_url/api/collections/$collection/records/$recordId');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Invalid request');
    }
  }

  update(String collection, String record, String name) async {
    final url = Uri.parse('$_url/api/collections/$collection/records/$record');

    final request = http.MultipartRequest('PATCH', url);

    request.headers.addAll(_headers);
    request.fields.addAll(<String, String>{'name': name});

    final httpClient = http.Client();
    final response = await httpClient.send(request);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final body = await response.stream.transform(json.utf8.decoder).join();
    print(body);
  }

  String filePath(String db, ListItem item) {
    return '$_url/api/files/$db/${item.id}/${item.file}';
  }
}
