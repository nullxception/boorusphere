import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UiBlurState extends StateNotifier<bool> {
  UiBlurState(super.state, this.repo);

  final SettingRepo repo;

  Future<bool> enable(bool value) async {
    state = value;
    await repo.put(Setting.uiBlur, value);
    return state;
  }
}
