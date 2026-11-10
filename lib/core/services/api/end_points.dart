abstract final class EndPoints {
  // static String get baseUrl => EnvConfig.apiBaseUrl;
  static String get uri => 'https://dori.toldpath.com/api/v1';
  static String get placeSlug => 'mira';
  static String get baseUrl => '$uri/places/$placeSlug';

  /// Home
  static final String home = '$baseUrl/home';
  static final String categories = '$baseUrl/categories'; // TODO:
  static final String services = '$baseUrl/services';
  static String service(int id) => '$services/$id';
  static String serviceReviews(int id) => '${service(id)}/reviews';
  static final String staff = '$baseUrl/staff';
  static String staffMember(int id) => '$staff/$id';
  static final String reviews = '$baseUrl/reviews';
  static final String busyHours = '$baseUrl/insights/busy-hours';
  static final String auth = '$baseUrl/auth';
  static final String register = '$auth/register';
  static final String login = '$auth/login';
  static final String me = '$auth/me';
  static final String profile = '$auth/profile';
  static final String logout = '$auth/logout';
  static final String notifications = '$baseUrl/notifications';
  static final String readAllNotifications = '$notifications/read-all';
  static final String availabilityDays = '$baseUrl/availability/days';
  static final String availabilitySlots = '$baseUrl/availability/slots';
  static final String couponCheck = '$baseUrl/coupons/check';
  static final String bookings = '$baseUrl/bookings';
  static final String waitlist = '$baseUrl/waitlist';
  static final String queue = '$baseUrl/queue';
  static final String queueTickets = '$queue/tickets';
  static final String myQueueTicket = '$queue/my-ticket';
  static String cancelQueueTicket(int id) => '$queueTickets/$id/cancel';
  static String waitlistEntry(int id) => '$waitlist/$id';
  static String claimWaitlistEntry(int id) => '${waitlistEntry(id)}/claim';
  static String booking(int id) => '$bookings/$id';
  static String rescheduleBooking(int id) => '${booking(id)}/reschedule';
  static String cancelBooking(int id) => '${booking(id)}/cancel';
  static String reviewBooking(int id) => '${booking(id)}/review';
}
