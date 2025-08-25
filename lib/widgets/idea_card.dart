import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Add this import
import '../models/idea.dart';

class IdeaCard extends StatefulWidget {
  final Idea idea;
  final Future<bool> Function(String) onVote;
  final bool hasVoted;

  const IdeaCard({
    super.key,
    required this.idea,
    required this.onVote,
    required this.hasVoted,
  });

  @override
  State<IdeaCard> createState() => _IdeaCardState();
}

class _IdeaCardState extends State<IdeaCard> {
  bool _isExpanded = false;
  bool _isVoting = false;

  void _showMsg(String msg, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color ?? Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Updated format date method with better formatting
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return "Just now";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return "$weeks week${weeks == 1 ? '' : 's'} ago";
    } else {
      // For older dates, show full date and time
      return DateFormat('MMM d, y • h:mm a').format(date);
    }
  }

  // Helper method to get responsive margin
  EdgeInsets _getCardMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Mobile: Small margins
      return const EdgeInsets.symmetric(horizontal: 0, vertical: 8);
    } else if (screenWidth < 1200) {
      // Tablet: Medium margins
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      // Desktop: Larger margins to prevent cards from being too wide
      final horizontalMargin = (screenWidth * 0.15).clamp(32.0, 120.0);
      return EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 8);
    }
  }

  // Helper method to get responsive card padding
  EdgeInsets _getCardPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return const EdgeInsets.all(16);
    } else if (screenWidth < 1200) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final voted = widget.hasVoted;

    return Container(
      margin: _getCardMargin(context),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: _getCardPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.idea.startupName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.idea.tagline,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _scoreColor(widget.idea.aiRating),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⭐ ${widget.idea.aiRating}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Text(
                  widget.idea.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  maxLines: _isExpanded ? null : 2,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Responsive layout for bottom row
                LayoutBuilder(
                  builder: (context, constraints) {
                    // If width is too narrow, stack vertically
                    if (constraints.maxWidth < 400) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(voted, colorScheme),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildActionButtons(colorScheme),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Normal horizontal layout
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoRow(voted, colorScheme),
                          _buildActionButtons(colorScheme),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(bool voted, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.thumb_up,
          size: 16,
          color: voted ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.idea.voteCount} vote${widget.idea.voteCount == 1 ? '' : 's'}',
          style: TextStyle(
            color: voted ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: voted ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.access_time,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(widget.idea.createdAt),
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    final voted = widget.hasVoted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: Text(
            _isExpanded ? 'Show less' : 'Read more',
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: (voted || _isVoting) ? null : _handleVote,
          style: ElevatedButton.styleFrom(
            backgroundColor: voted ? colorScheme.secondary : colorScheme.primary,
            foregroundColor: voted ? colorScheme.onSecondary : colorScheme.onPrimary,
            disabledBackgroundColor: colorScheme.surfaceVariant,
            disabledForegroundColor: colorScheme.onSurfaceVariant,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: _isVoting
              ? SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(
              color: colorScheme.onPrimary,
              strokeWidth: 2,
            ),
          )
              : Icon(voted ? Icons.check : Icons.thumb_up, size: 16),
          label: Text(
            _isVoting ? 'Voting...' : (voted ? 'Voted' : 'Vote'),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Future<void> _handleVote() async {
    if (_isVoting) return;
    setState(() => _isVoting = true);
    try {
      final ok = await widget.onVote(widget.idea.id);
      if (mounted) {
        setState(() => _isVoting = false);
        if (ok) {
          _showMsg('👍 Vote recorded!', color: Colors.green);
        } else {
          _showMsg('Already voted or failed to vote.', color: Colors.orange);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isVoting = false);
        _showMsg('Failed to vote. Please try again.', color: Colors.red);
      }
    }
  }
}