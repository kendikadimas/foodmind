import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import '../models/community_post.dart';
import '../models/user_profile.dart';
import '../services/post_database_service.dart';
import 'create_post_page.dart';
import 'post_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final PostDatabaseService _postDb = PostDatabaseService();
  Box<UserProfile>? userBox;
  UserProfile? currentUser;
  bool isLoading = true;
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      print('🔍 Initializing community page...');
      userBox = await Hive.openBox<UserProfile>('userProfile');
      print('📦 Hive box opened. Items count: ${userBox!.length}');
      
      if (userBox!.isNotEmpty) {
        currentUser = userBox!.getAt(0);
        print('✅ Current user loaded: ${currentUser?.name} (${currentUser?.email})');
      } else {
        print('❌ No user found in Hive box');
      }
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error initializing community data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    // Trigger rebuild with stream
    setState(() {});
  }

  void _navigateToCreatePost() async {
    if (currentUser == null) {
      _showLoginRequired();
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostPage()),
    );

    if (result == true) {
      _refreshPosts();
    }
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Silakan login terlebih dahulu untuk membuat post di komunitas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'Komunitas FoodMind',
          style: AppTheme.headingMedium,
        ),
        actions: [
          IconButton(
            onPressed: _refreshPosts,
            icon: const Icon(Icons.refresh),
            color: AppTheme.primaryOrange,
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _postDb.streamAllPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refreshPosts,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final postData = posts[index];
                final post = _postDb.postFromSupabase(postData);
                return _buildPostCard(post, postData['id'].toString());
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreatePost,
        backgroundColor: AppTheme.primaryOrange,
        label: const Text(
          'Buat Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Post',
              style: AppTheme.headingMedium.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Jadilah yang pertama membuat post dan bertanya tentang rekomendasi makanan!',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreatePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Buat Post Pertama',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post, String postId) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(post: post, postId: postId),
            ),
          );
          if (result == true) {
            _refreshPosts();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                    child: Text(
                      post.authorName.isNotEmpty 
                          ? post.authorName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          post.timeAgo,
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Post content
              Text(
                post.content,
                style: AppTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Post details
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (post.budget != null)
                    _buildInfoChip(Icons.account_balance_wallet, post.budgetText),
                  if (post.location != null)
                    _buildInfoChip(Icons.location_on, post.location!),
                  if (post.allergies.isNotEmpty)
                    _buildInfoChip(Icons.warning, '${post.allergies.length} alergi'),
                  if (post.preferences.isNotEmpty)
                    _buildInfoChip(Icons.restaurant_menu, '${post.preferences.length} preferensi'),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  _buildActionButton(
                    Icons.thumb_up_outlined,
                    '${post.likesCount}',
                    () => _toggleLike(post),
                    isSelected: currentUser != null && currentUser!.email != null && post.isLikedBy(currentUser!.email!),
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    Icons.chat_bubble_outline,
                    '${post.responses.length}',
                    null,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryOrange),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String text,
    VoidCallback? onTap, {
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.primaryOrange : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: AppTheme.bodySmall.copyWith(
                color: isSelected ? AppTheme.primaryOrange : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLike(CommunityPost post) {
    if (currentUser == null) {
      _showLoginRequired();
      return;
    }

    // Toggle like locally for instant UI feedback
    setState(() {
      if (currentUser!.email != null) {
        post.toggleLike(currentUser!.email!);
      }
    });
    
    // Note: Like is only stored locally
    // To persist to Supabase, need to implement updatePost API call
  }
}