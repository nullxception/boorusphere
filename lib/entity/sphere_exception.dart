import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sphere_exception.freezed.dart';

@freezed
class SphereException with _$SphereException implements IOException {
  const factory SphereException({required String message}) = _SphereException;
}
