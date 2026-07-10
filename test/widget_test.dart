import 'package:flutter_test/flutter_test.dart';

import 'package:traveling_app/main.dart';
import 'package:traveling_app/route/index.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/store/user/user_store.dart';

void main() {
  testWidgets('renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Continue with Email'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
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
