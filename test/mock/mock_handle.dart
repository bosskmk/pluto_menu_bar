import 'package:mockito/mockito.dart';

class Handle {
  void onTab() {}
}

class MockHandle extends Mock implements Handle {}
