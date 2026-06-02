import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_noc_frontend/main.dart';

void main() {
  testWidgets('App renders login shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: IspNocApp()));
    await tester.pump();

    expect(find.text('NOC Login'), findsOneWidget);
  });
}
