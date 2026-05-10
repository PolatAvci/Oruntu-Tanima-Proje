import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'features/signature_verification/data/datasources/signature_local_datasource.dart';
import 'features/signature_verification/data/datasources/signature_remote_datasource.dart';
import 'features/signature_verification/data/repositories/signature_repository_impl.dart';
import 'features/signature_verification/domain/repositories/signature_repository.dart';
import 'features/signature_verification/domain/usecases/pick_reference_signature.dart';
import 'features/signature_verification/domain/usecases/pick_test_signature.dart';
import 'features/signature_verification/domain/usecases/save_cropped_signature.dart';
import 'features/signature_verification/domain/usecases/verify_signatures.dart';
import 'features/signature_verification/presentation/providers/signature_verification_provider.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Initializes dependency injection for the entire application.
///
/// Registers core services, data sources, repositories, use cases,
/// and presentation providers as lazy singletons or factories.
void initDependencies() {
  // Core / External
  sl.registerLazySingleton<ImagePicker>(() => ImagePicker());

  // Data Sources
  sl.registerLazySingleton<SignatureLocalDataSource>(
    () => SignatureLocalDataSourceImpl(picker: sl()),
  );
  sl.registerLazySingleton<SignatureRemoteDataSource>(
    () => SignatureRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<SignatureRepository>(
    () => SignatureRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => PickReferenceSignature(sl()));
  sl.registerLazySingleton(() => PickTestSignature(sl()));
  sl.registerLazySingleton(() => SaveCroppedSignature(sl()));
  sl.registerLazySingleton(() => VerifySignatures(sl()));

  // Provider (factory because it holds ephemeral UI state)
  sl.registerFactory(
    () => SignatureVerificationProvider(
      pickReferenceSignature: sl(),
      pickTestSignature: sl(),
      verifySignatures: sl(),
      saveCroppedSignature: sl(),
    ),
  );
}
