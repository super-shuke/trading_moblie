import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:traveling_app/component/common/bubble/index.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/main.dart';
import 'package:traveling_app/route/index.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/store/user/user_store.dart';

void main() {
  testWidgets('renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Continue with Email'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('bubble actions are hidden by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => TravelBubble.show(
              context,
              message: 'Saved',
              visibleDuration: const Duration(milliseconds: 10),
              fadeDuration: const Duration(milliseconds: 1),
            ),
            child: const Text('Show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump(const Duration(milliseconds: 2));

    expect(find.text('Saved'), findsOneWidget);
    expect(
      tester.widget<TravelBubble>(find.byType(TravelBubble)).position,
      Alignment.center,
    );
    expect(find.text('Cancel'), findsNothing);
    expect(find.text('OK'), findsNothing);
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('bubble actions close and return default results', (
    WidgetTester tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await TravelBubble.show(
                context,
                title: 'Continue?',
                content: 'Your changes will be applied.',
                showActions: true,
                fadeDuration: const Duration(milliseconds: 1),
              );
            },
            child: const Text('Show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump(const Duration(milliseconds: 2));
    expect(find.text('Continue?'), findsOneWidget);
    expect(find.text('Your changes will be applied.'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 2));
    expect(result, isFalse);
    expect(find.text('Continue?'), findsNothing);

    await tester.tap(find.text('Show'));
    await tester.pump(const Duration(milliseconds: 2));
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(milliseconds: 2));
    expect(result, isTrue);
    expect(find.text('Continue?'), findsNothing);
  });

  test('adds discoveries and tracks completed itinerary stops', () {
    final store = TravelStore();
    final originalCount = store.itinerary.stops.length;

    store.addPoiToItinerary('senso_ji_temple');
    store.addPoiToItinerary('senso_ji_temple');

    expect(store.itinerary.stops.length, originalCount + 1);
    expect(store.isPoiInItinerary('senso_ji_temple'), isTrue);

    final firstStop = store.itinerary.stops.first;
    store.toggleStopCompleted(firstStop.id);
    expect(store.isStopCompleted(firstStop.id), isTrue);
  });

  test('adds replies and toggles tip reactions', () {
    final store = TravelStore();
    const poiId = 'miradouro_senhora_monte';
    final parent = store.tipsForPoi(poiId).first;
    final originalLikes = parent.likes;

    store.toggleTipLike(poiId, parent.id);
    expect(store.isTipLiked(parent.id), isTrue);
    expect(store.tipsForPoi(poiId).first.likes, originalLikes + 1);

    store.toggleTipDislike(poiId, parent.id);
    expect(store.isTipLiked(parent.id), isFalse);
    expect(store.isTipDisliked(parent.id), isTrue);
    expect(store.tipsForPoi(poiId).first.likes, originalLikes);

    store.addTipReply(
      parentTipId: parent.id,
      reply: Tip(
        id: 'test_reply',
        poiId: poiId,
        authorName: 'Tester',
        kind: TipKind.neutral,
        body: 'A nested reply',
        createdAt: DateTime(2026, 7, 12),
        likes: 0,
      ),
    );

    expect(store.tipsForPoi(poiId).first.children.last.body, 'A nested reply');
  });

  test('only deletes tips owned by the current user', () {
    final store = TravelStore();
    const poiId = 'miradouro_senhora_monte';
    final otherTip = store.tipsForPoi(poiId).first;
    final ownTip = Tip(
      id: 'own_tip',
      poiId: poiId,
      authorName: store.profile.name,
      kind: TipKind.neutral,
      body: 'My removable tip',
      createdAt: DateTime(2026, 7, 12),
      likes: 0,
    );

    store.addTip(ownTip);

    expect(store.deleteTip(poiId, otherTip.id), isFalse);
    expect(store.deleteTip(poiId, ownTip.id), isTrue);
    expect(store.tipsForPoi(poiId).any((tip) => tip.id == ownTip.id), isFalse);
  });

  test('updates profile details without a dialog', () {
    final store = UserStore();

    store.updateProfile(name: 'Alex Chen', bio: 'Slow travel, local stories.');

    expect(store.username, 'Alex Chen');
    expect(store.bio, 'Slow travel, local stories.');
    expect(store.isLoggedIn, isTrue);
  });

  test('stores travel records and newly planned trips', () {
    final store = TravelStore();
    final now = DateTime(2026, 7, 10);

    store.addTravelRecord(
      TravelRecord(
        id: 'record_1',
        type: TravelRecordType.place,
        title: 'A local shop',
        city: 'Lisbon',
        category: 'Shop',
        date: now,
      ),
    );
    store.addPlannedTrip(
      PlannedTrip(
        id: 'trip_1',
        name: 'Tokyo food crawl',
        country: 'Japan',
        city: 'Tokyo',
        startDate: now,
        travelers: 2,
      ),
    );

    expect(store.travelRecords.single.title, 'A local shop');
    expect(store.plannedTrips.single.name, 'Tokyo food crawl');
  });

  testWidgets('opens edit profile as a full detail route', (
    WidgetTester tester,
  ) async {
    mainRouter.go('/profile');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();

    expect(mainRouter.state.uri.path, '/profile/edit');
    expect(find.text('Save'), findsOneWidget);
    mainRouter.go('/login');
  });

  testWidgets('opens add record as a full detail route', (
    WidgetTester tester,
  ) async {
    mainRouter.go('/profile/history');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add record'));
    await tester.pumpAndSettle();

    expect(mainRouter.state.uri.path, '/profile/history/add');
    expect(find.text('Country'), findsOneWidget);
    expect(find.text('Place'), findsOneWidget);
    mainRouter.go('/login');
  });

  testWidgets('uses the shared primary action in city details', (
    WidgetTester tester,
  ) async {
    mainRouter.go('/explore/city/lisbon');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final primaryAction = tester.widget<TravelPrimaryActionButton>(
      find.byType(TravelPrimaryActionButton),
    );
    expect(primaryAction.light, isTrue);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.bottomNavigationBar, isNull);
    expect(
      scaffold.floatingActionButtonLocation,
      FloatingActionButtonLocation.centerFloat,
    );
    expect(
      find.widgetWithText(FilledButton, 'Plan a trip to Lisbon'),
      findsOneWidget,
    );
    mainRouter.go('/login');
  });

  testWidgets('shows the review composer in POI details', (
    WidgetTester tester,
  ) async {
    mainRouter.go('/explore/city/lisbon/poi/miradouro_senhora_monte');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final primaryAction = tester.widget<TravelPrimaryActionButton>(
      find.byType(TravelPrimaryActionButton),
    );
    expect(primaryAction.light, isTrue);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.bottomNavigationBar, isNull);
    expect(
      scaffold.floatingActionButtonLocation,
      FloatingActionButtonLocation.centerFloat,
    );
    expect(find.text('Write a review'), findsOneWidget);
    expect(find.text('Add photos'), findsOneWidget);
    expect(find.text('Post'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'A useful local note');
    await tester.pump();
    final postButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Post'),
    );
    postButton.onPressed!();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Your review was posted.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2100));
    mainRouter.go('/login');
  });

  testWidgets('posts a top-level comment from the tips page', (
    WidgetTester tester,
  ) async {
    mainRouter.go('/explore/city/lisbon/poi/miradouro_senhora_monte/tips');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final primaryAction = tester.widget<TravelPrimaryActionButton>(
      find.byType(TravelPrimaryActionButton),
    );
    expect(primaryAction.light, isTrue);
    final reviewButton = find.widgetWithText(FilledButton, 'Write a review');
    expect(reviewButton, findsOneWidget);
    final scaffold = tester.widget<Scaffold>(
      find.ancestor(of: reviewButton, matching: find.byType(Scaffold)).first,
    );
    expect(
      scaffold.floatingActionButtonLocation,
      FloatingActionButtonLocation.centerFloat,
    );
    expect(find.text('Add photos'), findsNothing);

    await tester.tap(reviewButton);
    await tester.pumpAndSettle();

    expect(find.text('Write a review'), findsNWidgets(2));
    expect(find.text('Add photos'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'A tip-page comment');
    await tester.pump();
    final postButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Post'),
    );
    postButton.onPressed!();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('A tip-page comment'), findsOneWidget);
    expect(find.text('Your comment was posted.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2100));
    mainRouter.go('/login');
  });

  testWidgets('opens new trip as a full detail route', (
    WidgetTester tester,
  ) async {
    mainRouter.go('/itinerary');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('New trip'));
    await tester.pumpAndSettle();

    expect(mainRouter.state.uri.path, '/itinerary/new');
    expect(find.text('TRIP NAME'), findsOneWidget);
    expect(find.text('TRAVELERS'), findsOneWidget);
    mainRouter.go('/login');
  });
}
