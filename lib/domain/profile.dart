/// 계정. 서버도 인증도 없다. Hive 에 이름 몇 줄 쓰는 것이 전부다.
///
/// 그럼에도 가입 단계를 두는 이유는 실감 때문이다.
/// 배송이 "누구에게" 가는지가 없으면 주문 화면이 비어 보인다.
class Profile {
  const Profile({
    required this.name,
    required this.joinedAt,
    this.nickname = '',
  });

  final String name;
  final String nickname;
  final DateTime joinedAt;

  String get displayName => nickname.isNotEmpty ? nickname : name;

  Map<String, dynamic> toMap() => {
        'name': name,
        'nickname': nickname,
        'joinedAt': joinedAt.millisecondsSinceEpoch,
      };

  static Profile fromMap(Map<dynamic, dynamic> m) => Profile(
        name: m['name'] as String,
        nickname: (m['nickname'] as String?) ?? '',
        joinedAt:
            DateTime.fromMillisecondsSinceEpoch(m['joinedAt'] as int),
      );
}

/// 배송지.
class Address {
  const Address({
    required this.recipient,
    required this.phone,
    required this.postcode,
    required this.line1,
    this.line2 = '',
  });

  final String recipient;
  final String phone;
  final String postcode;

  /// 도로명 주소.
  final String line1;

  /// 상세 주소.
  final String line2;

  String get full => line2.isEmpty ? line1 : '$line1 $line2';

  bool get isComplete =>
      recipient.isNotEmpty && phone.isNotEmpty && line1.isNotEmpty;

  Map<String, dynamic> toMap() => {
        'recipient': recipient,
        'phone': phone,
        'postcode': postcode,
        'line1': line1,
        'line2': line2,
      };

  static Address fromMap(Map<dynamic, dynamic> m) => Address(
        recipient: m['recipient'] as String,
        phone: m['phone'] as String,
        postcode: (m['postcode'] as String?) ?? '',
        line1: m['line1'] as String,
        line2: (m['line2'] as String?) ?? '',
      );
}
