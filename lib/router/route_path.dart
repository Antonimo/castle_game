class RoutePath {
  final String id;
  final String? argument;
  RoutePath.lander()
      : id = 'lander',
        argument = null;
  RoutePath.details(String itemId)
      : id = 'details',
        argument = itemId;
  bool get isLanderPage => id == 'lander';
  bool get isDetailsPage => id == 'details';
}