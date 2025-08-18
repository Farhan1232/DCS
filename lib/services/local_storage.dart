
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalUserService {
  static const _key = 'device_user_id';
  String? _deviceId;

  Future<String> getDeviceUserId() async {
    if (_deviceId != null) return _deviceId!;
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_key);
    if (id != null) {
      _deviceId = id;
      return id;
    }
    // generate new id
    final newId = Uuid().v4();
    await prefs.setString(_key, newId);
    _deviceId = newId;
    return newId;
  }
}
