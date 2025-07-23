// lib/utils/place_parser.dart

import 'package:goreto/data/models/places/place_model.dart';

List<PlaceModel> parsePlaces(List<dynamic> jsonList) {
  return jsonList.map((e) => PlaceModel.fromJson(e)).toList();
}
