
// Flutter Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// (https://pub.dev/packages/flutter_secure_storage)
// A Flutter plugin to store data in secure storage:
// -Keychain is used for iOS
// -AES encryption is used for Android. AES secret key is encrypted with RSA and RSA key is stored in KeyStore

class SecureStorage {
  final _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ));

  bool saveString(String key, String value) {
    try {
      _storage.write(key: key, value: value);

      return true;
    } catch (error) {
      return false;
    }
  }

  Future<String?> readString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (error) {
      return null;
    }
  }

  void deleteKey(String key) async => await _storage.delete(key: key);
}

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());
