import 'package:flutter/material.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../styles/colors.dart';

class InfiniteScrollListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final Function() onLoadMore;
  final bool isLoading;
  final bool hasReachedMax;
  final Widget Function(bool isCollapsed) headerBuilder;
  final double expandedHeaderHeight;
  final double collapsedHeaderHeight;
  final InfiniteScrollController? controller;
  final VoidCallback? onRefresh; // Add this line

  const InfiniteScrollListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.isLoading,
    required this.headerBuilder,
    this.hasReachedMax = false,
    this.expandedHeaderHeight = 350,
    this.collapsedHeaderHeight = 75,
    this.controller,
    this.onRefresh, // Add this line
  });

  @override
  State<InfiniteScrollListView<T>> createState() =>
      _InfiniteScrollListViewState<T>();
}

class _InfiniteScrollListViewState<T> extends State<InfiniteScrollListView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.controller?._addState(this); // Add this line
  }

  @override
  void dispose() {
    widget.controller?._removeState(this); // Add this line
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Add this method
  void _handleRefresh() {
    if (widget.onRefresh != null) {
      widget.onRefresh!();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const delta = 50.0;

    // Handle infinite scroll
    if ((maxScroll - currentScroll) <= delta &&
        !widget.isLoading &&
        !widget.hasReachedMax) {
      widget.onLoadMore();
    }

    // Handle header collapse with proper state update
    final shouldBeCollapsed = currentScroll >
        widget.expandedHeaderHeight - widget.collapsedHeaderHeight;
    if (shouldBeCollapsed != _isCollapsed) {
      setState(() => _isCollapsed = shouldBeCollapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        // Wrap with RefreshIndicator
        onRefresh: () async {
          _handleRefresh();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: widget.expandedHeaderHeight,
              collapsedHeight: widget.collapsedHeaderHeight,
              flexibleSpace: FlexibleSpaceBar(
                background: widget.headerBuilder(false),
                // Expanded state
                titlePadding: EdgeInsets.zero,
                centerTitle: false,
                title: AnimatedOpacity(
                  opacity: _isCollapsed ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: widget.headerBuilder(true), // Collapsed state
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= widget.items.length) {
                    return Center(
                      child: Padding(
                        padding: kPaddV14,
                        child: widget.isLoading
                            ? LinearProgressIndicator(
                                color: MyColors.primary,
                                backgroundColor:
                                    MyColors.primary.withValues(alpha: 0.1),
                              )
                            : const SizedBox(),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      widget.itemBuilder(context, widget.items[index]),
                      kGap14,
                    ],
                  );
                },
                childCount:
                    widget.items.length + (widget.hasReachedMax ? 0 : 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfiniteScrollController {
  _InfiniteScrollListViewState? _state;

  void _addState(_InfiniteScrollListViewState state) {
    _state = state;
  }

  void _removeState(_InfiniteScrollListViewState state) {
    if (_state == state) {
      _state = null;
    }
  }

  void refresh() {
    _state?._handleRefresh();
  }
}
