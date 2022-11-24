import 'package:boorusphere/data/repository/booru/entity/post.dart';

extension PostExt on Post {
  String get heroTag => '$id@$serverId';
}
