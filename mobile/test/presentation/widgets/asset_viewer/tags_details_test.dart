import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immich_mobile/data/store.dart';
import 'package:immich_mobile/domain/models/tag.model.dart';
import 'package:immich_mobile/presentation/widgets/asset_viewer/asset_details/tags_details.widget.dart';

import '../../../unit/factories/remote_asset_factory.dart';
import '../../../widget_tester_extensions.dart';

void main() {
  final asset = RemoteAssetFactory.create();
  const tags = [Tag(id: 't2', value: 'Travel'), Tag(id: 't1', value: 'Family/Kids')];

  Future<void> pump(WidgetTester tester, {required bool tagsEnabled, List<Tag> tags = tags}) =>
      tester.pumpConsumerWidget(
        TagsDetails(asset: asset),
        overrides: [
          Store.userMetadata.preferences().overrideWith((ref) => Stream.value(.new(tagsEnabled: tagsEnabled))),
          Store.tags.forAsset(asset.id).overrideWith((ref) async => tags),
        ],
      );

  testWidgets('shows the asset tags sorted by value', (tester) async {
    await pump(tester, tagsEnabled: true);

    final labels = tester.widgetList<Chip>(find.byType(Chip)).map((chip) => (chip.label as Text).data).toList();
    expect(labels, ['Family/Kids', 'Travel']);
  });

  testWidgets('hidden when tags are disabled', (tester) async {
    await pump(tester, tagsEnabled: false);

    expect(find.byType(Chip), findsNothing);
  });

  testWidgets('hidden when the asset has no tags', (tester) async {
    await pump(tester, tagsEnabled: true, tags: const []);

    expect(find.byType(Chip), findsNothing);
    expect(find.byType(Text), findsNothing);
  });
}
