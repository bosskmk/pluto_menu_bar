import 'package:mockito/mockito.dart';

class Handle {
  void onTap() {}
}

class MockHandle extends Mock implements Handle {}
