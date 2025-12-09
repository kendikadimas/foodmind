import '../models/community_post.dart';
import 'supabase_service.dart';

class PostDatabaseService {
  final SupabaseService _supabase = SupabaseService();

  // Get current user ID
  String? get currentUserId => _supabase.currentUserId;
  String? get currentUserEmail => _supabase.currentUserEmail;

  // Create a new post
  Future<String> createPost(CommunityPost post) async {
    if (currentUserId == null) {
      throw 'User belum login';
    }

    try {
      final response = await _supabase.client.from('posts').insert({
        'user_id': currentUserId,
        'author_name': post.authorName,
        'author_email': post.authorEmail,
        'content': post.content,
        'budget': post.budget,
        'location': post.location,
        'allergies': post.allergies,
        'preferences': post.preferences,
        'likes_count': post.likesCount,
        'liked_by': post.likedBy,
        'responses': post.responses.map((r) => {
          'id': r.id,
          'author_name': r.authorName,
          'author_email': r.authorEmail,
          'content': r.content,
          'restaurant_name': r.restaurantName,
          'estimated_price': r.estimatedPrice,
          'created_at': r.createdAt.toIso8601String(),
          'likes_count': r.likesCount,
          'liked_by': r.likedBy,
        }).toList(),
        'created_at': post.createdAt.toIso8601String(),
      }).select('id').single();

      return response['id'].toString();
    } catch (e) {
      throw 'Gagal membuat post: $e';
    }
  }

  // Update post
  Future<void> updatePost(String postId, CommunityPost post) async {
    if (currentUserId == null) {
      throw 'User belum login';
    }

    try {
      await _supabase.client.from('posts').update({
        'content': post.content,
        'budget': post.budget,
        'location': post.location,
        'allergies': post.allergies,
        'preferences': post.preferences,
        'likes_count': post.likesCount,
        'liked_by': post.likedBy,
        'responses': post.responses.map((r) => {
          'id': r.id,
          'author_name': r.authorName,
          'author_email': r.authorEmail,
          'content': r.content,
          'restaurant_name': r.restaurantName,
          'estimated_price': r.estimatedPrice,
          'created_at': r.createdAt.toIso8601String(),
          'likes_count': r.likesCount,
          'liked_by': r.likedBy,
        }).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', postId);
    } catch (e) {
      throw 'Gagal update post: $e';
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    if (currentUserId == null) {
      throw 'User belum login';
    }

    try {
      // Check if user is the author
      final post = await _supabase.client
          .from('posts')
          .select('user_id')
          .eq('id', postId)
          .single();
      
      if (post['user_id'] != currentUserId) {
        throw 'Kamu ga bisa hapus post orang lain!';
      }

      await _supabase.client.from('posts').delete().eq('id', postId);
    } catch (e) {
      throw 'Gagal hapus post: $e';
    }
  }

  // Get all posts (ordered by newest first)
  Stream<List<Map<String, dynamic>>> streamAllPosts() {
    return _supabase.client
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          return data;
        });
  }

  // Get posts by user
  Stream<List<Map<String, dynamic>>> streamUserPosts(String userId) {
    return _supabase.client
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) {
          return data;
        });
  }

  // Get single post
  Future<Map<String, dynamic>?> getPost(String postId) async {
    try {
      final response = await _supabase.client
          .from('posts')
          .select()
          .eq('id', postId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw 'Gagal ambil post: $e';
    }
  }

  // Toggle like on post
  Future<void> toggleLike(String postId, bool isCurrentlyLiked) async {
    if (currentUserEmail == null) {
      throw 'User belum login';
    }

    try {
      final post = await getPost(postId);
      if (post == null) throw 'Post tidak ditemukan';

      List<String> likedBy = List<String>.from(post['liked_by'] ?? []);
      int likesCount = post['likes_count'] ?? 0;

      if (isCurrentlyLiked) {
        likedBy.remove(currentUserEmail);
        likesCount = (likesCount - 1).clamp(0, 999999);
      } else {
        if (!likedBy.contains(currentUserEmail)) {
          likedBy.add(currentUserEmail!);
        }
        likesCount++;
      }

      await _supabase.client.from('posts').update({
        'liked_by': likedBy,
        'likes_count': likesCount,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', postId);
    } catch (e) {
      throw 'Gagal toggle like: $e';
    }
  }

  // Add response to post
  Future<void> addResponse(String postId, PostResponse response) async {
    if (currentUserId == null) {
      throw 'User belum login';
    }

    try {
      final post = await getPost(postId);
      if (post == null) throw 'Post tidak ditemukan';

      List<dynamic> responses = List.from(post['responses'] ?? []);
      responses.add({
        'id': response.id,
        'author_name': response.authorName,
        'author_email': response.authorEmail,
        'content': response.content,
        'restaurant_name': response.restaurantName,
        'estimated_price': response.estimatedPrice,
        'created_at': response.createdAt.toIso8601String(),
        'likes_count': response.likesCount,
        'liked_by': response.likedBy,
      });

      await _supabase.client.from('posts').update({
        'responses': responses,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', postId);
    } catch (e) {
      throw 'Gagal tambah response: $e';
    }
  }

  // Convert Supabase data to CommunityPost
  CommunityPost postFromSupabase(Map<String, dynamic> data) {
    return CommunityPost(
      id: data['id'].toString(),
      authorName: data['author_name'] as String,
      authorEmail: data['author_email'] as String,
      content: data['content'] as String,
      budget: (data['budget'] as num?)?.toDouble(),
      location: data['location'] as String?,
      allergies: List<String>.from(data['allergies'] ?? []),
      medicalConditions: [],
      preferences: List<String>.from(data['preferences'] ?? []),
      likesCount: data['likes_count'] as int? ?? 0,
      likedBy: List<String>.from(data['liked_by'] ?? []),
      responses: (data['responses'] as List<dynamic>?)?.map((r) {
        return PostResponse(
          id: r['id'] as String,
          authorName: r['author_name'] as String,
          authorEmail: r['author_email'] as String,
          content: r['content'] as String,
          restaurantName: r['restaurant_name'] as String?,
          estimatedPrice: (r['estimated_price'] as num?)?.toDouble(),
          createdAt: DateTime.parse(r['created_at'] as String),
          likesCount: r['likes_count'] as int? ?? 0,
          likedBy: List<String>.from(r['liked_by'] ?? []),
        );
      }).toList() ?? [],
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}
