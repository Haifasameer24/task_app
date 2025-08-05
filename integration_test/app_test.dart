import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/screens/home_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:getx_course/main.dart' as app;
void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await GetStorage.init());
  tearDown(() async => await GetStorage().erase());
  group('end to end test', () {

    testWidgets('verify login screen with correct email and password', (tester) async {
      await GetStorage().write("seen_onboarding", true);
      await GetStorage().write("is_logged_in", false);
     app.main();
     await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      expect(find.byType(TextField), findsWidgets);
     await Future.delayed(Duration(seconds: 5));
      expect(find.byKey(Key('user_email')), findsOneWidget);
      expect(find.byKey(Key('user_password')), findsOneWidget);

      await tester.enterText(find.byKey(Key('user_email')), 'haifa3@gmail.com');
      await tester.enterText(find.byKey(Key('user_password')), '123456');
     await Future.delayed(Duration(seconds: 2));
     await tester.tap(find.byType(ElevatedButton));
     await Future.delayed(Duration(seconds: 2));
     await tester.pumpAndSettle();

     expect(find.byType(HomeScreen), findsOneWidget);
            },
    );
    testWidgets('verify login screen with incorrect email and password',
          (tester) async {
        app.main();
        await tester.pumpAndSettle();
        await Future.delayed(Duration(seconds: 2));
        await tester.enterText(find.byType(TextField).at(0), 'email2');
        await Future.delayed(Duration(seconds: 2));
        await tester.enterText(find.byType(TextField).at(1), 'password');
        await Future.delayed(Duration(seconds: 2));
        await tester.tap(find.byType(ElevatedButton));
        await Future.delayed(Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.text('Invalid email and password'), findsOneWidget);
      },);
  },
  );
}