import 'package:mocktail/mocktail.dart';

class FakePodListener<T> extends Mock {
  void call(T? previous, T value);
}
