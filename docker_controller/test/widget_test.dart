import 'package:docker_controller/app.dart';
import 'package:docker_controller/core/di/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await setupLocator();
  });

  testWidgets('Smoke test', (WidgetTester tester) async {
    // Basic test that the app builds without crashing
    await tester.pumpWidget(const DockerControllerApp());
    expect(find.byType(DockerControllerApp), findsOneWidget);
  });
}
