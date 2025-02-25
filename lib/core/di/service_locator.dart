import 'package:get_it/get_it.dart';
import 'package:watertracker/data/repositories/water_repository.dart';
import 'package:watertracker/domain/repositories/i_water_repository.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Repositories
  getIt.registerLazySingleton<IWaterRepository>(() => WaterRepository());

  // BLoCs
  getIt.registerFactory(() => WaterBloc(getIt()));
}