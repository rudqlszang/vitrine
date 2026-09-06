import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/order.dart';
import '../../domain/profile.dart';
import '../../domain/savings.dart';
import 'order_box.dart';
import 'profile_box.dart';

/// main() 에서 열어둔 박스를 주입한다.
final orderBoxProvider = Provider<OrderBox>(
  (ref) => throw UnimplementedError('main 에서 override 해야 한다'),
);

/// 주문 목록. 이 앱의 유일한 진실이다.
/// 잔고·절약은 전부 여기서 파생된다.
class OrdersNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() => ref.read(orderBoxProvider).all();

  Future<void> add(Order order) async {
    await ref.read(orderBoxProvider).put(order);
    state = [order, ...state];
  }

  Future<void> cancel(String id) async {
    final box = ref.read(orderBoxProvider);
    final target = state.where((o) => o.id == id).firstOrNull;
    if (target == null || !target.isCancellable) return;

    final cancelled = target.cancel();
    await box.put(cancelled);
    state = [
      for (final o in state) if (o.id == id) cancelled else o,
    ];
  }

  /// 배송 단계가 시간에 따라 바뀌므로 주기적으로 화면을 다시 그린다.
  void refresh() => state = [...state];
}

final ordersProvider =
    NotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

/// 잔고·확정절약·대기절약.
final savingsProvider = Provider<Savings>(
  (ref) => Savings.from(ref.watch(ordersProvider)),
);

/// main() 에서 열어둔 프로필 박스.
final profileBoxProvider = Provider<ProfileBox>(
  (ref) => throw UnimplementedError('main 에서 override 해야 한다'),
);

/// 가입 정보. null 이면 아직 가입 전이다.
class ProfileNotifier extends Notifier<Profile?> {
  @override
  Profile? build() => ref.read(profileBoxProvider).readProfile();

  Future<void> save(Profile p) async {
    await ref.read(profileBoxProvider).writeProfile(p);
    state = p;
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, Profile?>(ProfileNotifier.new);

/// 배송지. null 이면 아직 입력 전이다.
class AddressNotifier extends Notifier<Address?> {
  @override
  Address? build() => ref.read(profileBoxProvider).readAddress();

  Future<void> save(Address a) async {
    await ref.read(profileBoxProvider).writeAddress(a);
    state = a;
  }
}

final addressProvider =
    NotifierProvider<AddressNotifier, Address?>(AddressNotifier.new);
