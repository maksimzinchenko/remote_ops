// Доверенные отпечатки в локальном JSON.
import 'dart:io';

import '../../domain/entities/host_endpoint.dart';
import '../../domain/entities/stored_host_key.dart';
import '../../domain/repositories/host_key_store.dart';
import 'file_mutex.dart';
import 'host_key_store_codec.dart';

class FileHostKeyStore implements HostKeyStore {
  FileHostKeyStore(this._file);

  final File _file;

  @override
  Future<StoredHostKey?> find(String host, int port) async {
    final keys = await _readLocked();
    final wanted = endpointKey(host, port);
    for (final key in keys) {
      if (key.endpoint == wanted) {
        return key;
      }
    }
    return null;
  }

  @override
  Future<void> save(StoredHostKey key) {
    return FileMutex.synchronized(_file.path, () async {
      final keys = await _read();
      final normalized = key.copyWith(host: normalizeHost(key.host));
      final index = keys.indexWhere((item) => item.endpoint == normalized.endpoint);
      if (index >= 0) {
        keys[index] = normalized;
      } else {
        keys.add(normalized);
      }
      await _write(keys);
    });
  }

  @override
  Future<void> delete(String host, int port) {
    return FileMutex.synchronized(_file.path, () async {
      final keys = await _read();
      final wanted = endpointKey(host, port);
      keys.removeWhere((item) => item.endpoint == wanted);
      await _write(keys);
    });
  }

  Future<List<StoredHostKey>> _readLocked() => FileMutex.synchronized(_file.path, _read);

  Future<List<StoredHostKey>> _read() async {
    if (!await _file.exists()) {
      return [];
    }
    return HostKeyStoreCodec.decode(await _file.readAsString());
  }

  Future<void> _write(List<StoredHostKey> keys) async {
    await _file.parent.create(recursive: true);
    final temporary = File('${_file.path}.tmp');
    await temporary.writeAsString(HostKeyStoreCodec.encode(keys));
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
