import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/features/condition/presentation/data/region_loader.dart';

final regionHierarchyProvider = FutureProvider<RegionHierarchy>((ref) async {
  return await loadRegionHierarchy();
});
