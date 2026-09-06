import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Bahagi ng isang Hive box na pag-aari ng iisang bata.
///
/// Ang susi sa disk ay `'<childId>::<key>'`, pero walang tumatawag na
/// humahawak niyon. Iyon ang buong punto: kung ang prefix ay idadagdag sa
/// bawat lugar na may `get` o `put`, sapat nang makalimutan ito nang isang
/// beses para makita ng magulang ang datos ng ibang anak.
///
/// Ang susing walang separator ay galing sa bersyon bago ang multi-child.
/// Hindi ito nakikita rito — sinasadya, para may mababalikan kung may masira
/// sa paglipat.
class ScopedBox<T> {
  /// Buong box, kasama ang lahat ng bata. Para lang sa backup.
  final Box<T> raw;

  final String _prefix;

  ScopedBox(this.raw, String childId) : _prefix = '$childId$separator';

  static const String separator = '::';

  String _full(Object key) => '$_prefix$key';

  Iterable<String> get _ownKeys =>
      raw.keys.whereType<String>().where((k) => k.startsWith(_prefix));

  T? get(Object key, {T? defaultValue}) =>
      raw.get(_full(key), defaultValue: defaultValue);

  Future<void> put(Object key, T value) => raw.put(_full(key), value);

  Future<void> putAll(Map<dynamic, T> entries) => raw.putAll({
    for (final entry in entries.entries) _full(entry.key): entry.value,
  });

  Future<void> delete(Object key) => raw.delete(_full(key));

  Future<void> deleteAll(Iterable<dynamic> keys) =>
      raw.deleteAll([for (final key in keys) _full(key)]);

  bool containsKey(Object key) => raw.containsKey(_full(key));

  Iterable<String> get keys => _ownKeys.map((k) => k.substring(_prefix.length));

  Iterable<T> get values => _ownKeys.map((k) => raw.get(k) as T);

  int get length => _ownKeys.length;

  bool get isEmpty => _ownKeys.isEmpty;

  bool get isNotEmpty => _ownKeys.isNotEmpty;

  /// Ang bata lang ang nililinis, hindi ang buong box.
  Future<void> clear() => raw.deleteAll(_ownKeys.toList());

  /// Buong box ang pinapakinggan. Titibok ito kapag nagbago ang ibang bata,
  /// pero ang bunga ay isang muling pagguhit na walang nakikitang pagbabago.
  ValueListenable<Box<T>> listenable() => raw.listenable();
}
