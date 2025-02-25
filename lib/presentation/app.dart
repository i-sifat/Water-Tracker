import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/core/di/service_locator.dart';
import 'package:watertracker/core/routing/app_router.dart';
import 'package:watertracker/core/theme/app_theme.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<WaterBloc>(
              create: (context) => getIt<WaterBloc>(),
              lazy: false,
            ),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Water Reminder',
            theme: AppTheme.light(lightDynamic),
            darkTheme: AppTheme.dark(darkDynamic),
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}