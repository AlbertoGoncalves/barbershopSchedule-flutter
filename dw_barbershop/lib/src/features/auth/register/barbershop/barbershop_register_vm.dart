import 'package:dw_barbershop/src/core/fp/either.dart';
import 'package:dw_barbershop/src/core/providers/application_providers.dart';
import 'package:dw_barbershop/src/features/auth/register/barbershop/barbershop_register_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'barbershop_register_vm.g.dart';

@riverpod
class BarbershopRegisterVm extends _$BarbershopRegisterVm {
  @override
  BarbershopRegisterState build() => BarbershopRegisterState.initial();

  void addOrRemoveOpenHour(int hour) {
    final openingHours = state.openingHours;

    if (openingHours.contains(hour)) {
      openingHours.remove(hour);
    } else {
      openingHours.add(hour);
    }

    state = state.copyWith(openingHours: openingHours);
  }

  void addOrRemoveOpenDay(String weekDays) {
    final openingDays = state.openingDays;

    if (openingDays.contains(weekDays)) {
      openingDays.remove(weekDays);
    } else {
      openingDays.add(weekDays);
    }

    state = state.copyWith(openingDays: openingDays);
  }

  Future<void> register(String name, String email) async {
    final repository = ref.watch(barbershopRepositoryProvider);
    final BarbershopRegisterState(:openingDays, :openingHours) = state;

    final dto = (
      name: name,
      email: email,
      openingDays: openingDays, 
      openingHours: openingHours
    ); 

    final registerResult = await repository.save(dto);

    switch (registerResult) {
      case Success():
        ref.invalidate(getMyBarbershopProvider);
        state = state.copyWith(status: BarbershopRegisterStateStatus.success);
      case Failure():
        state = state.copyWith(status: BarbershopRegisterStateStatus.error);
    }
  }
}
