// Профили в локальном JSON. Файл не содержит паролей.
import 'dart:io';

import '../../domain/entities/server_profile.dart';
import '../../domain/repositories/server_repository.dart';
import 'file_mutex.dart';
import 'server_store_codec.dart';

class FileServerRepository implements ServerRepository {
  FileServerRepository(this._file);

  final File _file;

  @override
  Future<List<ServerProfile>> list() {
    return FileMutex.synchronized(_file.path, _read);
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
  Future<void> save(ServerProfile profile) {
    return FileMutex.synchronized(_file.path, () async {
      final profiles = await _read();
      final index = profiles.indexWhere((item) => item.id == profile.id);
      if (index >= 0) {
        profiles[index] = profile;
      } else {
        profiles.add(profile);
      }
      await _write(profiles);
    });
  }

  @override
  Future<void> delete(String id) {
    return FileMutex.synchronized(_file.path, () async {
      final profiles = await _read();
      profiles.removeWhere((item) => item.id == id);
      await _write(profiles);
    });
  }

  Future<List<ServerProfile>> _read() async {
    if (!await _file.exists()) {
      return [];
    }
    return ServerStoreCodec.decode(await _file.readAsString());
  }

  Future<void> _write(List<ServerProfile> profiles) async {
    await _file.parent.create(recursive: true);
    final temporary = File('${_file.path}.tmp');
    await temporary.writeAsString(ServerStoreCodec.encode(profiles));
    try {
      await temporary.rename(_file.path);
    } on FileSystemException {
      if (await _file.exists()) {
        await _file.delete();
      }
      await temporary.rename(_file.path);
    }
  }
}
