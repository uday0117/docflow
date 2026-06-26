import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RecentFile {
  final String id;
  final String name;
  final String path;
  final String tool;
  final String toolLabel;
  final DateTime createdAt;

  const RecentFile({
    required this.id,
    required this.name,
    required this.path,
    required this.tool,
    required this.toolLabel,
    required this.createdAt,
  });

  bool get exists => File(path).existsSync();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'tool': tool,
        'toolLabel': toolLabel,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
        id: json['id'] as String,
        name: json['name'] as String,
        path: json['path'] as String,
        tool: json['tool'] as String,
        toolLabel: json['toolLabel'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );
}

class RecentFilesService extends GetxService {
  static RecentFilesService get to => Get.find<RecentFilesService>();

  static const _key = 'recent_files_v2';
  static const _maxEntries = 20;

  final _box = GetStorage();
  final RxList<RecentFile> files = <RecentFile>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    final raw = _box.read<List>(_key);
    if (raw == null) return;
    final loaded = raw
        .map((e) => RecentFile.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((f) => f.exists)
        .toList();
    files.assignAll(loaded);
  }

  void addFile({
    required String path,
    required String tool,
    required String toolLabel,
  }) {
    final file = File(path);
    if (!file.existsSync()) return;

    final entry = RecentFile(
      id: '${tool}_${DateTime.now().millisecondsSinceEpoch}',
      name: path.split('/').last,
      path: path,
      tool: tool,
      toolLabel: toolLabel,
      createdAt: DateTime.now(),
    );

    files.removeWhere((f) => f.path == path);
    files.insert(0, entry);
    if (files.length > _maxEntries) {
      files.removeRange(_maxEntries, files.length);
    }
    _save();
  }

  void removeFile(String id) {
    files.removeWhere((f) => f.id == id);
    _save();
  }

  void _save() {
    _box.write(_key, files.map((f) => f.toJson()).toList());
  }
}
