import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _tokenKey = 'driver_auth_token';
  static const _driverIdKey = 'driver_id';
  static const _phoneKey = 'driver_phone';
  static const _nameKey = 'driver_name';
  static const _driverPhotoKey = 'driver_photo';

  static const _registeredKey = 'driver_registered';
  static const _approvedKey = 'driver_approved';
  static const _loggedKey = 'driver_logged';

  static const _blockedKey = 'driver_blocked';
  static const _blockedReasonKey = 'driver_blocked_reason';

  static const _currentRideIdKey = 'driver_current_ride_id';
  static const _onlineStatusKey = 'driver_online_status';

  static const _draftNameKey = 'driver_draft_name';
  static const _draftPhoneKey = 'driver_draft_phone';
  static const _draftEmailKey = 'driver_draft_email';
  static const _draftIdDocKey = 'driver_draft_id_doc';
  static const _draftLicenseKey = 'driver_draft_license';
  static const _draftCarInfoKey = 'driver_draft_car_info';
  static const _draftPlateKey = 'driver_draft_plate';

  static const _rideSoundKey = 'ride_sound';
  static const _vibrationKey = 'vibration';
  static const _darkModeKey = 'dark_mode';
  static const _navigationDefaultKey = 'navigation_default';

  Future<void> logoutOnly() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_driverIdKey);
    await prefs.remove(_currentRideIdKey);

    await prefs.setBool(_loggedKey, false);
    await prefs.setBool(_onlineStatusKey, false);
    await prefs.setBool(_blockedKey, false);
    await prefs.setString(_blockedReasonKey, '');
  }

  Future<void> saveSession({
    required String token,
    required String driverId,
    required String phone,
    required String name,
    String? driverPhoto,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token.trim());
    await prefs.setString(_driverIdKey, driverId.trim());
    await prefs.setString(_phoneKey, phone.trim());
    await prefs.setString(_nameKey, name.trim());

    if (driverPhoto != null && driverPhoto.trim().isNotEmpty) {
      await prefs.setString(_driverPhotoKey, driverPhoto.trim());
    }

    await prefs.setBool(_registeredKey, true);
    await prefs.setBool(_approvedKey, true);
    await prefs.setBool(_loggedKey, true);
    await prefs.setBool(_blockedKey, false);
    await prefs.setString(_blockedReasonKey, '');
  }

  Future<void> saveDriverPhoto(String photo) async {
    final clean = photo.trim();
    if (clean.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverPhotoKey, clean);
  }

  Future<String?> getDriverPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_driverPhotoKey);
  }

  Future<void> saveRideSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rideSoundKey, value);
  }

  Future<bool> getRideSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rideSoundKey) ?? true;
  }

  Future<void> saveVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
  }

  Future<bool> getVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? true;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? true;
  }

  Future<void> saveNavigation(String value) async {
    final clean = value.trim();

    if (clean.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_navigationDefaultKey, clean);
  }

  Future<String> getNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_navigationDefaultKey) ?? 'Google Maps';
  }

  Future<void> saveRegistrationState({
    required String phone,
    required String name,
    required bool registered,
    required bool approved,
    required bool logged,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_phoneKey, phone.trim());
    await prefs.setString(_nameKey, name.trim());
    await prefs.setBool(_registeredKey, registered);
    await prefs.setBool(_approvedKey, approved);
    await prefs.setBool(_loggedKey, logged);
  }

  Future<void> markApprovedAndLogged() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_registeredKey, true);
    await prefs.setBool(_approvedKey, true);
    await prefs.setBool(_loggedKey, true);
    await prefs.setBool(_blockedKey, false);
    await prefs.setString(_blockedReasonKey, '');
  }

  Future<bool> hasRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_registeredKey) ?? false;
  }

  Future<bool> isApproved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_approvedKey) ?? false;
  }

  Future<bool> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedKey) ?? false;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_driverIdKey);
  }

  Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  Future<void> saveBlockedStatus({
    required bool blocked,
    String reason = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_blockedKey, blocked);
    await prefs.setString(_blockedReasonKey, reason.trim());

    if (blocked) {
      await prefs.setBool(_onlineStatusKey, false);
      await prefs.setBool(_loggedKey, false);
      await prefs.remove(_currentRideIdKey);
    }
  }

  Future<bool> isBlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_blockedKey) ?? false;
  }

  Future<String> getBlockedReason() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_blockedReasonKey) ?? '';
  }

  Future<void> resetBlockedStatus() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_blockedKey, false);
    await prefs.setString(_blockedReasonKey, '');
  }

  Future<void> saveCurrentRideId(String rideId) async {
    final prefs = await SharedPreferences.getInstance();
    final clean = rideId.trim();

    if (clean.isEmpty) return;

    await prefs.setString(_currentRideIdKey, clean);
  }

  Future<String?> getCurrentRideId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentRideIdKey);
  }

  Future<bool> hasActiveRide() async {
    final rideId = await getCurrentRideId();
    return rideId != null && rideId.trim().isNotEmpty;
  }

  Future<void> clearCurrentRideId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentRideIdKey);
  }

  Future<void> clearAllRideData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentRideIdKey);
  }

  Future<void> saveOnlineStatus(bool online) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onlineStatusKey, online);
  }

  Future<bool> getOnlineStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onlineStatusKey) ?? false;
  }

  Future<void> saveRegistrationDraft({
    required String name,
    required String phone,
    required String email,
    required String idDocPath,
    required String licensePath,
    required String carInfo,
    required String carPlate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_draftNameKey, name.trim());
    await prefs.setString(_draftPhoneKey, phone.trim());
    await prefs.setString(_draftEmailKey, email.trim());
    await prefs.setString(_draftIdDocKey, idDocPath.trim());
    await prefs.setString(_draftLicenseKey, licensePath.trim());
    await prefs.setString(_draftCarInfoKey, carInfo.trim());
    await prefs.setString(_draftPlateKey, carPlate.trim());
  }

  Future<Map<String, String>?> getRegistrationDraft() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString(_draftNameKey);
    final phone = prefs.getString(_draftPhoneKey);
    final email = prefs.getString(_draftEmailKey);
    final idDoc = prefs.getString(_draftIdDocKey);
    final license = prefs.getString(_draftLicenseKey);
    final carInfo = prefs.getString(_draftCarInfoKey);
    final plate = prefs.getString(_draftPlateKey);

    if ([name, phone, email, idDoc, license, carInfo, plate]
        .any((value) => value == null || value.trim().isEmpty)) {
      return null;
    }

    return {
      'name': name!.trim(),
      'phone': phone!.trim(),
      'email': email!.trim(),
      'id_doc': idDoc!.trim(),
      'license': license!.trim(),
      'car_info': carInfo!.trim(),
      'car_plate': plate!.trim(),
    };
  }

  Future<void> clearRegistrationDraft() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_draftNameKey);
    await prefs.remove(_draftPhoneKey);
    await prefs.remove(_draftEmailKey);
    await prefs.remove(_draftIdDocKey);
    await prefs.remove(_draftLicenseKey);
    await prefs.remove(_draftCarInfoKey);
    await prefs.remove(_draftPlateKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_driverIdKey);
    await prefs.remove(_currentRideIdKey);

    await prefs.setBool(_loggedKey, false);
    await prefs.setBool(_onlineStatusKey, false);
    await prefs.setBool(_blockedKey, false);
    await prefs.setString(_blockedReasonKey, '');
  }

  Future<void> forceResetDevMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}