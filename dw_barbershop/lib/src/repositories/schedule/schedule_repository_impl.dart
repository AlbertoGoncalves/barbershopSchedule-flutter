import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dw_barbershop/src/core/exceptions/repository_exception.dart';

import 'package:dw_barbershop/src/core/fp/either.dart';

import 'package:dw_barbershop/src/core/fp/nil.dart';
import 'package:dw_barbershop/src/core/rest_client/rest_client.dart';
import 'package:dw_barbershop/src/model/schedule_model.dart';

import './schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final RestClient restClient;

  ScheduleRepositoryImpl({required this.restClient});

  @override
  Future<Either<RepositoryException, Nil>> scheduleClient(
      ({
        int barbershopId,
        String clientName,
        DateTime date,
        int time,
        int userId,
      }) scheduleDate) async {
    try {
      await restClient.auth.post('/schedules', data: {
        'barbershop_id': scheduleDate.barbershopId,
        'user_id': scheduleDate.userId,
        'client_name': scheduleDate.clientName,
        'date': scheduleDate.date.toIso8601String(),
        'time': scheduleDate.time,
      });

      return Success(nil);
    } on DioException catch (e, s) {
      log('Erro ao registrar agendamento', error: e, stackTrace: s);
      return Failure(RepositoryException(message: 'Erro ao agendar horário'));
    }
  }

  @override
  Future<Either<RepositoryException, List<ScheduleModel>>> findScheduleByDate(
      ({
        DateTime date,
        int userId,
      }) filter) async {
    try {
      final Response(:List data) = await restClient.auth.get('/schedules',
          queryParameters: {
            'user_id': filter.userId,
            'date': filter.date.toIso8601String()
          });
      final schedules = data.map((s) => ScheduleModel.fromMap(s)).toList();
      return Success(schedules);
    } on DioException catch (e, s) {
      log('json invalido', error: e, stackTrace: s);
      return Failure(
        RepositoryException(message: 'Erro ao buscar agendamento de uma data'),
      );
    } on ArgumentError catch (e, s) {
      log('json invalido', error: e, stackTrace: s);
      return Failure(
        RepositoryException(message: 'json invalido'),
      );
    }
  }
}
