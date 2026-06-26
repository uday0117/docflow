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

  /// Returns a user-accessible downloads folder for DocFlow output files.
  /// On Android this is the app's external storage; on iOS it falls back to
  /// the app documents directory (accessible via Files app).
  static Future<Directory> getDownloadsDirectory() async {
    Directory? base;

    if (Platform.isAndroid) {
      base = await getExternalStorageDirectory();
    }
    base ??= await getApplicationDocumentsDirectory();

    final dir = Directory('${base.path}/DocFlow');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Copies [source] to the downloads folder and returns the saved [File].
  static Future<File> saveToDownloads(File source) async {
    final dir = await getDownloadsDirectory();
    final name = source.path.split('/').last;
    final dest = File('${dir.path}/$name');
    return source.copy(dest.path);
  }
}
