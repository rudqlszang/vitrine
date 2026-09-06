import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/profile.dart';

/// 계정·배송지 저장.
class ProfileBox {
  ProfileBox._(this._box);

  static const boxName = 'profile';
  static const _profileKey = 'me';
  static const _addressKey = 'address';

  final Box<Map<dynamic, dynamic>> _box;

  static Future<ProfileBox> open() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    return ProfileBox._(box);
  }

  Profile? readProfile() {
    final m = _box.get(_profileKey);
    return m == null ? null : Profile.fromMap(m);
  }

  Future<void> writeProfile(Profile p) =>
      _box.put(_profileKey, p.toMap());

  Address? readAddress() {
    final m = _box.get(_addressKey);
    return m == null ? null : Address.fromMap(m);
  }

  Future<void> writeAddress(Address a) =>
      _box.put(_addressKey, a.toMap());

  Future<void> clear() => _box.clear();
}
