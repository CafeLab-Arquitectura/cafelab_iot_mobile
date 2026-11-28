import 'dart:io';

import 'package:cafelab_iot_mobile/features/auth/data/user_session_storage.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/authenticated_user.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_up_request.dart';
import 'package:cafelab_iot_mobile/features/profiles/data/profile_api_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/create_profile_request.dart';

class ProfileBootstrapOrchestrator {
  ProfileBootstrapOrchestrator({
    ProfileApiService? profileApiService,
    UserSessionStorage? sessionStorage,
  })  : _profileApiService = profileApiService ?? ProfileApiService(),
        _sessionStorage = sessionStorage ?? UserSessionStorage();

  final ProfileApiService _profileApiService;
  final UserSessionStorage _sessionStorage;

  Future<void> ensureProfileExistsBeforeSignUp({
    required SignUpRequest signUpRequest,
  }) async {
    final createRequest = CreateProfileRequest(
      name: signUpRequest.name,
      email: signUpRequest.email,
      password: signUpRequest.password,
      role: _mapRole(signUpRequest.role),
      cafeteriaName: signUpRequest.cafeteriaName,
      experience: signUpRequest.experience,
      profilePicture: signUpRequest.profilePicture,
      paymentMethod: signUpRequest.paymentMethod,
      isFirstLogin: signUpRequest.isFirstLogin,
      plan: signUpRequest.plan,
      hasPlan: signUpRequest.hasPlan,
    );

    await _profileApiService.createProfile(createRequest);
  }

  Future<void> ensureProfileExistsAfterSignIn({
    required AuthenticatedUser user,
  }) async {
    try {
      final profile = await _profileApiService.getProfileByEmail(user.email);
      await _sessionStorage.saveProfileState(
        profileId: profile.id,
        plan: profile.plan,
        hasPlan: profile.hasPlan,
      );
      if (profile.id > 0) {
        await _sessionStorage.saveUserId(profile.id);
      }
    } on ProfileApiException catch (e) {
      if (e.statusCode == HttpStatus.notFound) {
        throw const ProfileApiException(
          'Perfil no encontrado para este usuario. Registra nuevamente para crear el perfil.',
          statusCode: HttpStatus.notFound,
        );
      }
      rethrow;
    }
  }

  String _mapRole(String authRole) {
    final normalized = authRole.toLowerCase();
    if (normalized.contains('owner')) return 'owner';
    return 'barista';
  }
}
