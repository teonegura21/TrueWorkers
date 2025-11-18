import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Base skeleton widget for loading states
class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for job cards
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title placeholder
            const Skeleton(height: 20, width: double.infinity),
            const SizedBox(height: AppSpacing.md),

            // Description placeholders
            const Skeleton(height: 14, width: double.infinity),
            const SizedBox(height: AppSpacing.sm),
            const Skeleton(height: 14, width: 200),
            const SizedBox(height: AppSpacing.lg),

            // Footer with budget and location
            Row(
              children: [
                const Skeleton(height: 16, width: 80),
                const Spacer(),
                const Skeleton(height: 16, width: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for craftsman cards
class CraftsmanCardSkeleton extends StatelessWidget {
  const CraftsmanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: ListTile(
        leading: const Skeleton(
          width: 60,
          height: 60,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        title: const Skeleton(height: 16, width: 150),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Skeleton(height: 12, width: 100),
            const SizedBox(height: 4),
            const Skeleton(height: 12, width: 80),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for project cards
class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Skeleton(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(height: 16, width: 120),
                      SizedBox(height: 4),
                      Skeleton(height: 12, width: 80),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title and description
            const Skeleton(height: 18, width: double.infinity),
            const SizedBox(height: AppSpacing.sm),
            const Skeleton(height: 14, width: double.infinity),
            const SizedBox(height: AppSpacing.sm),
            const Skeleton(height: 14, width: 150),
            const SizedBox(height: AppSpacing.lg),

            // Progress bar
            const Skeleton(height: 8, width: double.infinity),
            const SizedBox(height: AppSpacing.sm),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Skeleton(height: 12, width: 100),
                const Skeleton(height: 12, width: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for message list
class MessageListSkeleton extends StatelessWidget {
  const MessageListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: Skeleton(
                    width: 32,
                    height: 32,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              Skeleton(
                width: 200,
                height: 50,
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Skeleton for payment history
class PaymentCardSkeleton extends StatelessWidget {
  const PaymentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: ListTile(
        leading: const Skeleton(
          width: 48,
          height: 48,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        title: const Skeleton(height: 16, width: 150),
        subtitle: const Skeleton(height: 12, width: 100),
        trailing: const Skeleton(height: 18, width: 60),
      ),
    );
  }
}

/// Generic list skeleton
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
