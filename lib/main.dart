import 'package:flutter/material.dart';
import 'package:watertracker/core/di/service_locator.dart';
import 'package:watertracker/presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const App());
}
