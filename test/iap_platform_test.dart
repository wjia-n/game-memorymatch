import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memorymatch/services/iap_service.dart';

void main() {
  test('iOS maps to the single Gold Star product', () {
    expect(StoreService.productIdsFor(TargetPlatform.iOS), {'memorymatchstar'});
    expect(StoreService.starId, 'memorymatchstar');
  });
  test('Android maps to coffee + chocolate only', () {
    expect(StoreService.productIdsFor(TargetPlatform.android),
        {'memorymatchcoffee', 'memorymatchchocolate'});
    expect(StoreService.productIdsFor(TargetPlatform.android),
        isNot(contains('memorymatchstar')));
  });
}
