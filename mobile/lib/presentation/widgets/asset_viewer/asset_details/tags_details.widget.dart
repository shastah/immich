import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/data/store.dart';
import 'package:immich_mobile/domain/models/asset/base_asset.model.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/extensions/theme_extensions.dart';
import 'package:immich_mobile/generated/translations.g.dart';

class TagsDetails extends ConsumerWidget {
  final BaseAsset asset;

  const TagsDetails({super.key, required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsEnabled = ref.watch(
      Store.userMetadata.preferences().select((value) => value.valueOrNull?.tagsEnabled ?? false),
    );

    final remoteAssetId = switch (asset) {
      RemoteAsset(:final id) => id,
      LocalAsset(:final remoteAssetId) => remoteAssetId,
    };

    if (!tagsEnabled || remoteAssetId == null) {
      return const SizedBox.shrink();
    }

    final tags = ref.watch(Store.tags.forAsset(remoteAssetId)).valueOrNull ?? const [];
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = [...tags]..sort((a, b) => a.value.compareTo(b.value));

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            context.t.tags,
            style: context.textTheme.labelLarge?.copyWith(color: context.colorScheme.onSurfaceSecondary),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in sorted)
                Chip(
                  avatar: const Icon(Icons.sell_outlined, size: 16),
                  label: Text(tag.value),
                  visualDensity: VisualDensity.compact,
                  shape: const StadiumBorder(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
