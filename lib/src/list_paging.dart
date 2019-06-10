import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'definitions.dart';
import 'paging_controller.dart';

class RestListPaging<T> extends StatefulWidget {
	final ItemBuilder<T> itemBuilder;
	final PagingController<T> controller;
	final Widget skeleton;
	final Widget empty_widget;
	final double item_extend;
	final EdgeInsets padding;
	final ScrollController outer_scroll_controller;
	final Map<int, Widget> items_extension;
	final bool allow_refresh;
	final bool allow_load_more;
	final OnError onError;
	const RestListPaging({
		Key key,
		@required this.controller,
		@required this.itemBuilder,
		@required this.onError,
		this.skeleton,
		this.empty_widget,
		this.item_extend,
		this.padding,
		this.outer_scroll_controller,
		this.items_extension,
		this.allow_refresh = true,
		this.allow_load_more = true,
	}) : assert( controller != null ), assert( itemBuilder != null ), super(key: key);
	
	@override
	State<StatefulWidget> createState() => _RestListPagingState<T>();
}

class _RestListPagingState<T> extends State<RestListPaging<T>> {
	GlobalKey<EasyRefreshState> _refresh_state = GlobalKey<EasyRefreshState>();
	@override
	Widget build(BuildContext context) => new StreamBuilder<List<T>>(
		stream: widget.controller?.itemStream,
		builder: ( _, snapshot ) {
			int index_scynchronizer = 0;
			return new EasyRefresh(
				key: _refresh_state,
				outerController: widget.outer_scroll_controller,
				onRefresh: widget.allow_refresh ? _onRefresh : null,
				loadMore: widget.allow_load_more ? _onLoadMore : null,
				firstRefresh: true,
				emptyWidget: widget.empty_widget,
				firstRefreshWidget: widget.skeleton == null ? null : ListView.builder(
					itemCount: widget.controller.items_per_page,
					itemExtent: widget.item_extend,
					padding: widget.padding,
					itemBuilder: ( final BuildContext context, final int index ) {
						if ( widget.items_extension != null ) {
							if ( widget.items_extension.containsKey(index) ) return widget.items_extension[index];
							else return widget.skeleton;
						} else return widget.skeleton;
					},
				),
				child: ListView.builder(
					itemCount: snapshot.hasData ? ( snapshot.data.length + ( widget.items_extension  != null ? widget.items_extension.length : 0 ) ) : ( widget.items_extension  != null ? widget.items_extension.length : 0 ),
					padding: widget.padding,
					itemExtent: widget.item_extend,
					itemBuilder: ( final BuildContext context, final int index ) {
						if ( widget.items_extension != null ) {
							if ( widget.items_extension.containsKey(index) ) {
								index_scynchronizer++;
								return widget.items_extension[index];
							}
							else return widget.itemBuilder(context, snapshot.data[index - index_scynchronizer], index);
						} else return widget.itemBuilder(context, snapshot.data[index - index_scynchronizer], index);
					},
				),
			);
		},
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
	
	@override
	void didUpdateWidget(RestListPaging<T> oldWidget) {
		super.didUpdateWidget(oldWidget);
		if ( widget.controller != oldWidget.controller ) {
			new Future.delayed(Duration.zero, () {
				if ( _refresh_state.currentState != null )_refresh_state.currentState.callRefresh();
			});
		}
	}
}