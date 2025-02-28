import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/data/repositories/water_repository.dart';
import 'package:watertracker/data/services/storage_service.dart';
import 'package:watertracker/domain/repositories/i_water_repository.dart';
import 'package:watertracker/presentation/blocs/history/history_bloc.dart';
import 'package:watertracker/presentation/blocs/user/user_bloc.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  final prefs = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<StorageService>(StorageService(prefs))
    // Repositories
    ..registerLazySingleton<IWaterRepository>(
      () => WaterRepository(getIt()),
    )
    // BLoCs
    ..registerFactory(() => WaterBloc(getIt()))
    ..registerFactory(() => UserBloc(getIt()))
    ..registerFactory(() => HistoryBloc());
}