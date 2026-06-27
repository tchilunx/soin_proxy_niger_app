import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../core/network/api_client.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/care_request/data/datasources/care_request_remote_datasource.dart';
import '../features/care_request/data/repositories/care_request_repository_impl.dart';
import '../features/care_request/domain/repositories/care_request_repository.dart';
import '../features/care_request/presentation/bloc/care_request_bloc.dart';
import '../features/professional/data/datasources/professional_remote_datasource.dart';
import '../features/professional/presentation/bloc/professional_bloc.dart';
import '../features/pharmacist/data/datasources/pharmacist_remote_datasource.dart';
import '../features/pharmacist/data/repositories/pharmacist_repository_impl.dart';
import '../features/pharmacist/domain/repositories/pharmacist_repository.dart';
import '../features/pharmacist/presentation/bloc/pharmacist_bloc.dart';
import '../features/patient/data/datasources/patient_remote_datasource.dart';
import '../features/patient/data/repositories/patient_repository_impl.dart';
import '../features/patient/domain/repositories/patient_repository.dart';
import '../features/patient/presentation/bloc/patient_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );

  // Core
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      dio: getIt<Dio>(),
      storage: getIt<FlutterSecureStorage>(),
    ),
  );

  // Auth Feature
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: getIt<FlutterSecureStorage>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  // Care Request Feature
  // Data sources
  getIt.registerLazySingleton<CareRequestRemoteDataSource>(
    () => CareRequestRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<CareRequestRepository>(
    () => CareRequestRepositoryImpl(getIt<CareRequestRemoteDataSource>()),
  );

  // BLoCs
  getIt.registerFactory<CareRequestBloc>(
    () => CareRequestBloc(getIt<CareRequestRepository>()),
  );

  // Professional Feature
  // Data sources
  getIt.registerLazySingleton<ProfessionalRemoteDataSource>(
    () => ProfessionalRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // BLoCs
  getIt.registerFactory<ProfessionalBloc>(
    () => ProfessionalBloc(getIt<ProfessionalRemoteDataSource>()),
  );

  // Pharmacist Feature
  // Data sources
  getIt.registerLazySingleton<PharmacistRemoteDataSource>(
    () => PharmacistRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<PharmacistRepository>(
    () => PharmacistRepositoryImpl(getIt<PharmacistRemoteDataSource>()),
  );

  // BLoCs
  getIt.registerFactory<PharmacistBloc>(
    () => PharmacistBloc(getIt<PharmacistRepository>()),
  );

  // Patient Feature
  getIt.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(getIt<PatientRemoteDataSource>()),
  );
  getIt.registerFactory<PatientBloc>(
    () => PatientBloc(getIt<PatientRepository>()),
  );
}

