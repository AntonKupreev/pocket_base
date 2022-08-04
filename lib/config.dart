import 'package:flutter/foundation.dart' show kIsWeb;

const databaseUrl = kIsWeb ? "http://localhost:8090" : "http://10.0.2.2:8090";

const email = 'anton@anton.com';
const password = '1234567890';

const collectionName = 'db';

const uploadFilesExtensions = ['mp4', 'webm', 'jpeg', 'jpg'];
