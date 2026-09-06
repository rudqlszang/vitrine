import 'package:flutter/material.dart';

import '../core/format/won_format.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../data/catalog/resolved_item.dart';

/// 상품 카드.
///
/// 이미지 소스가 몰마다 배경·여백이 달라서, 카드 자체는 최대한 조용하게 둔다.
/// 그림자·테두리 없이 여백으로만 분리하고, 이미지 배경을 [AppColors.surface] 로
/// 통일해서 소스 편차를 덮는다.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.item, this.onTap});

  final ResolvedItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: _Thumbnail(url: item.imageUrl),
          ),
          const SizedBox(height: 10),
          Text(
            item.brand.toUpperCase(),
            style: AppTypo.brand,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            item.title,
            style: AppTypo.body.copyWith(color: AppColors.textSecond),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(Won.format(item.priceKrw), style: AppTypo.price),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final src = url;
    if (src == null || src.isEmpty) return const _EmptyThumb();

    // 수집 단계에서 흰 배경 스튜디오 컷만 고르므로 배경도 흰색으로 맞춘다.
    // 회색이면 이미지 여백과 카드 배경 사이에 띠가 생긴다.
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.all(8),
      child: Image.network(
        src,
        fit: BoxFit.contain,
        // 이미지가 뜨기 전 회색 판이 깜빡이지 않도록 페이드로 받는다.
        frameBuilder: (context, child, frame, wasSyncLoaded) {
          if (wasSyncLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (_, _, _) => const _EmptyThumb(),
      ),
    );
  }
}

/// 이미지가 없거나 실패했을 때. 깨진 아이콘 대신 조용한 빈 판을 둔다.
class _EmptyThumb extends StatelessWidget {
  const _EmptyThumb();

  @override
  Widget build(BuildContext context) {
    return Container(color: AppColors.surface);
  }
}
