// Профили в локальном JSON. Файл не содержит паролей.
import 'dart:convert';
import 'dart:io';

import '../../domain/entities/server_profile.dart';
import '../../domain/repositories/server_repository.dart';

class FileServerRepository implements ServerRepository {
  FileServerRepository(this._file);

  final File _file;

  @override
  Future<List<ServerProfile>> list() async {
    final raw = await _read();
    return raw.map(ServerProfile.fromJson).toList();
  }

  @override
  Future<ServerProfile?> findById(String id) async {
    final profiles = await list();
    for (final profile in profiles) {
      if (profile.id == id) {
        return profile;
      }
    }
    return null;
  }

  @override
  Future<void> save(ServerProfile profile) async {
    final profiles = await list();
    final index = profiles.indexWhere((item) => item.id == profile.id);
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }
    await _write(profiles);
  }

  @override
  Future<void> delete(String id) async {
    final profiles = await list();
    profiles.removeWhere((item) => item.id == id);
    await _write(profiles);
  }

  Future<List<Map<String, Object?>>> _read() async {
    if (!await _file.exists()) {
      return [];
    }
    final content = await _file.readAsString();
    if (content.trim().isEmpty) {
      return [];
    }
    final decoded = jsonDecode(content);
    if (decoded is! List) {
      throw const FormatException('server store is not a list');
    }
    return decoded.map((item) => Map<String, Object?>.from(item as Map)).toList();
  }

  Future<void> _write(List<ServerProfile> profiles) async {
    await _file.parent.create(recursive: true);
    final payload = jsonEncode(profiles.map((profile) => profile.toJson()).toList());
    final temporary = File('${_file.path}.tmp');
    await temporary.writeAsString(payload);
    if (await _file.exists()) {
      await _file.delete();
    }
    await temporary.rename(_file.path);
  }
}
