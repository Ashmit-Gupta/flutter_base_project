import 'package:basic_project_setup/features/security/pin/domain/repo_contract/pin_repo.dart';

class VerifyPinUseCase {
  final PinRepositoryContract repo;

  VerifyPinUseCase(this.repo);

  Future<bool> call(String pin) {
    return repo.verifyPin(pin);
  }
}