import '../../domain/entities/appliance.dart';

class AppliancesState {
  final List<Appliance> appliances;
  final bool isLoading;
  final String? errorMessage;

  const AppliancesState({
    this.appliances = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AppliancesState copyWith({
    List<Appliance>? appliances,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppliancesState(
      appliances: appliances ?? this.appliances,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
