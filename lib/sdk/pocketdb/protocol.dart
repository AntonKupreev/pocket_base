class AuthRequest {
  final String email;
  final String password;

  AuthRequest(this.email, this.password);

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class AuthResponse {
  final String token;

  AuthResponse(this.token);

  factory AuthResponse.fromJson(dynamic json) {
    return AuthResponse(json['token'] as String);
  }
}

class ListItem {
  final String created;
  final String updated;
  final String id;
  final String name;
  final String file;

  ListItem(this.created, this.updated, this.id, this.name, this.file);

  factory ListItem.fromJson(dynamic json) {
    return ListItem(
      json['created'] as String,
      json['updated'] as String,
      json['id'] as String,
      json['name'] as String,
      json['file'] as String,
    );
  }
}

class ListResponse {
  final int page;
  final int perPage;
  final int totalItems;
  final List<ListItem> items;

  ListResponse(this.page, this.perPage, this.totalItems, this.items);

  factory ListResponse.fromJson(dynamic json) {
    final items = json["items"] as List<dynamic>;
    final List<ListItem> resultItems = [];

    for (final item in items) {
      resultItems.add(ListItem.fromJson(item));
    }

    return ListResponse(
        json['page'] as int,
        json['perPage'] as int,
        json['totalItems'] as int,
        resultItems);
  }
}

class SubscriptionRequest {
  final String clientId;
  final List<String> subscriptions;

  SubscriptionRequest(this.clientId, this.subscriptions);

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'subscriptions': subscriptions,
  };

}

class SseEvent{
  final String? id;
  final String? event;
  final String? data;

  SseEvent(this.id, this.event, this.data);

  @override
  String toString() {

    return '{id:$id, event:$event, data:$data}';
  }
}

class SseProtocol {
  final String key;
  final String value;

  SseProtocol(this.key, this.value);
}

class SubscriptionEventDBRecord {
  final String id;
  final String file;
  final String name;

  SubscriptionEventDBRecord(this.id, this.file, this.name);

  factory SubscriptionEventDBRecord.fromJson(dynamic json) {
    return SubscriptionEventDBRecord(
      json['id'] as String,
      json['file'] as String,
      json['name'] as String,
    );
  }
}

class SubscriptionEventData {
  final String action;
  final SubscriptionEventDBRecord record;

  SubscriptionEventData(this.action, this.record);

  factory SubscriptionEventData.fromJson(dynamic json) {
    return SubscriptionEventData(
      json['action'] as String,
      SubscriptionEventDBRecord.fromJson(json['record']),
    );
  }

}

class MediaFile {
  final String url;
  final String name;
  final String id;

  MediaFile(this.url, this.name, this.id);
}

