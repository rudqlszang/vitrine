import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/catalog/catalog_repository.dart';
import '../../data/catalog/resolved_item.dart';
import '../../widgets/product_card.dart';
import 'home_header.dart';

/// 홈(쇼핑) 화면.
///
/// 잔고·절약 헤더 + 카테고리 필터 + 2열 상품 그리드.
/// 잔고/절약은 5단계에서 Hive 와 연결한다. 지금은 초기값을 그대로 보여준다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _initialBalance = 1000000000000; // 1조

  final _repo = CatalogRepository();
  List<ResolvedItem> _items = const [];
  String? _category;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bundled = await _repo.loadBundled();
    if (!mounted) return;
    setState(() {
      _items = bundled.items;
      _loading = false;
    });

    // 원격에 새 버전이 있으면 조용히 갈아끼운다. 실패해도 화면은 그대로다.
    final fresh = await _repo.fetchIfNewer(bundled.version);
    if (fresh != null && mounted) {
      setState(() => _items = fresh.items);
    }
  }

  List<ResolvedItem> get _visible {
    final c = _category;
    if (c == null) return _items;
    return _items.where((i) => i.category == c).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>[];
    for (final i in _items) {
      if (!categories.contains(i.category)) categories.add(i.category);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const SizedBox.shrink()
            : CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: HomeHeader(
                      balance: _initialBalance,
                      saved: 0,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _CategoryBar(
                      categories: categories,
                      selected: _category,
                      onSelect: (c) => setState(() => _category = c),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      8,
                      AppSpacing.screenPadding,
                      AppSpacing.sectionGap,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.cardGap,
                        mainAxisSpacing: AppSpacing.sectionGap,
                        childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => ProductCard(item: _visible[i]),
                        childCount: _visible.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 카테고리 필터. 알약 버튼 대신 텍스트만 쓴다. 선택된 것만 검게.
class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, i) {
          final label = i == 0 ? Strings.categoryAll : categories[i - 1];
          final value = i == 0 ? null : categories[i - 1];
          final active = selected == value;
          return GestureDetector(
            onTap: () => onSelect(value),
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Text(
                label,
                style: AppTypo.body.copyWith(
                  color: active ? AppColors.textPrimary : AppColors.textSecond,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
