import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileStorageService {
  static Future<Directory> getDocFlowDirectory() async {
    final directory = await getApplicationDocumentsDirectory();

    final docFlowDir = Directory('${directory.path}/DocFlow');

    if (!await docFlowDir.exists()) {
      await docFlowDir.create(recursive: true);
    }

    return docFlowDir;
  }
}
