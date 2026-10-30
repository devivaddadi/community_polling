import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:community_polling_app/models/poll_model.dart';
import 'package:community_polling_app/providers/auth_provider.dart';
import 'package:community_polling_app/providers/community_provider.dart';
import 'package:community_polling_app/providers/decision_provider.dart';
import 'package:community_polling_app/providers/poll_provider.dart';
import 'package:community_polling_app/screens/admin/admin_dashboard_screen.dart';
import 'package:community_polling_app/screens/polls/poll_detail_screen.dart';
import 'package:community_polling_app/screens/polls/poll_results_screen.dart';
import 'package:community_polling_app/widgets/polls/delete_poll_dialog.dart';
import 'package:community_polling_app/widgets/polls/poll_card.dart';

void main() {
  group('Admin Delete Poll - Provider Tests', () {
    test('PollProvider.deletePoll removes poll from list and updates count', () async {
      final pollProvider = PollProvider();
      final initialCount = pollProvider.polls.length;
      expect(initialCount, greaterThan(0));

      final pollToDelete = pollProvider.polls.first;
      await pollProvider.deletePoll(pollToDelete.id);

      expect(pollProvider.polls.length, equals(initialCount - 1));
      expect(pollProvider.totalPollsCount, equals(initialCount - 1));
      expect(pollProvider.getPollById(pollToDelete.id), isNull);
    });
  });

  group('Admin Delete Poll - PollCard Widget Tests', () {
    testWidgets('PollCard does not show delete button when onDelete is null', (tester) async {
      final testPoll = PollModel(
        id: 'test_poll_1',
        communityId: 'c1',
        creatorId: 'u_test',
        creatorName: 'Test User',
        creatorAvatar: '',
        question: 'Should we add bike racks?',
        category: 'Facilities',
        options: [
          PollOption(id: 'opt1', text: 'Yes', voteCount: 5, percentage: 50.0),
          PollOption(id: 'opt2', text: 'No', voteCount: 5, percentage: 50.0),
        ],
        createdAt: DateTime.now(),
        endsAt: DateTime.now().add(const Duration(days: 3)),
        totalVotes: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PollCard(
              poll: testPoll,
              hasVoted: false,
              onTap: () {},
              onVoteTap: () {},
              onDelete: null,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets('PollCard shows delete button and triggers onDelete when provided', (tester) async {
      bool deleteCalled = false;
      final testPoll = PollModel(
        id: 'test_poll_2',
        communityId: 'c1',
        creatorId: 'u_test',
        creatorName: 'Test User',
        creatorAvatar: '',
        question: 'Should we add solar panels?',
        category: 'Eco',
        options: [
          PollOption(id: 'opt1', text: 'Yes', voteCount: 8, percentage: 80.0),
          PollOption(id: 'opt2', text: 'No', voteCount: 2, percentage: 20.0),
        ],
        createdAt: DateTime.now(),
        endsAt: DateTime.now().add(const Duration(days: 3)),
        totalVotes: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PollCard(
              poll: testPoll,
              hasVoted: false,
              onTap: () {},
              onVoteTap: () {},
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });
  });

  group('Admin Delete Poll - Confirmation Dialog Tests', () {
    testWidgets('showDeletePollDialog displays title, question and buttons', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDeletePollDialog(
                    context,
                    pollTitle: 'Sample Question?',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Poll'), findsOneWidget);
      expect(find.textContaining('Sample Question?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('showDeletePollDialog returns true on clicking Delete', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDeletePollDialog(
                    context,
                    pollTitle: 'Sample Question?',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap Delete button
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });

  group('Admin Delete Poll - Screens Integration', () {
    testWidgets('AdminDashboardScreen displays delete button for each poll', (tester) async {
      final pollProvider = PollProvider();
      final authProvider = AuthProvider();
      final communityProvider = CommunityProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: pollProvider),
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: communityProvider),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Each poll in recent polls has a delete button
      expect(find.byTooltip('Delete Poll'), findsWidgets);
    });

    testWidgets('PollDetailScreen displays delete button in AppBar for Admin', (tester) async {
      final pollProvider = PollProvider();
      final authProvider = AuthProvider();
      final poll = pollProvider.polls.first;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: pollProvider),
            ChangeNotifierProvider.value(value: authProvider),
          ],
          child: MaterialApp(
            home: PollDetailScreen(poll: poll),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(authProvider.isAdmin, isTrue);
      expect(find.byTooltip('Delete Poll'), findsOneWidget);
    });

    testWidgets('PollResultsScreen displays delete button in AppBar for Admin', (tester) async {
      final pollProvider = PollProvider();
      final authProvider = AuthProvider();
      final decisionProvider = DecisionProvider();
      final poll = pollProvider.polls.first;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: pollProvider),
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: decisionProvider),
          ],
          child: MaterialApp(
            home: PollResultsScreen(poll: poll),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(authProvider.isAdmin, isTrue);
      expect(find.byTooltip('Delete Poll'), findsOneWidget);
    });
  });
}
