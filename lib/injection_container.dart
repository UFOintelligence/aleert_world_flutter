import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// AUTH
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';

// ALERTAS
import 'package:alert_world/bloc/alerts/alert_bloc.dart';
import 'package:alert_world/features/alerts/domain/usecases/get_alertas.dart';
import 'package:alert_world/features/alerts/data/datasources/alert_remote_data_source.dart';
import 'package:alert_world/features/alerts/domain/repositories/alert_repository.dart';
import 'package:alert_world/features/alerts/data/repositories/alert_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // HTTP
  sl.registerLazySingleton(() => http.Client());

  // AUTH
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
        client: sl(),
        baseUrl: 'http://10.0.2.2:8000/api',
      ));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));

  // ALERTAS
 sl.registerLazySingleton<AlertRemoteDataSource>(() => AlertRemoteDataSourceImpl(
  client: sl(),
  baseUrl: 'http://10.0.2.2:8000/api',
));

sl.registerLazySingleton<AlertRepository>(() => AlertRepositoryImpl(sl()));
sl.registerLazySingleton(() => GetAlertas(sl()));
sl.registerFactory(() => AlertBloc(sl()));

}
