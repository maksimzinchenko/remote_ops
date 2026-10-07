// Доверенные отпечатки в локальном JSON.
import 'dart:convert';
import 'dart:io';

import '../../domain/entities/stored_host_key.dart';
import '../../domain/repositories/host_key_store.dart';

class FileHostKeyStore implements HostKeyStore {
  FileHostKeyStore(this._file);

  final File _file;

  @override
  Future<StoredHostKey?> find(String host, int port) async {
    final keys = await _read();
    for (final key in keys) {
      if (key.host == host && key.port == port) {
        return key;
      }
    }
    return null;
  }

  @override
  Future<void> save(StoredHostKey key) async {
    final keys = await _read();
    final index = keys.indexWhere((item) => item.host == key.host && item.port == key.port);
    if (index >= 0) {
      keys[index] = key;
    } else {
      keys.add(key);
    }
    await _write(keys);
  }

  @override
  Future<void> delete(String host, int port) async {
    final keys = await _read();
    keys.removeWhere((item) => item.host == host && item.port == port);
    await _write(keys);
  }

  Future<List<StoredHostKey>> _read() async {
    if (!await _file.exists()) {
      return [];
    }
    final content = await _file.readAsString();
    if (content.trim().isEmpty) {
      return [];
    }
    final decoded = jsonDecode(content);
    if (decoded is! List) {
      throw const FormatException('host key store is not a list');
    }
    return decoded
        .map((item) => StoredHostKey.fromJson(Map<String, Object?>.from(item as Map)))
        .toList();
  }

  Future<void> _write(List<StoredHostKey> keys) async {
    await _file.parent.create(recursive: true);
    final payload = jsonEncode(keys.map((key) => key.toJson()).toList());
    final temporary = File('${_file.path}.tmp');
    await temporary.writeAsString(payload);
    if (await _file.exists()) {
      await _file.delete();
    }
    await temporary.rename(_file.path);
  }
}
