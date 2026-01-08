import 'dart:math';

import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/user.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

class UserService {
  static bool _testMode = false;
  static Box<User>? _testBox;

  static void enableTestMode(Box<User> testBox) {
    _testMode = true;
    _testBox = testBox;
  }

  static void disableTestMode() {
    _testMode = false;
    _testBox = null;
  }

  static Box<User> _getBox() {
    if (_testMode && _testBox != null) {
      return _testBox!;
    }
    return Hive.box<User>(userBoxName);
  }

  static Future<void> saveUser(User user) async {
    debugPrint('UserService: Saving user: ${user.name} (${user.id})');
    final box = _getBox();
    await box.put(user.id, user);
  }

  static Future<User?> getUser(String userId) async {
    debugPrint('UserService: Getting user: $userId');
    try {
      final box = _getBox();
      final user = box.get(userId);
      if (user != null) {
        debugPrint('UserService: Found user: ${user.name} (${user.id})');
      } else {
        debugPrint('UserService: User not found');
      }
      return user;
    } catch (e) {
      debugPrint('UserService: Error getting user: $e');
      return null;
    }
  }

  static Future<String> getOrCreateUserId() async {
    final settings = Hive.box(settingsBox);
    final userId = settings.get('userId');

    if (userId != null) {
      return userId as String;
    }

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final randomId =
        List.generate(
          10,
          (index) => chars[random.nextInt(chars.length)],
        ).join();

    await settings.put('userId', randomId);
    return randomId;
  }

  static String getUserId() {
    final settings = Hive.box(settingsBox);
    final userId = settings.get('userId', defaultValue: null);

    if (userId == null) {
      throw Exception('User ID not found in Hive storage');
    }

    return userId as String;
  }

  static Future<User?> getCurrentUser() async {
    final userId = await getOrCreateUserId();
    return getUser(userId);
  }

  static Future<bool> maybeCreateDebugUser() async {
    final userId = await getOrCreateUserId();
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      return false;
    }

    final user = User(id: userId, name: 'Test User');
    await saveUser(user);
    return true;
  }

  static Future<void> changeUserName(String newName) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User not found');
    }
    final updatedUser = user.copyWith(name: newName);
    await saveUser(updatedUser);
    await syncUserToServer();
  }

  /// Syncs the current user data to the server. Note: assumes the user exists.
  static Future<void> syncUserToServer() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User not found');
    }
    ServiceLocator.serverService.makePostRequest(
      '/user/create_or_update_user',
      user.toJson(),
    );
  }
}
