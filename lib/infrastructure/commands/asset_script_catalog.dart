// Каталог из assets. Повторно файл не перечитывается в рамках процесса.
import 'package:flutter/services.dart';

import '../../domain/entities/command_script.dart';
import '../../domain/repositories/script_catalog.dart';
import 'script_codec.dart';

class AssetScriptCatalog implements ScriptCatalog {
  AssetScriptCatalog({this.assetPath = 'assets/commands/builtin_scripts.json'});

  final String assetPath;
  List<CommandScript>? _cache;

  @override
  Future<List<CommandScript>> list() async {
    _cache ??= ScriptCodec.parse(await rootBundle.loadString(assetPath));
    return List.unmodifiable(_cache!);
  }

  @override
  Future<CommandScript?> findById(String id) async {
    final scripts = await list();
    for (final script in scripts) {
      if (script.id == id) {
        return script;
      }
    }
    return null;
  }
}
