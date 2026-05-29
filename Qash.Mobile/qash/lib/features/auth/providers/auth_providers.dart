import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../data/auth_api.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/change_password_use_case.dart';
import '../domain/usecases/login_use_case.dart';
import '../domain/usecases/register_use_case.dart';
import '../domain/usecases/request_forgot_password_code_use_case.dart';
import '../domain/usecases/reset_forgot_password_use_case.dart';
import '../domain/usecases/logout_use_case.dart';
import '../domain/usecases/verify_phone_use_case.dart';
import '../../../core/auth/auth_state.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthApi(ref.read(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    ref.read(secureStorageProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final verifyPhoneUseCaseProvider = Provider<VerifyPhoneUseCase>((ref) {
  return VerifyPhoneUseCase(ref.read(authRepositoryProvider));
});

final requestForgotPasswordCodeUseCaseProvider =
    Provider<RequestForgotPasswordCodeUseCase>((ref) {
      return RequestForgotPasswordCodeUseCase(ref.read(authRepositoryProvider));
    });

final resetForgotPasswordUseCaseProvider = Provider<ResetForgotPasswordUseCase>(
  (ref) {
    return ResetForgotPasswordUseCase(ref.read(authRepositoryProvider));
  },
);

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

/// After login / verify, mark session active for routing.
void markUserAuthenticated(WidgetRef ref) {
  ref.read(authStatusProvider.notifier).setAuthenticated();
}
