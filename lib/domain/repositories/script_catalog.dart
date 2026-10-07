// Только чтение блоков команд. Запись сознательно не входит в контракт.
import '../entities/command_script.dart';

abstract class ScriptCatalog {
  Future<List<CommandScript>> list();

  Future<CommandScript?> findById(String id);
}
