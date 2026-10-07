// Значения параметров одного блока на одном сервере. Секреты сюда не пишутся.
abstract class ParameterValueStore {
  Future<Map<String, String>> read(String profileId, String scriptId);

  Future<void> save(String profileId, String scriptId, Map<String, String> values);
}
