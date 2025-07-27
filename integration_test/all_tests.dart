import 'package:integration_test/integration_test.dart';

import 'app_test.dart' as app_test;
import 'data_persistence_test.dart' as data_persistence_test;
import 'notification_test.dart' as notification_test;
import 'offline_online_test.dart' as offline_online_test;
import 'premium_unlock_test.dart' as premium_unlock_test;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Run all integration tests
  app_test.main();
  data_persistence_test.main();
  notification_test.main();
  offline_online_test.main();
  premium_unlock_test.main();
}