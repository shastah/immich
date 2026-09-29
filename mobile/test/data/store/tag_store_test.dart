import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/data/server/tag.dart';
import 'package:immich_mobile/data/store.dart';
import 'package:immich_mobile/domain/models/tag.model.dart';
import 'package:mocktail/mocktail.dart';

class _MockTagApi extends Mock implements TagApiRepository {}

const _tag = Tag(id: 't1', value: 'Travel');

void main() {
  late _MockTagApi api;
  late ProviderContainer container;

  setUp(() {
    api = _MockTagApi();
    container = ProviderContainer(overrides: [tagApiRepositoryProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);
  });

  Future<List<Tag>> load(String assetId) {
    // Keep the provider alive
    container.listen(Store.tags.forAsset(assetId), (_, _) {});
    return container.read(Store.tags.forAsset(assetId).future);
  }

  test('forAsset serves fetched tags', () async {
    when(() => api.getForAsset('asset')).thenAnswer((_) async => [_tag]);
    when(() => api.getForAsset('broken')).thenThrow(Exception('offline'));

    expect(await load('asset'), [_tag]);
    expect(await load('broken'), isEmpty);
  });

  test('applyToAssets refetches the tags of the tagged assets', () async {
    when(() => api.getForAsset('asset')).thenAnswer((_) async => []);
    expect(await load('asset'), isEmpty);

    when(() => api.bulkTagAssets(['asset'], ['t1'])).thenAnswer((_) async => 1);
    when(() => api.getForAsset('asset')).thenAnswer((_) async => [_tag]);

    await container.read(Store.tags).applyToAssets(['asset'], ['t1']);

    expect(await container.read(Store.tags.forAsset('asset').future), [_tag]);
  });
}
