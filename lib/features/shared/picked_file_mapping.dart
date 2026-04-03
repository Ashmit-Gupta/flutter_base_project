import '../../core/ui/models/picked_file.dart';
import 'models/app_file_model.dart';

extension AppFileModelPickedMapping on AppFileModel {
  PickedFile get asPickedFile => PickedFile(name: name, path: path, size: size);
}
