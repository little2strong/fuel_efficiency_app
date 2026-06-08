import 'package:get_storage/get_storage.dart';

class LocalStorageProvider {
  LocalStorageProvider(this._box);

  final GetStorage _box;

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clear() => _box.erase();
}
