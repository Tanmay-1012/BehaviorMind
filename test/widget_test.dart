import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/app.dart';
import 'package:behaviormind/routes.dart';
import 'package:behaviormind/providers/user_provider.dart';
import 'package:behaviormind/providers/health_data_provider.dart';
import 'package:behaviormind/providers/prediction_provider.dart';
import 'package:behaviormind/providers/settings_provider.dart';

void main() {
  testWidgets('BehaviorMindApp basic smoke test', (WidgetTester tester) async {
    final userProvider = UserProvider();
    final healthDataProvider = HealthDataProvider();
    final predictionProvider = PredictionProvider();
    final settingsProvider = SettingsProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider.value(value: healthDataProvider),
          ChangeNotifierProvider.value(value: predictionProvider),
          ChangeNotifierProvider.value(value: settingsProvider),
        ],
        child: const BehaviorMindApp(initialRoute: AppRoutes.permissions),
      ),
    );

    // Verify BehaviorMindApp initializes and pumps widget tree
    expect(find.byType(BehaviorMindApp), findsOneWidget);
  });
}
