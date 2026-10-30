import '../models/user_model.dart';
import '../models/community_model.dart';
import '../models/poll_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/decision_model.dart';

class MockDataService {
  static List<UserModel> getMockUsers() {
    return [
      UserModel(
        id: 'u_priya',
        name: 'Priya Patel',
        email: 'priya.patel@example.com',
        phone: '+91 98765 43210',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        role: UserRole.admin,
        communityId: 'c1',
        joinedAt: DateTime(2023, 3, 15),
      ),
      UserModel(
        id: 'u_rohit',
        name: 'Rohit Verma',
        email: 'rohit.verma@example.com',
        phone: '+91 98765 43211',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        role: UserRole.admin,
        communityId: 'c1',
        joinedAt: DateTime(2023, 4, 1),
      ),
      UserModel(
        id: 'u_anita',
        name: 'Anita Sharma',
        email: 'anita.sharma@example.com',
        phone: '+91 98765 43212',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        role: UserRole.member,
        communityId: 'c1',
        joinedAt: DateTime(2023, 6, 10),
      ),
      UserModel(
        id: 'u_mehul',
        name: 'Mehul Joshi',
        email: 'mehul.joshi@example.com',
        phone: '+91 98765 43213',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        role: UserRole.member,
        communityId: 'c1',
        joinedAt: DateTime(2023, 7, 20),
      ),
      UserModel(
        id: 'u_neha',
        name: 'Neha Singh',
        email: 'neha.singh@example.com',
        phone: '+91 98765 43214',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        role: UserRole.member,
        communityId: 'c1',
        joinedAt: DateTime(2023, 8, 5),
      ),
      UserModel(
        id: 'u_vikram',
        name: 'Vikram Rao',
        email: 'vikram.rao@example.com',
        phone: '+91 98765 43215',
        avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
        role: UserRole.member,
        communityId: 'c1',
        joinedAt: DateTime(2023, 9, 12),
      ),
    ];
  }

  static List<CommunityModel> getMockCommunities() {
    return [
      CommunityModel(
        id: 'c1',
        name: 'Green Valley Community',
        description: 'A vibrant, eco-conscious residential neighborhood in North Bengaluru.',
        location: 'Bengaluru, India',
        iconUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=150',
        memberCount: 128,
        adminIds: ['u_priya', 'u_rohit'],
        createdAt: DateTime(2022, 1, 1),
        category: 'Gated Residential Society',
      ),
      CommunityModel(
        id: 'c2',
        name: 'Sunshine Heights Society',
        description: 'Modern high-rise residential apartment association.',
        location: 'Pune, India',
        iconUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=150',
        memberCount: 85,
        adminIds: ['u_priya'],
        createdAt: DateTime(2022, 5, 10),
        category: 'Apartment Complex',
      ),
      CommunityModel(
        id: 'c3',
        name: 'Oakridge Eco Township',
        description: 'Sustainable living community focusing on clean green living.',
        location: 'Hyderabad, India',
        iconUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=150',
        memberCount: 210,
        adminIds: ['u_rohit'],
        createdAt: DateTime(2021, 11, 20),
        category: 'Township',
      ),
    ];
  }

  static List<PollModel> getMockPolls() {
    final now = DateTime.now();

    return [
      PollModel(
        id: 'poll_1',
        communityId: 'c1',
        creatorId: 'u_priya',
        creatorName: 'Priya Patel',
        creatorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        question: 'What improvement should we prioritize in our community?',
        description: 'Please cast your vote to help the executive council allocate Q3 infrastructure budget effectively.',
        category: 'Infrastructure',
        pollType: PollType.public,
        createdAt: now.subtract(const Duration(days: 3)),
        endsAt: now.add(const Duration(days: 2)),
        totalVotes: 324,
        status: PollStatus.active,
        voterUserIds: ['u_rohit', 'u_anita', 'u_mehul'],
        options: [
          PollOption(id: 'opt_1_1', text: 'Better Street Lighting', voteCount: 146, percentage: 45.0),
          PollOption(id: 'opt_1_2', text: 'Clean Water Supply', voteCount: 81, percentage: 25.0),
          PollOption(id: 'opt_1_3', text: 'More Parks & Greenery', voteCount: 65, percentage: 20.0),
          PollOption(id: 'opt_1_4', text: 'Waste Management', voteCount: 26, percentage: 8.0),
          PollOption(id: 'opt_1_5', text: 'Other (Please specify)', voteCount: 6, percentage: 2.0),
        ],
      ),
      PollModel(
        id: 'poll_2',
        communityId: 'c1',
        creatorId: 'u_rohit',
        creatorName: 'Rohit Verma',
        creatorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        question: 'Which day is best for the community event?',
        description: 'Organizing our Annual Summer Meet & Greet with food stalls and games.',
        category: 'Events',
        pollType: PollType.public,
        createdAt: now.subtract(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 5)),
        totalVotes: 120,
        status: PollStatus.active,
        voterUserIds: ['u_neha'],
        options: [
          PollOption(id: 'opt_2_1', text: 'Saturday Evening (6 PM - 9 PM)', voteCount: 66, percentage: 55.0),
          PollOption(id: 'opt_2_2', text: 'Sunday Morning (9 AM - 12 PM)', voteCount: 42, percentage: 35.0),
          PollOption(id: 'opt_2_3', text: 'Sunday Evening (5 PM - 8 PM)', voteCount: 12, percentage: 10.0),
        ],
      ),
      PollModel(
        id: 'poll_3',
        communityId: 'c1',
        creatorId: 'u_priya',
        creatorName: 'Priya Patel',
        creatorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        question: 'Should we start a community recycling program?',
        description: 'Proposal to partner with EcoCycle for weekly door-to-door dry and wet waste collection.',
        category: 'Environment',
        pollType: PollType.public,
        createdAt: now.subtract(const Duration(days: 2)),
        endsAt: now.add(const Duration(days: 7)),
        totalVotes: 210,
        status: PollStatus.active,
        voterUserIds: ['u_anita', 'u_vikram'],
        options: [
          PollOption(id: 'opt_3_1', text: 'Yes, definitely participate', voteCount: 151, percentage: 72.0),
          PollOption(id: 'opt_3_2', text: 'Yes, but need doorstep bins', voteCount: 44, percentage: 21.0),
          PollOption(id: 'opt_3_3', text: 'No, not interested', voteCount: 15, percentage: 7.0),
        ],
      ),
      PollModel(
        id: 'poll_4',
        communityId: 'c1',
        creatorId: 'u_rohit',
        creatorName: 'Rohit Verma',
        creatorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        question: 'Clubhouse gym equipment upgrade proposal',
        description: 'Reviewing budget to install 3 new treadmills, multi-gym station, and dumbbell racks.',
        category: 'Recreation',
        pollType: PollType.public,
        createdAt: now.subtract(const Duration(days: 14)),
        endsAt: now.subtract(const Duration(days: 2)),
        totalVotes: 188,
        status: PollStatus.closed,
        voterUserIds: ['u_priya', 'u_rohit', 'u_anita', 'u_mehul', 'u_neha'],
        options: [
          PollOption(id: 'opt_4_1', text: 'Approve full equipment upgrade', voteCount: 122, percentage: 65.0),
          PollOption(id: 'opt_4_2', text: 'Approve cardio equipment only', voteCount: 47, percentage: 25.0),
          PollOption(id: 'opt_4_3', text: 'Reject / Keep current setup', voteCount: 19, percentage: 10.0),
        ],
      ),
    ];
  }

  static List<CommentModel> getMockComments() {
    final now = DateTime.now();

    return [
      CommentModel(
        id: 'comm_1',
        pollId: 'poll_1',
        userId: 'u_anita',
        userName: 'Anita Sharma',
        userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        text: 'We really need better street lights near the main road for safety.',
        timestamp: now.subtract(const Duration(hours: 2)),
        likesCount: 12,
        likedByUserIds: ['u_priya', 'u_mehul'],
        replies: [
          CommentReply(
            id: 'rep_1_1',
            commentId: 'comm_1',
            userId: 'u_priya',
            userName: 'Priya Patel',
            userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
            text: 'Agreed! The council has already surveyed 14 blind spots along Gate 2 and East Avenue.',
            timestamp: now.subtract(const Duration(hours: 1, minutes: 40)),
            likesCount: 5,
            likedByUserIds: ['u_anita'],
          ),
        ],
      ),
      CommentModel(
        id: 'comm_2',
        pollId: 'poll_1',
        userId: 'u_rohit',
        userName: 'Rohan Verma',
        userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        text: 'Clean water is equally important. We face issues every summer.',
        timestamp: now.subtract(const Duration(hours: 1)),
        likesCount: 8,
        likedByUserIds: ['u_anita', 'u_mehul'],
      ),
      CommentModel(
        id: 'comm_3',
        pollId: 'poll_1',
        userId: 'u_mehul',
        userName: 'Mehul Joshi',
        userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        text: 'Parks and greenery will improve the environment for our children.',
        timestamp: now.subtract(const Duration(minutes: 30)),
        likesCount: 5,
        likedByUserIds: ['u_neha'],
      ),
      CommentModel(
        id: 'comm_4',
        pollId: 'poll_1',
        userId: 'u_neha',
        userName: 'Neha Singh',
        userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        text: 'Waste management and proper compost pits will also keep stray animals away.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        likesCount: 3,
        likedByUserIds: [],
      ),
      CommentModel(
        id: 'comm_5',
        pollId: 'poll_2',
        userId: 'u_anita',
        userName: 'Anita Sharma',
        userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        text: 'Saturday evening gives working families time to relax and participate without rush.',
        timestamp: now.subtract(const Duration(hours: 4)),
        likesCount: 7,
        likedByUserIds: ['u_rohit'],
      ),
    ];
  }

  static List<NotificationModel> getMockNotifications() {
    final now = DateTime.now();

    return [
      NotificationModel(
        id: 'notif_1',
        title: 'New Poll',
        message: 'A new poll "Which day is best for the community event?" has been created.',
        type: NotificationType.newPoll,
        timestamp: now.subtract(const Duration(minutes: 10)),
        isRead: false,
        relatedPollId: 'poll_2',
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'Poll Closing Soon',
        message: 'Poll "What improvement should we prioritize in our community?" is closing in 6 hours.',
        type: NotificationType.pollClosing,
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        relatedPollId: 'poll_1',
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'Results Published',
        message: 'Results for "Should we start a community recycling program?" are out now.',
        type: NotificationType.resultsPublished,
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
        relatedPollId: 'poll_3',
      ),
      NotificationModel(
        id: 'notif_4',
        title: 'New Comment',
        message: 'Anita Sharma commented on a poll you followed.',
        type: NotificationType.newComment,
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
        relatedPollId: 'poll_1',
      ),
      NotificationModel(
        id: 'notif_5',
        title: 'Decision Recorded',
        message: 'Council approved action plan for Clubhouse gym upgrade based on poll results.',
        type: NotificationType.decisionRecorded,
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        relatedPollId: 'poll_4',
        relatedDecisionId: 'dec_1',
      ),
    ];
  }

  static List<DecisionModel> getMockDecisions() {
    final now = DateTime.now();

    return [
      DecisionModel(
        id: 'dec_1',
        communityId: 'c1',
        pollId: 'poll_4',
        pollTitle: 'Clubhouse gym equipment upgrade proposal',
        title: 'Gym Upgrade & Fitness Center Modernization',
        summary: 'Allocated ₹3,50,000 budget to procure commercial grade treadmills and dumbbell sets.',
        rationale: '65% of residents voted in favor of complete overhaul to accommodate peak morning usage.',
        status: DecisionStatus.inProgress,
        decidedBy: 'Executive Committee (Priya Patel, Rohit Verma)',
        decidedAt: now.subtract(const Duration(days: 2)),
        estimatedBudget: '₹3,50,000',
        targetCompletionDate: '20 June 2024',
        actionItems: [
          ActionItem(
            id: 'act_1',
            title: 'Finalize vendor quotation with FitPro Systems',
            assignedTo: 'Rohit Verma',
            dueDate: now.add(const Duration(days: 3)),
            isCompleted: true,
          ),
          ActionItem(
            id: 'act_2',
            title: 'Clubhouse electrical rewiring & flooring rubber matting',
            assignedTo: 'Estate Supervisor',
            dueDate: now.add(const Duration(days: 8)),
            isCompleted: false,
          ),
          ActionItem(
            id: 'act_3',
            title: 'Delivery, assembly and resident induction session',
            assignedTo: 'Committee Members',
            dueDate: now.add(const Duration(days: 15)),
            isCompleted: false,
          ),
        ],
      ),
      DecisionModel(
        id: 'dec_2',
        communityId: 'c1',
        pollId: 'poll_1',
        pollTitle: 'What improvement should we prioritize in our community?',
        title: 'Solar High-Mast Street Lighting Project (Phase 1)',
        summary: 'Installing 18 smart solar-powered LED poles along North Boulevard & Gate 2.',
        rationale: 'Leading poll priority with 45% votes (146 responses) and strong resident discussion backing.',
        status: DecisionStatus.proposed,
        decidedBy: 'Security & Infra Sub-committee',
        decidedAt: now.subtract(const Duration(hours: 12)),
        estimatedBudget: '₹2,20,000',
        targetCompletionDate: '15 July 2024',
        actionItems: [
          ActionItem(
            id: 'act_4',
            title: 'Issue Tender RFP for solar street lighting suppliers',
            assignedTo: 'Infra Committee',
            dueDate: now.add(const Duration(days: 5)),
            isCompleted: false,
          ),
          ActionItem(
            id: 'act_5',
            title: 'Hold public community townhall for vendor demo',
            assignedTo: 'Priya Patel',
            dueDate: now.add(const Duration(days: 10)),
            isCompleted: false,
          ),
        ],
      ),
    ];
  }
}
