// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/health_status.dart';
import '../models/readiness_status.dart';

part 'health_client.g.dart';

@RestApi()
abstract class HealthClient {
  factory HealthClient(Dio dio, {String? baseUrl}) = _HealthClient;

  /// Liveness.
  ///
  /// Отвечает, пока процесс жив. В зависимости не ходит.
  @GET('/health')
  Future<HealthStatus> getHealth();

  /// Readiness.
  ///
  /// Проверяет Postgres, Redis и доступность бакета.
  @GET('/health/ready')
  Future<ReadinessStatus> getReadiness();
}
