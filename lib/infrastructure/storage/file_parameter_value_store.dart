// Локальные значения параметров. Каталог команд этот файл не читает.
import 'dart:convert';
import 'dart:io';

import '../../domain/repositories/parameter_value_store.dart';
import 'file_mutex.dart';

class FileParameterValueStore implements ParameterValueStore {
  FileParameterValueStore(this._file);

  final File _file;

  @override
  Future<Map<String, String>> read(String profileId, String scriptId) {
    return FileMutex.synchronized(_file.path, () async {
      final data = await _read();
      final entry = data['$profileId::$scriptId'];
      if (entry is! Map) return const {};
      return {
        for (final item in entry.entries)
          if (item.key is String && item.value is String) item.key as String: item.value as String,
      };
    });
  }

  @override
  Future<void> save(String profileId, String scriptId, Map<String, String> values) {
    return FileMutex.synchronized(_file.path, () async {
      final data = await _read();
      final kept = {
        for (final item in values.entries)
          if (item.value.trim().isNotEmpty) item.key: item.value.trim(),
      };
      if (kept.isEmpty) {
        data.remove('$profileId::$scriptId');
      } else {
        data['$profileId::$scriptId'] = kept;
      }
      await _write(data);
    });
  }

  Future<Map<String, Object?>> _read() async {
    if (!await _file.exists()) return {};
    final decoded = jsonDecode(await _file.readAsString());
    if (decoded is! Map) return {};
    final values = decoded['values'];
    if (values is! Map) return {};
    return Map<String, Object?>.from(values);
  }

  Future<void> _write(Map<String, Object?> values) async {
    final parent = _file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    final payload = jsonEncode({'version': 1, 'values': values});
    final temporary = File('${_file.path}.tmp');
    await temporary.writeAsString(payload);
    try {
      await temporary.rename(_file.path);
    } on FileSystemException {
      await _file.writeAsString(payload);
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
