import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'definitions.dart';
import 'paging_controller.dart';

class StaggeredGridPaging<T> extends StatefulWidget {
	final int cross_axis_count;
	final ItemBuilder<T> itemBuilder;
	final PagingController<T> controller;
	final IndexedStaggeredTileBuilder tileBuilder;
	final Widget skeleton;
	final Widget empty_widget;
	final ScrollController outer_scroll_controller;
	final OnError onError;
	const StaggeredGridPaging({
		Key key,
		@required this.controller,
		@required this.itemBuilder,
		@required this.tileBuilder,
		@required this.onError,
		this.skeleton,
		this.empty_widget,
		this.cross_axis_count = 2,
		this.outer_scroll_controller,
	}) : assert( controller != null ),
				assert( itemBuilder != null ),
				assert( tileBuilder != null ),
				assert( onError != null ),
				super(key: key);
	
	@override
	State<StatefulWidget> createState() => _StaggeredGridPagingState<T>();
}

class _StaggeredGridPagingState<T> extends State<StaggeredGridPaging<T>> {
	final GlobalKey<EasyRefreshState> _refresh_state = GlobalKey<EasyRefreshState>();
	@override
	Widget build(BuildContext context) => new StreamBuilder<List<T>>(
		stream: widget.controller?.itemStream,
		builder: ( _, snapshot ) => new EasyRefresh(
			key: _refresh_state,
			outerController: widget.outer_scroll_controller,
			onRefresh: _onRefresh,
			loadMore: _onLoadMore,
			firstRefresh: true,
			emptyWidget: widget.empty_widget,
			firstRefreshWidget: widget.skeleton == null ? null : StaggeredGridView.countBuilder(
				crossAxisCount: widget.cross_axis_count,
				staggeredTileBuilder: widget.tileBuilder,
				itemCount: widget.controller.items_per_page,
				itemBuilder: ( final BuildContext context, final int index ) => widget.skeleton,
			),
			child: StaggeredGridView.countBuilder(
				crossAxisCount: widget.cross_axis_count,
				staggeredTileBuilder: widget.tileBuilder,
				itemCount: snapshot.hasData ? snapshot.data.length : 0,
				itemBuilder: ( final BuildContext context, final int index ) => widget.itemBuilder(context, snapshot.data[index], index),
			),
		),
	);
	
	Future<void> _onRefresh() async {
		try {
			await widget.controller.refresh();
		} catch ( error, st ) {
			widget.onError(error, st);
		}
	}
	
	Future<void> _onLoadMore() async {
		try {
			await widget.controller.load();
		} catch ( error, st ) {
			widget.onError(error, st);
		}
	}
}