import 'package:boorusphere/utils/extensions/number.dart';
import 'package:boorusphere/utils/extensions/pick.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('number', () {
    test('valid ImageChunk', () {
      const chunk =
          ImageChunkEvent(expectedTotalBytes: 1024, cumulativeBytesLoaded: 512);
      expect(chunk.progressPercentage?.ratio, .5);
      expect(chunk.progressRatio?.percentage, 50);
    });

    test('nulled ImageChunk', () {
      const chunk =
          ImageChunkEvent(expectedTotalBytes: null, cumulativeBytesLoaded: 512);
      expect(chunk.progressPercentage?.ratio, null);
      expect(chunk.progressRatio?.percentage, null);
    });
  });

  group('pick', () {
    const tags = {
      'mixed': ['foo', 'bar', 3],
      'words': 'foo bar',
      'blank': '   ',
      'null': null,
    };

    test('asStringList', () {
      expect(pick(tags, 'mixed').asStringList(), ['foo', 'bar', '3']);
      expect(pick(tags, 'blank').asStringList(), []);
      expect(pick(tags, 'null').asStringList(), []);
    });

    test('toWordList', () {
      expect(pick(tags, 'words').toWordList(), ['foo', 'bar']);
      expect(pick(tags, 'blank').toWordList(), []);
      expect(pick(tags, 'null').toWordList(), []);
    });
  });

  group('string', () {
    const imgUrl = 'file:///sdcard/Downloads/Boorusphere/cool-photo.webp';
    const stuffUrl = 'file:///sdcard/Downloads/Boorusphere/cool-stuff';

    test('mimeType', () {
      expect(imgUrl.mimeType, 'image/webp');
    });

    test('unknown mimeType', () {
      expect(stuffUrl.mimeType, 'application/octet-stream');
    });

    test('fileName', () {
      expect(imgUrl.fileName, 'cool-photo.webp');
    });

    test('fileName w/o ext', () {
      expect(stuffUrl.fileName, 'cool-stuff');
    });

    test('fileExt', () {
      expect(imgUrl.fileExt, 'webp');
    });

    test('empty fileExt', () {
      expect(stuffUrl.fileExt, '');
    });

    test('toWordList', () {
      expect('foo bar 3'.toWordList(), ['foo', 'bar', '3']);
    });
  });
}
