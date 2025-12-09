import 'package:hive/hive.dart';

part 'community_post.g.dart';

@HiveType(typeId: 2)
class CommunityPost extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String authorName;

  @HiveField(2)
  String authorEmail;

  @HiveField(3)
  String content;

  @HiveField(4)
  String? location;

  @HiveField(5)
  double? budget;

  @HiveField(6)
  List<String> allergies;

  @HiveField(7)
  List<String> medicalConditions;

  @HiveField(8)
  List<String> preferences;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  List<PostResponse> responses;

  @HiveField(11)
  int likesCount;

  @HiveField(12)
  List<String> likedBy;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    this.location,
    this.budget,
    this.allergies = const [],
    this.medicalConditions = const [],
    this.preferences = const [],
    required this.createdAt,
    this.responses = const [],
    this.likesCount = 0,
    this.likedBy = const [],
  });

  // Helper methods
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${(difference.inDays / 7).floor()} minggu yang lalu';
    }
  }

  String get budgetText {
    if (budget == null) return 'Budget tidak disebutkan';
    if (budget! < 1000) {
      return 'Rp ${budget!.toInt()}';
    } else if (budget! < 1000000) {
      return 'Rp ${(budget! / 1000).toStringAsFixed(budget! % 1000 == 0 ? 0 : 1)}rb';
    } else {
      return 'Rp ${(budget! / 1000000).toStringAsFixed(budget! % 1000000 == 0 ? 0 : 1)}jt';
    }
  }

  bool isLikedBy(String userEmail) {
    return likedBy.contains(userEmail);
  }

  void toggleLike(String userEmail) {
    if (isLikedBy(userEmail)) {
      likedBy.remove(userEmail);
      likesCount = (likesCount - 1).clamp(0, double.infinity).toInt();
    } else {
      likedBy.add(userEmail);
      likesCount++;
    }
  }
}

@HiveType(typeId: 3)
class PostResponse extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String authorName;

  @HiveField(2)
  String authorEmail;

  @HiveField(3)
  String content;

  @HiveField(4)
  String? recommendedFood;

  @HiveField(5)
  String? restaurantName;

  @HiveField(6)
  String? location;

  @HiveField(7)
  double? estimatedPrice;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  int likesCount;

  @HiveField(10)
  List<String> likedBy;

  PostResponse({
    required this.id,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    this.recommendedFood,
    this.restaurantName,
    this.location,
    this.estimatedPrice,
    required this.createdAt,
    this.likesCount = 0,
    this.likedBy = const [],
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${(difference.inDays / 7).floor()} minggu yang lalu';
    }
  }

  String get priceText {
    if (estimatedPrice == null) return '';
    if (estimatedPrice! < 1000) {
      return 'Rp ${estimatedPrice!.toInt()}';
    } else if (estimatedPrice! < 1000000) {
      return 'Rp ${(estimatedPrice! / 1000).toStringAsFixed(estimatedPrice! % 1000 == 0 ? 0 : 1)}rb';
    } else {
      return 'Rp ${(estimatedPrice! / 1000000).toStringAsFixed(estimatedPrice! % 1000000 == 0 ? 0 : 1)}jt';
    }
  }

  bool isLikedBy(String userEmail) {
    return likedBy.contains(userEmail);
  }

  void toggleLike(String userEmail) {
    if (isLikedBy(userEmail)) {
      likedBy.remove(userEmail);
      likesCount = (likesCount - 1).clamp(0, double.infinity).toInt();
    } else {
      likedBy.add(userEmail);
      likesCount++;
    }
  }
}