import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/router/route_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteMetadataRegistry.of', () {
    test('exact match returns registered metadata', () {
      final metadata = RouteMetadataRegistry.of(AppRoutes.premium);

      expect(metadata.hidesChrome, isTrue);
      expect(metadata.showsAssistantFab, isFalse);
      expect(metadata.isFullScreenModal, isTrue);
    });

    test('exact match works for /settings/subscription', () {
      final metadata = RouteMetadataRegistry.of(AppRoutes.subscriptionSettings);

      expect(metadata.hidesChrome, isFalse);
      expect(metadata.showsAssistantFab, isFalse);
    });

    test('prefix match resolves child paths to parent metadata', () {
      final metadata = RouteMetadataRegistry.of(
        '${AppRoutes.subscriptionSettings}/manage',
      );

      expect(metadata.hidesChrome, isFalse);
      expect(metadata.showsAssistantFab, isFalse);
    });

    test('query parameters do not break exact matching', () {
      final metadata = RouteMetadataRegistry.of(
        '${AppRoutes.premium}?source=today',
      );

      expect(metadata.hidesChrome, isTrue);
      expect(metadata.isFullScreenModal, isTrue);
    });

    test('unknown route falls back to standard metadata', () {
      final metadata = RouteMetadataRegistry.of('/does-not-exist');

      expect(metadata.hidesChrome, RouteMetadata.standard.hidesChrome);
      expect(
        metadata.showsAssistantFab,
        RouteMetadata.standard.showsAssistantFab,
      );
      expect(
        metadata.isFullScreenModal,
        RouteMetadata.standard.isFullScreenModal,
      );
    });
  });
}
