import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

setupMocktailFallbacks() {
  registerFallbackValue(RequestOptions());
}
