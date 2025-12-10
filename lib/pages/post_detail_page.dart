import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import '../models/community_post.dart';
import '../models/user_profile.dart';
import '../providers/service_providers.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  final CommunityPost post;
  final String postId;

  const PostDetailPage({super.key, required this.post, required this.postId});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _replyController = TextEditingController();
  final _restaurantController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  UserProfile? currentUser;
  bool isSubmittingReply = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final box = await Hive.openBox<UserProfile>('userProfile');
    if (box.isNotEmpty) {
      setState(() {
        currentUser = box.getAt(0);
      });
    }
  }

  Future<void> _submitReply() async {
    if (!_formKey.currentState!.validate() || currentUser == null) {
      return;
    }

    setState(() => isSubmittingReply = true);

    try {
      final response = PostResponse(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: currentUser!.name ?? '',
        authorEmail: currentUser!.email ?? '',
        content: _replyController.text.trim(),
        restaurantName: _restaurantController.text.trim().isNotEmpty 
            ? _restaurantController.text.trim() 
            : null,
        estimatedPrice: _priceController.text.trim().isNotEmpty 
            ? double.tryParse(_priceController.text.trim()) 
            : null,
        createdAt: DateTime.now(),
      );

      // Add to Firestore
      await ref.read(postDatabaseServiceProvider).addResponse(widget.postId, response);

      // Add to local state
      setState(() {
        widget.post.responses.add(response);
      });

      // Clear form
      _replyController.clear();
      _restaurantController.clear();
      _priceController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Balasan berhasil disimpan ke cloud! ☁️'),
            backgroundColor: AppTheme.primaryOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal nambah balasan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isSubmittingReply = false);
    }
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Silakan login terlebih dahulu untuk membalas post ini.'),
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
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'Detail Post',
          style: AppTheme.headingMedium,
        ),
      ),
      body: Column(
        children: [
          // Post content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPostCard(),
                  const SizedBox(height: 24),
                  _buildResponsesSection(),
                ],
              ),
            ),
          ),
          
          // Reply input (only if logged in)
          if (currentUser != null) _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                  child: Text(
                    widget.post.authorName.isNotEmpty 
                        ? widget.post.authorName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.authorName,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.post.timeAgo,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Post content
            Text(
              widget.post.content,
              style: AppTheme.bodyMedium,
            ),
            
            const SizedBox(height: 16),
            
            // Post details
            if (widget.post.budget != null || 
                widget.post.location != null ||
                widget.post.allergies.isNotEmpty ||
                widget.post.preferences.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.post.budget != null)
                    _buildInfoChip(Icons.account_balance_wallet, widget.post.budgetText),
                  if (widget.post.location != null)
                    _buildInfoChip(Icons.location_on, widget.post.location!),
                  if (widget.post.allergies.isNotEmpty)
                    _buildInfoChip(Icons.warning, '${widget.post.allergies.length} alergi'),
                  if (widget.post.preferences.isNotEmpty)
                    _buildInfoChip(Icons.restaurant_menu, '${widget.post.preferences.length} preferensi'),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                _buildActionButton(
                  Icons.thumb_up_outlined,
                  '${widget.post.likesCount}',
                  () => _togglePostLike(),
                  isSelected: currentUser?.email != null && widget.post.isLikedBy(currentUser!.email!),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  Icons.chat_bubble_outline,
                  '${widget.post.responses.length}',
                  null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesSection() {
    if (widget.post.responses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Balasan',
              style: AppTheme.headingSmall.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Jadilah yang pertama memberikan rekomendasi!',
              style: AppTheme.bodySmall.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Balasan (${widget.post.responses.length})',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 12),
        ...widget.post.responses.map((response) => _buildResponseCard(response)),
      ],
    );
  }

  Widget _buildResponseCard(PostResponse response) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    response.authorName.isNotEmpty 
                        ? response.authorName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        response.authorName,
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        response.timeAgo,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Response content
            Text(
              response.content,
              style: AppTheme.bodySmall,
            ),
            
            // Restaurant/price info
            if (response.restaurantName != null || response.estimatedPrice != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (response.restaurantName != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.restaurant, size: 14, color: AppTheme.primaryOrange),
                          const SizedBox(width: 4),
                          Text(
                            response.restaurantName!,
                            style: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (response.estimatedPrice != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 14, color: AppTheme.primaryOrange),
                          const SizedBox(width: 4),
                          Text(
                            response.priceText,
                            style: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 8),
            
            // Response action
            Row(
              children: [
                _buildActionButton(
                  Icons.thumb_up_outlined,
                  '${response.likesCount}',
                  () => _toggleResponseLike(response),
                  isSelected: currentUser?.email != null && response.isLikedBy(currentUser!.email!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Reply text field
            TextFormField(
              controller: _replyController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Bagikan rekomendasi makanan Anda...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Harap isi balasan Anda';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 8),
            
            // Optional restaurant and price fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _restaurantController,
                    decoration: InputDecoration(
                      hintText: 'Nama restoran (opsional)',
                      prefixIcon: const Icon(Icons.restaurant, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Harga (opsional)',
                      prefixText: 'Rp ',
                      prefixIcon: const Icon(Icons.attach_money, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmittingReply ? null : _submitReply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmittingReply
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Kirim Balasan',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
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
          Icon(icon, size: 12, color: AppTheme.primaryOrange),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w500,
              fontSize: 11,
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
              size: 16,
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

  Future<void> _togglePostLike() async {
    if (currentUser == null) {
      _showLoginRequired();
      return;
    }

    try {
      final isLiked = widget.post.isLikedBy(currentUser!.email!);
      
      // Update Firestore
      await ref.read(postDatabaseServiceProvider).toggleLike(widget.postId, isLiked);
      
      // Update local state
      setState(() {
        if (currentUser!.email != null) {
          widget.post.toggleLike(currentUser!.email!);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal nyimpan like: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleResponseLike(PostResponse response) async {
    if (currentUser == null) {
      _showLoginRequired();
      return;
    }

    try {
      // Update local state
      setState(() {
        if (currentUser!.email != null) {
          response.toggleLike(currentUser!.email!);
        }
      });
      
      // Update Firestore with full post data
      await ref.read(postDatabaseServiceProvider).updatePost(widget.postId, widget.post);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal nyimpan like: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    _restaurantController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}