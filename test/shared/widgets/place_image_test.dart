import 'package:flutter_test/flutter_test.dart';
import 'package:wanderboard/shared/widgets/atoms/place_image.dart';

void main() {
  test('a curated "id:" photo resolves to that exact picsum image', () {
    const image = PlaceImage(seed: 'id:15', aspectRatio: 1, pixelWidth: 300);

    expect(image.url, 'https://picsum.photos/id/15/300/300');
  });

  test('a free seed keeps resolving through picsum seeds', () {
    const image = PlaceImage(seed: 'wb-lib-1', aspectRatio: 2, pixelWidth: 400);

    expect(image.url, 'https://picsum.photos/seed/wb-lib-1/400/200');
  });
}
