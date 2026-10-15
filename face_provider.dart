import 'dart:math';
import 'package:flutter/material.dart';

/// Лицо в игре. Уникально идентифицируется [id].
class Face {
  const Face({required this.id, required this.image});
  final String id;
  final ImageProvider image;
}

/// Источник лиц. Позволяет заменить генератор на любой другой
/// (свой StyleGAN-сервис, generated.photos API, заранее скачанные фото).
abstract class FaceProvider {
  Future<Face> nextFace();

  Future<List<Face>> nextFaces(int n) async {
    final out = <Face>[];
    for (var i = 0; i < n; i++) {
      out.add(await nextFace());
    }
    return out;
  }
}

/// Фотореалистичные лица из StyleGAN: каждый запрос к thispersondoesnotexist.com
/// возвращает новое сгенерированное лицо (1024x1024 JPEG).
///
/// ВНИМАНИЕ: это исследовательский демо-эндпоинт — может быть медленным
/// или недоступным. Для продакшена используйте:
///  - generated.photos (платный API, есть бесплатный тариф)
///  - свой StyleGAN2-ADA/StyleGAN3-сервис
///  - офлайн: AssetFaceProvider + tools/download_faces.sh
class GanFaceProvider implements FaceProvider {
  GanFaceProvider({this.baseUrl = 'https://thispersondoesnotexist.com/'});

  final String baseUrl;
  int _seq = 0;

  @override
  Future<Face> nextFace() async {
    _seq++;
    final id = 'gan_${DateTime.now().millisecondsSinceEpoch}_$_seq';
    // Уникальный query-параметр: без него HTTP-кэш может вернуть ту же картинку
    return Face(id: id, image: NetworkImage('$baseUrl?t=$id'));
  }
}

/// Лица из заранее скачанных файлов assets/faces/face_0001.jpg ...
/// Полностью офлайн, мгновенная загрузка.
class AssetFaceProvider implements FaceProvider {
  AssetFaceProvider({required this.count}) : assert(count > 0);

  final int count;
  final _rng = Random();
  final _used = <String>{};

  @override
  Future<Face> nextFace() async {
    var guard = 0;
    String id;
    do {
      id = 'face_${(1 + _rng.nextInt(count)).toString().padLeft(4, '0')}';
    } while (_used.contains(id) && guard++ < count * 2);
    _used.add(id);
    if (_used.length > count * 0.9) _used.clear(); // не исчерпать запас
    return Face(id: id, image: AssetImage('assets/faces/$id.jpg'));
  }
}
