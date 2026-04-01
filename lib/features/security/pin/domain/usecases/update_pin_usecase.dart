import 'package:basic_project_setup/features/security/pin/domain/repo_contract/pin_repo.dart';

class UpdatePinUseCase {
  final PinRepositoryContract repo;

  UpdatePinUseCase(this.repo);

  Future<void> call(String oldPin, String newPin) {
    return repo.updatePin(oldPin, newPin);
  }
}