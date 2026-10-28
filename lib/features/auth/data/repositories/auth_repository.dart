import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/otp_service.dart';
import '../models/user_model.dart';

/// Result object for authentication actions.
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final UserProfile? user;

  const AuthResult.success(this.user)
      : isSuccess = true,
        errorMessage = null;

  const AuthResult.failure(this.errorMessage)
      : isSuccess = false,
        user = null;
}

/// Abstract contract for authentication operations in GramConnect.
/// Prepares the application for a future Supabase or REST API backend.
abstract class AuthRepository {
  Future<UserProfile?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<AuthResult> login({required String phoneNumber, required String pin});
  Future<AuthResult> register({
    required String fullName,
    required String phoneNumber,
    required String villageName,
    required String pin,
    String? wardOrGalli,
  });
  Future<void> logout();
  Future<AuthResult> resetPin({
    required String phoneNumber,
    required String newPin,
    required String otp,
  });
  Future<String> requestOtp(String phoneNumber);
  Future<bool> updateUserProfile(UserProfile updatedUser);
}

/// Persistent local authentication repository backed by [SharedPreferences].
/// Saves user registrations, credentials, and active session across app restarts.
class LocalAuthRepository implements AuthRepository {
  static final LocalAuthRepository _instance = LocalAuthRepository._internal();
  factory LocalAuthRepository() => _instance;
  LocalAuthRepository._internal();

  static const String _keyUsers = 'gc_registered_users';
  static const String _keyCurrentUserId = 'gc_current_user_id';
  static const String _keyIsLoggedIn = 'gc_is_logged_in';

  /// Pre-seeded demo accounts
  static final List<UserProfile> _initialSeedUsers = [
    UserProfile.mockUser,
    UserProfile.sarpanchUser,
  ];

  Future<List<UserProfile>> _loadAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyUsers);

    if (jsonList == null || jsonList.isEmpty) {
      // Seed default accounts initially
      await _saveAllUsers(_initialSeedUsers);
      return List.of(_initialSeedUsers);
    }

    try {
      final users = jsonList.map((str) {
        return UserProfile.fromJson(jsonDecode(str) as Map<String, dynamic>);
      }).toList();
      return users;
    } catch (_) {
      return List.of(_initialSeedUsers);
    }
  }

  Future<void> _saveAllUsers(List<UserProfile> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = users.map((u) => jsonEncode(u.toJson())).toList();
    await prefs.setStringList(_keyUsers, jsonList);
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    final currentId = prefs.getString(_keyCurrentUserId);
    if (currentId == null) return null;

    final users = await _loadAllUsers();
    try {
      return users.firstWhere(
        (u) => u.id == currentId || u.phoneNumber == currentId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  @override
  Future<AuthResult> login({
    required String phoneNumber,
    required String pin,
  }) async {
    final cleanPhone = phoneNumber.trim();
    final cleanPin = pin.trim();

    if (cleanPhone.length != 10) {
      return const AuthResult.failure('Please enter a valid 10-digit mobile number.');
    }
    if (cleanPin.length < 4) {
      return const AuthResult.failure('Please enter a valid 4-digit PIN.');
    }

    final users = await _loadAllUsers();

    UserProfile? matchedUser;
    try {
      matchedUser = users.firstWhere((u) => u.phoneNumber == cleanPhone);
    } catch (_) {
      matchedUser = null;
    }

    if (matchedUser == null) {
      return const AuthResult.failure(
        'No account found with this mobile number. Please register first.',
      );
    }

    if (matchedUser.pin != cleanPin) {
      return const AuthResult.failure(
        'Incorrect PIN. Please check and try again.',
      );
    }

    // Persist active session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyCurrentUserId, matchedUser.id);

    return AuthResult.success(matchedUser);
  }

  @override
  Future<AuthResult> register({
    required String fullName,
    required String phoneNumber,
    required String villageName,
    required String pin,
    String? wardOrGalli,
  }) async {
    final cleanName = fullName.trim();
    final cleanPhone = phoneNumber.trim();
    final cleanVillage = villageName.trim();
    final cleanPin = pin.trim();

    if (cleanName.isEmpty) {
      return const AuthResult.failure('Full name is required.');
    }
    if (cleanPhone.length != 10) {
      return const AuthResult.failure('Please enter a valid 10-digit mobile number.');
    }
    if (cleanPin.length < 4) {
      return const AuthResult.failure('PIN must be at least 4 digits.');
    }

    final users = await _loadAllUsers();

    final alreadyExists = users.any((u) => u.phoneNumber == cleanPhone);
    if (alreadyExists) {
      return const AuthResult.failure(
        'An account with this mobile number already exists. Please log in instead.',
      );
    }

    final newId = 'usr_${cleanPhone}_${DateTime.now().millisecondsSinceEpoch}';
    final randomSuffix = cleanPhone.length >= 4 ? cleanPhone.substring(6) : '0000';

    final newUser = UserProfile(
      id: newId,
      fullName: cleanName,
      phoneNumber: cleanPhone,
      villageName: cleanVillage.isNotEmpty ? cleanVillage : 'Dhawalpuri',
      wardOrGalli: wardOrGalli?.trim(),
      pin: cleanPin,
      digitalIdStatus: 'pending',
      digitalIdCode: 'GC-DHA-$randomSuffix-PENDING',
      role: 'villager',
      createdAt: DateTime.now(),
    );

    users.add(newUser);
    await _saveAllUsers(users);

    // Persist active session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyCurrentUserId, newUser.id);

    return AuthResult.success(newUser);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyCurrentUserId);
  }

  @override
  Future<String> requestOtp(String phoneNumber) async {
    final result = await OtpService().sendOtp(phoneNumber);
    return result.otpCode ?? '1234';
  }

  @override
  Future<AuthResult> resetPin({
    required String phoneNumber,
    required String newPin,
    required String otp,
  }) async {
    final cleanPhone = phoneNumber.trim();
    final cleanPin = newPin.trim();

    final isValid = OtpService().verifyOtp(
      phoneNumber: cleanPhone,
      enteredOtp: otp,
    );

    if (!isValid) {
      return const AuthResult.failure('Invalid or expired OTP code.');
    }
    if (cleanPin.length < 4) {
      return const AuthResult.failure('New PIN must be at least 4 digits.');
    }

    final users = await _loadAllUsers();
    final index = users.indexWhere((u) => u.phoneNumber == cleanPhone);

    if (index == -1) {
      return const AuthResult.failure('Mobile number not found in village records.');
    }

    final updated = users[index].copyWith(pin: cleanPin);
    users[index] = updated;
    await _saveAllUsers(users);

    return AuthResult.success(updated);
  }

  @override
  Future<bool> updateUserProfile(UserProfile updatedUser) async {
    final users = await _loadAllUsers();
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      await _saveAllUsers(users);
      return true;
    }
    return false;
  }
}
