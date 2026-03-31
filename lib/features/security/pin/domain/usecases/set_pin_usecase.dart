import 'package:basic_project_setup/features/security/pin/domain/repo_contract/pin_repo.dart';

class SetPinUseCase {
  final PinRepositoryContract repo;

  SetPinUseCase(this.repo);

  Future<void> call(String pin) {
    return repo.setPin(pin);
  }
}