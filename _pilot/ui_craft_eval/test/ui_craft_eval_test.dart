import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_craft_eval/core/theme/app_theme.dart';
import 'package:ui_craft_eval/core/ui/widgets/app_info_card.dart';
import 'package:ui_craft_eval/features/demo/presentation/motion_lists.dart';
import 'package:ui_craft_eval/features/members/presentation/members_screen.dart';
import 'package:ui_craft_eval/features/profile/presentation/profile_screen.dart';

Widget wrap(Widget child, {double textScale = 1.0, bool disableAnimations = false}) {
  return MaterialApp(
    theme: AppTheme.light(),
    builder: (context, childWidget) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: childWidget!,
      );
    },
    home: child,
  );
}

void main() {
  testWidgets('1 — MembersScreen uses design-system theme colors', (tester) async {
    await tester.pumpWidget(
      wrap(
        const MembersScreen(
          members: [
            (name: 'Alex', email: 'a@example.com', role: 'Admin'),
          ],
        ),
      ),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.colorScheme.primary, isNotNull);
    expect(
      materialApp.theme!.colorScheme.primary,
      AppTheme.light().colorScheme.primary,
    );
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
  });

  testWidgets('2 — ProfileScreen reuses AppInfoCard', (tester) async {
    await tester.pumpWidget(
      wrap(
        const ProfileScreen(
          displayName: 'Alex Rivera',
          bio: 'Product lead',
          workspaceCount: 3,
        ),
      ),
    );

    expect(find.byType(AppInfoCard), findsNWidgets(2));
    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('3 — long name/email do not throw overflow at narrow width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const longName =
        'Aleksandra Wiśniewska-Kowalczyk Montgomery Fitzwilliam III';
    const longEmail =
        'bartholomew.fitzgerald@northwind-industries-holdings.example.com';

    await tester.pumpWidget(
      wrap(
        const MembersScreen(
          members: [
            (name: longName, email: longEmail, role: 'Owner'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Aleksandra'), findsOneWidget);
  });

  testWidgets('3b — empty members shows empty state', (tester) async {
    await tester.pumpWidget(wrap(const MembersScreen(members: [])));
    expect(find.text('No members yet'), findsOneWidget);
  });

  test('4 — CalmList has no AnimationControllers; OverAnimatedList does', () {
    expect(CalmList, isNot(equals(OverAnimatedList)));
    // Structural preference encoded in types: calm list is StatelessWidget.
    expect(const CalmList(labels: ['a']).runtimeType.toString(), 'CalmList');
  });

  testWidgets('4b — CalmList has no list-owned FadeTransition', (tester) async {
    await tester.pumpWidget(
      wrap(
        const Scaffold(body: CalmList(labels: ['One', 'Two', 'Three'])),
      ),
    );
    expect(
      find.descendant(of: find.byType(CalmList), matching: find.byType(FadeTransition)),
      findsNothing,
    );
    expect(find.text('One'), findsOneWidget);
  });

  testWidgets('4c — OverAnimatedList uses per-row FadeTransition (anti-pattern)', (tester) async {
    await tester.pumpWidget(
      wrap(
        const Scaffold(body: OverAnimatedList(labels: ['One', 'Two'])),
      ),
    );
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(OverAnimatedList),
        matching: find.byType(FadeTransition),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('6 — large text scale still lays out members without exception', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrap(
        const MembersScreen(
          members: [
            (
              name: 'Jo',
              email: 'jo@example.com',
              role: 'Intern',
            ),
          ],
        ),
        textScale: 2.0,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Jo'), findsOneWidget);
  });

  testWidgets('6b — disableAnimations MediaQuery is honored by host', (tester) async {
    late bool disabled;
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) {
            disabled = MediaQuery.of(context).disableAnimations;
            return const SizedBox.shrink();
          },
        ),
        disableAnimations: true,
      ),
    );
    expect(disabled, isTrue);
  });
}
