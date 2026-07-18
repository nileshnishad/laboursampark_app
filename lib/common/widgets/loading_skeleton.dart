import 'package:flutter/material.dart';

enum LoadingSkeletonType {
  card,
  myJobCard,
  availableJobCard,
  appliedJobCard,
  applicationPage,
  row,
  profile,
  contractorCard,
  narrowRow,
}

class LoadingSkeleton extends StatefulWidget {
  final LoadingSkeletonType type;
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const LoadingSkeleton({
    super.key,
    required this.type,
    this.itemCount = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      progress: _controller,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.hasBoundedHeight;

          if (hasBoundedHeight) {
            return ListView.separated(
              padding: widget.padding,
              itemCount: widget.itemCount,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildSkeletonItem(context),
            );
          }

          final items = List<Widget>.generate(widget.itemCount, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == widget.itemCount - 1 ? 0 : 12,
              ),
              child: _buildSkeletonItem(context),
            );
          });

          return Padding(
            padding: widget.padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    switch (widget.type) {
      case LoadingSkeletonType.card:
        return _buildCard(context);
      case LoadingSkeletonType.myJobCard:
        return _buildMyJobCardSkeleton(context);
      case LoadingSkeletonType.availableJobCard:
        return _buildAvailableJobCardSkeleton(context);
      case LoadingSkeletonType.appliedJobCard:
        return _buildAppliedJobCardSkeleton(context);
      case LoadingSkeletonType.applicationPage:
        return _buildApplicationPageSkeleton(context);
      case LoadingSkeletonType.contractorCard:
        return _buildContractorCard(context);
      case LoadingSkeletonType.profile:
        return _buildProfile(context);
      case LoadingSkeletonType.narrowRow:
        return _buildNarrowRow(context);
      case LoadingSkeletonType.row:
        return _buildRow(context);
    }
  }

  Color _surfaceColor(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      return const Color(0xFF111827);
    }
    return const Color(0xFFF3F4F6);
  }

  Color _skeletonColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? const Color(0xFF334155)
        : const Color(0xFFCBD5E1);
  }

  Widget _skeletonBox(
    BuildContext context, {
    double width = double.infinity,
    double height = 16,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _skeletonColor(context),
        borderRadius: borderRadius ?? BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _skeletonBox(
                context,
                width: 72,
                height: 72,
                borderRadius: BorderRadius.circular(18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(context, height: 16),
                    const SizedBox(height: 10),
                    _skeletonBox(context, width: 120, height: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _skeletonBox(context, height: 16),
          const SizedBox(height: 10),
          _skeletonBox(context, width: 140, height: 14),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _skeletonBox(context, height: 38)),
              const SizedBox(width: 10),
              Expanded(child: _skeletonBox(context, height: 38)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyJobCardSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _skeletonBox(
                context,
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(context, height: 18, width: 180),
                    const SizedBox(height: 8),
                    _skeletonBox(context, height: 14, width: 120),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _skeletonBox(
                context,
                width: 70,
                height: 24,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _skeletonBox(
                  context,
                  height: 32,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _skeletonBox(
                  context,
                  height: 32,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _skeletonBox(
                context,
                width: 80,
                height: 28,
                borderRadius: BorderRadius.circular(14),
              ),
              _skeletonBox(
                context,
                width: 90,
                height: 28,
                borderRadius: BorderRadius.circular(14),
              ),
              _skeletonBox(
                context,
                width: 70,
                height: 28,
                borderRadius: BorderRadius.circular(14),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _skeletonBox(context, height: 14, width: 160),
          const SizedBox(height: 8),
          _skeletonBox(context, height: 14, width: 120),
        ],
      ),
    );
  }

  Widget _buildAvailableJobCardSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _skeletonBox(
                context,
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(context, height: 18, width: 150),
                    const SizedBox(height: 8),
                    _skeletonBox(context, height: 14, width: 110),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _skeletonBox(
                context,
                width: 70,
                height: 24,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _skeletonColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _skeletonBox(
                  context,
                  width: 36,
                  height: 36,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(context, height: 14, width: 120),
                      const SizedBox(height: 8),
                      _skeletonBox(context, height: 12, width: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _skeletonBox(
                context,
                width: 90,
                height: 28,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 8),
              _skeletonBox(
                context,
                width: 100,
                height: 28,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 8),
              _skeletonBox(
                context,
                width: 80,
                height: 28,
                borderRadius: BorderRadius.circular(14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _skeletonBox(
                context,
                width: 70,
                height: 24,
                borderRadius: BorderRadius.circular(14),
              ),
              _skeletonBox(
                context,
                width: 90,
                height: 24,
                borderRadius: BorderRadius.circular(14),
              ),
              _skeletonBox(
                context,
                width: 80,
                height: 24,
                borderRadius: BorderRadius.circular(14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _skeletonBox(context, height: 14, width: 180),
          const SizedBox(height: 8),
          _skeletonBox(context, height: 14, width: 140),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _skeletonBox(
                  context,
                  height: 70,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _skeletonBox(
                  context,
                  height: 70,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedJobCardSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _skeletonBox(context, height: 18)),
              const SizedBox(width: 10),
              _skeletonBox(
                context,
                width: 80,
                height: 24,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _skeletonBox(context, height: 14, width: 140),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _skeletonBox(
                  context,
                  height: 32,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _skeletonBox(
                  context,
                  height: 32,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _skeletonBox(context, height: 32)),
              const SizedBox(width: 8),
              Expanded(child: _skeletonBox(context, height: 32)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationPageSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildJobInfoSkeleton(context),
        const SizedBox(height: 16),
        _buildSummaryRowSkeleton(context),
        const SizedBox(height: 16),
        _buildApplicationCardSkeleton(context),
        const SizedBox(height: 12),
        _buildApplicationCardSkeleton(context),
        const SizedBox(height: 12),
        _buildApplicationCardSkeleton(context),
      ],
    );
  }

  Widget _buildJobInfoSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _skeletonBox(context, height: 18, width: 180),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _skeletonBox(
                context,
                width: 120,
                height: 30,
                borderRadius: BorderRadius.circular(20),
              ),
              _skeletonBox(
                context,
                width: 100,
                height: 30,
                borderRadius: BorderRadius.circular(20),
              ),
              _skeletonBox(
                context,
                width: 80,
                height: 30,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _skeletonBox(context, height: 14),
          const SizedBox(height: 8),
          _skeletonBox(context, height: 14, width: 140),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _skeletonBox(
                context,
                width: 70,
                height: 24,
                borderRadius: BorderRadius.circular(14),
              ),
              _skeletonBox(
                context,
                width: 90,
                height: 24,
                borderRadius: BorderRadius.circular(14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRowSkeleton(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _skeletonBox(
                context,
                height: 80,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _skeletonBox(
                context,
                height: 80,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _skeletonBox(
                context,
                height: 80,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _skeletonBox(
                context,
                height: 80,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApplicationCardSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _skeletonBox(
                context,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 12),
              Expanded(child: _skeletonBox(context, height: 16)),
              const SizedBox(width: 10),
              _skeletonBox(
                context,
                width: 70,
                height: 24,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _skeletonBox(context, height: 14, width: 120),
          const SizedBox(height: 8),
          _skeletonBox(context, height: 14, width: 90),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _skeletonBox(
                  context,
                  height: 36,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _skeletonBox(
                  context,
                  height: 36,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContractorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _skeletonBox(context, height: 18),
          const SizedBox(height: 10),
          _skeletonBox(context, width: 180, height: 14),
          const SizedBox(height: 14),
          Row(
            children: [
              _skeletonBox(
                context,
                width: 52,
                height: 52,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(context, height: 14),
                    const SizedBox(height: 8),
                    _skeletonBox(context, width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _skeletonBox(context, height: 12),
          const SizedBox(height: 8),
          _skeletonBox(context, width: 140, height: 12),
        ],
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    return Row(
      children: [
        _skeletonBox(
          context,
          width: 72,
          height: 72,
          borderRadius: BorderRadius.circular(36),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _skeletonBox(context, height: 18),
              const SizedBox(height: 10),
              _skeletonBox(context, width: 120, height: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context) {
    return _skeletonBox(context, height: 18);
  }

  Widget _buildNarrowRow(BuildContext context) {
    return _skeletonBox(context, width: 140, height: 14);
  }
}

class Shimmer extends StatelessWidget {
  final Animation<double> progress;
  final Widget child;

  const Shimmer({super.key, required this.progress, required this.child});

  @override
  Widget build(BuildContext context) {
    final shimmerBase = _shimmerBaseColor(context);
    final shimmerHighlight = _shimmerHighlightColor(context);

    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final offset = (progress.value * 2) - 1;
            return LinearGradient(
              begin: Alignment(-1 - offset, -0.3),
              end: Alignment(1 - offset, 0.3),
              colors: [shimmerBase, shimmerHighlight, shimmerBase],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  Color _shimmerBaseColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? const Color(0xFF334155)
        : const Color(0xFFCBD5E1);
  }

  Color _shimmerHighlightColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? const Color(0xFF475569)
        : const Color(0xFFF1F5F9);
  }
}
