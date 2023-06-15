import 'package:hooks_riverpod/hooks_riverpod.dart';

extension ProviderContainerExt on ProviderContainer {
  void setupTestFor<T>(ProviderListenable<T> provider) {
    listen(provider, (previous, value) {}, fireImmediately: true);
  }
}
