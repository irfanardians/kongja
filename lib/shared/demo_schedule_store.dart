import 'package:flutter/material.dart';

enum DemoMeetRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  completed,
}

class DemoMeetRequest {
  const DemoMeetRequest({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.countryCode,
    required this.hostName,
    required this.eventType,
    required this.meetingAddress,
    required this.landmark,
    required this.date,
    required this.startHour,
    required this.durationHours,
    required this.coins,
    required this.status,
    required this.requestedAt,
  });

  final int id;
  final String userName;
  final String userAvatar;
  final String countryCode;
  final String hostName;
  final String eventType;
  final String meetingAddress;
  final String landmark;
  final DateTime date;
  final int startHour;
  final int durationHours;
  final int coins;
  final DemoMeetRequestStatus status;
  final DateTime requestedAt;

  int get endHour => startHour + durationHours;

  String get dateLabel => formatDemoDate(date);

  String get startTimeLabel => formatDemoHour(startHour);

  String get endTimeLabel => formatDemoHour(endHour);

  String get durationLabel => '$durationHours hours';

  String get requestedAtLabel => formatDemoRelativeTime(requestedAt);

  String get statusLabel {
    switch (status) {
      case DemoMeetRequestStatus.pending:
        return 'Submitted';
      case DemoMeetRequestStatus.accepted:
        return 'Accepted';
      case DemoMeetRequestStatus.rejected:
        return 'Rejected';
      case DemoMeetRequestStatus.cancelled:
        return 'Cancelled';
      case DemoMeetRequestStatus.completed:
        return 'Completed';
    }
  }

  String get statusDescription {
    switch (status) {
      case DemoMeetRequestStatus.pending:
        return 'Waiting for talent confirmation.';
      case DemoMeetRequestStatus.accepted:
        return 'Talent accepted your schedule request.';
      case DemoMeetRequestStatus.rejected:
        return 'Talent rejected this schedule request.';
      case DemoMeetRequestStatus.cancelled:
        return 'This request was cancelled.';
      case DemoMeetRequestStatus.completed:
        return 'This schedule has been completed.';
    }
  }

  bool get isUserNotificationVisible =>
      status == DemoMeetRequestStatus.accepted ||
      status == DemoMeetRequestStatus.rejected;
}

class DemoScheduleNotification {
  const DemoScheduleNotification({
    required this.request,
    required this.title,
    required this.body,
    required this.isPositive,
  });

  final DemoMeetRequest request;
  final String title;
  final String body;
  final bool isPositive;
}

const String demoCurrentUserName = 'Aditya Saputra';
const String demoCurrentUserAvatar =
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200';

class DemoScheduleStore extends ValueNotifier<List<DemoMeetRequest>> {
  DemoScheduleStore() : super(_seedRequests());

  int _nextId = 3;
  late final Map<String, List<DateTime>> _talentHolidayDates = {
    'Clara': _seedHolidayDates([21, 23]),
  };

  void addRequest(DemoMeetRequest request) {
    value = [request, ...value];
  }

  List<DemoMeetRequest> requestsForHost(String hostName) {
    return value.where((request) => request.hostName == hostName).toList();
  }

  List<DemoMeetRequest> requestsForUser(String userName) {
    return value.where((request) => request.userName == userName).toList();
  }

  List<DemoScheduleNotification> notificationsForUser(String userName) {
    return requestsForUser(userName)
        .where((request) => request.isUserNotificationVisible)
        .map((request) {
          final accepted = request.status == DemoMeetRequestStatus.accepted;
          return DemoScheduleNotification(
            request: request,
            title: accepted
                ? 'Your schedule was accepted'
                : 'Your schedule was rejected',
            body: accepted
                ? '${request.hostName} accepted ${request.eventType} on ${request.dateLabel} at ${request.startTimeLabel}.'
                : '${request.hostName} rejected ${request.eventType} on ${request.dateLabel} at ${request.startTimeLabel}.',
            isPositive: accepted,
          );
        })
        .toList(growable: false);
  }

  bool canOpenEventChat({
    required String userName,
    required String hostName,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    return requestsForUser(userName).any((request) {
      if (request.hostName != hostName ||
          request.status != DemoMeetRequestStatus.accepted) {
        return false;
      }

      final eventDate = normalizeDemoDate(request.date);
      final startWindow = eventDate.subtract(const Duration(days: 3));
      final endWindow = eventDate.add(const Duration(days: 1, hours: 23));
      return !currentTime.isBefore(startWindow) &&
          !currentTime.isAfter(endWindow);
    });
  }

  DemoMeetRequest? latestAcceptedRequestForUserHost({
    required String userName,
    required String hostName,
  }) {
    final matches = requestsForUser(userName)
        .where(
          (request) =>
              request.hostName == hostName &&
              request.status == DemoMeetRequestStatus.accepted,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return matches.isEmpty ? null : matches.first;
  }

  bool canHostOpenEventChat({
    required String hostName,
    required String userName,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    return requestsForHost(hostName).any((request) {
      if (request.userName != userName ||
          request.status != DemoMeetRequestStatus.accepted) {
        return false;
      }

      final eventDate = normalizeDemoDate(request.date);
      final startWindow = eventDate.subtract(const Duration(days: 3));
      final endWindow = eventDate.add(const Duration(days: 1, hours: 23));
      return !currentTime.isBefore(startWindow) &&
          !currentTime.isAfter(endWindow);
    });
  }

  DemoMeetRequest? latestAcceptedRequestForHostUser({
    required String hostName,
    required String userName,
  }) {
    final matches = requestsForHost(hostName)
        .where(
          (request) =>
              request.userName == userName &&
              request.status == DemoMeetRequestStatus.accepted,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return matches.isEmpty ? null : matches.first;
  }

  void updateRequestStatus(int requestId, DemoMeetRequestStatus status) {
    value = value
        .map(
          (request) => request.id == requestId
              ? DemoMeetRequest(
                  id: request.id,
                  userName: request.userName,
                  userAvatar: request.userAvatar,
                  countryCode: request.countryCode,
                  hostName: request.hostName,
                  eventType: request.eventType,
                  meetingAddress: request.meetingAddress,
                  landmark: request.landmark,
                  date: request.date,
                  startHour: request.startHour,
                  durationHours: request.durationHours,
                  coins: request.coins,
                  status: status,
                  requestedAt: request.requestedAt,
                )
              : request,
        )
        .toList(growable: false);
  }

  List<DateTime> holidayDatesForHost(String hostName) {
    return List<DateTime>.unmodifiable(
      _talentHolidayDates[hostName] ?? const <DateTime>[],
    );
  }

  bool isTalentHoliday({required String hostName, required DateTime date}) {
    return holidayDatesForHost(
      hostName,
    ).any((holiday) => isSameDemoDate(holiday, date));
  }

  bool hasActiveBookingOnDate({
    required String hostName,
    required DateTime date,
  }) {
    return value.any(
      (request) =>
          request.hostName == hostName &&
          request.status != DemoMeetRequestStatus.rejected &&
          request.status != DemoMeetRequestStatus.cancelled &&
          request.status != DemoMeetRequestStatus.completed &&
          isSameDemoDate(request.date, date),
    );
  }

  bool isDateLockedForHost({required String hostName, required DateTime date}) {
    return isTalentHoliday(hostName: hostName, date: date) ||
        hasActiveBookingOnDate(hostName: hostName, date: date);
  }

  bool canToggleHolidayDate({
    required String hostName,
    required DateTime date,
  }) {
    return !hasActiveBookingOnDate(hostName: hostName, date: date);
  }

  void toggleHolidayDate({required String hostName, required DateTime date}) {
    final normalizedDate = normalizeDemoDate(date);
    final dates = List<DateTime>.from(
      _talentHolidayDates[hostName] ?? const [],
    );
    final existingIndex = dates.indexWhere(
      (holiday) => isSameDemoDate(holiday, normalizedDate),
    );

    if (existingIndex >= 0) {
      dates.removeAt(existingIndex);
    } else {
      dates.add(normalizedDate);
    }

    _talentHolidayDates[hostName] = dates;
    notifyListeners();
  }

  DateTime? firstAvailableDateForHost({
    required String hostName,
    required DateTime start,
    int maxDaysAhead = 90,
  }) {
    for (var offset = 0; offset <= maxDaysAhead; offset++) {
      final candidate = normalizeDemoDate(start.add(Duration(days: offset)));
      if (!isDateLockedForHost(hostName: hostName, date: candidate)) {
        return candidate;
      }
    }
    return null;
  }

  DemoMeetRequest createRequest({
    required String hostName,
    required String eventType,
    required String meetingAddress,
    required String landmark,
    required DateTime date,
    required int startHour,
    required int durationHours,
  }) {
    final normalizedDate = normalizeDemoDate(date);
    if (isDateLockedForHost(hostName: hostName, date: normalizedDate)) {
      throw StateError('Selected date is not available for this talent.');
    }

    return DemoMeetRequest(
      id: _nextId++,
        userName: demoCurrentUserName,
        userAvatar: demoCurrentUserAvatar,
      countryCode: 'ID',
      hostName: hostName,
      eventType: eventType,
      meetingAddress: meetingAddress,
      landmark: landmark,
      date: normalizedDate,
      startHour: startHour,
      durationHours: durationHours,
      coins: 500,
      status: DemoMeetRequestStatus.pending,
      requestedAt: DateTime.now(),
    );
  }

  int get pendingCount => value
      .where((request) => request.status == DemoMeetRequestStatus.pending)
      .length;

  List<DemoMeetRequest> pendingRequests() {
    return value
        .where((request) => request.status == DemoMeetRequestStatus.pending)
        .toList();
  }
}

List<DemoMeetRequest> _seedRequests() {
  final today = normalizeDemoDate(DateTime.now());
  return [
    DemoMeetRequest(
      id: 1,
      userName: demoCurrentUserName,
      userAvatar: demoCurrentUserAvatar,
      countryCode: 'ID',
      hostName: 'Clara',
      eventType: 'Dinner Date',
      meetingAddress: 'Senopati, South Jakarta',
      landmark: 'Near Senayan City',
      date: today.add(const Duration(days: 1)),
      startHour: 19,
      durationHours: 3,
      coins: 500,
      status: DemoMeetRequestStatus.accepted,
      requestedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    DemoMeetRequest(
      id: 2,
      userName: demoCurrentUserName,
      userAvatar: demoCurrentUserAvatar,
      countryCode: 'ID',
      hostName: 'Mia',
      eventType: 'Cafe Meetup',
      meetingAddress: 'Seminyak, Bali',
      landmark: 'Close to Potato Head',
      date: today.add(const Duration(days: 4)),
      startHour: 15,
      durationHours: 2,
      coins: 420,
      status: DemoMeetRequestStatus.rejected,
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}

String formatDemoDate(DateTime date) {
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
}

String formatDemoHour(int hour) {
  final normalizedHour = hour % 24;
  final period = normalizedHour >= 12 ? 'PM' : 'AM';
  final displayHour = normalizedHour == 0
      ? 12
      : (normalizedHour > 12 ? normalizedHour - 12 : normalizedHour);
  return '${displayHour.toString().padLeft(2, '0')}:00 $period';
}

String formatDemoRelativeTime(DateTime time) {
  final difference = DateTime.now().difference(time);
  if (difference.inMinutes < 1) {
    return 'just now';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes} min ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours} hr ago';
  }
  return '${difference.inDays} day ago';
}

final demoScheduleStore = DemoScheduleStore();

DateTime normalizeDemoDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool isSameDemoDate(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

List<DateTime> _seedHolidayDates(List<int> days) {
  final now = DateTime.now();
  return days.map((day) {
    final candidate = DateTime(now.year, now.month, day);
    if (candidate.isBefore(normalizeDemoDate(now))) {
      return DateTime(now.year, now.month + 1, day);
    }
    return candidate;
  }).toList();
}
