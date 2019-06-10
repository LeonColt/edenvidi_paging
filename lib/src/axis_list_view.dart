import 'package:flutter/material.dart';

import 'definitions.dart';
import 'paging_controller.dart';

class AxisListView<T> extends StatefulWidget {
	final ItemBuilder<T> itemBuilder;
	final PagingController<T> controller;
	final Widget skeleton;
	final Widget empty_widget;
	final double item_extend;
	final EdgeInsets padding;
	final ScrollController outer_scroll_controller;
	final Map<int, Widget> items_extension;
	final bool allow_refresh;
	final OnError onError;
	final Axis scroll_direction;
	const AxisListView({
		Key key,
		@required this.controller,
		@required this.itemBuilder,
		this.skeleton,
		this.empty_widget,
		this.item_extend,
		this.padding,
		this.outer_scroll_controller,
		this.items_extension,
		this.allow_refresh = true,
		this.onError,
		this.scroll_direction,
	}) : assert( controller != null ), assert( itemBuilder != null ), super(key: key);
	
	@override
	State<StatefulWidget> createState() => _AxisListViewState<T>();
}

class _AxisListViewState<T> extends State<AxisListView<T>> {
	@override
	Widget build(BuildContext context) => new StreamBuilder<List<T>>(
		stream: widget.controller?.itemStream,
		builder: ( _, snapshot ) {
			int index_scynchronizer = 0;
			if ( snapshot.connectionState == ConnectionState.waiting ) return _getFirstRefreshWidget();
			else {
				if ( snapshot.hasData && snapshot.data.isNotEmpty ) {
					return ListView.builder(
						itemCount: snapshot.hasData ? ( snapshot.data.length + ( widget.items_extension  != null ? widget.items_extension.length : 0 ) ) : ( widget.items_extension  != null ? widget.items_extension.length : 0 ),
						padding: widget.padding,
						itemExtent: widget.item_extend,
						scrollDirection: widget.scroll_direction,
						itemBuilder: ( final BuildContext context, final int index ) {
							if ( widget.items_extension != null ) {
								if ( widget.items_extension.containsKey(index) ) {
									index_scynchronizer++;
									return widget.items_extension[index];
								}
								else return widget.itemBuilder(context, snapshot.data[index - index_scynchronizer], index);
							} else return widget.itemBuilder(context, snapshot.data[index - index_scynchronizer], index);
						},
					);
				}
				else {
					if ( widget.empty_widget != null ) {
						return widget.empty_widget;
					}
					else {
						return ListView.builder(
							itemCount: snapshot.hasData ? ( snapshot.data.length + ( widget.items_extension  != null ? widget.items_extension.length : 0 ) ) : ( widget.items_extension  != null ? widget.items_extension.length : 0 ),
							padding: widget.padding,
							itemExtent: widget.item_extend,
							scrollDirection: widget.scroll_direction,
							itemBuilder: ( final BuildContext context, final int index ) {
								if ( widget.items_extension != null ) {
									if ( widget.items_extension.containsKey(index) ) {
										index_scynchronizer++;
										return widget.items_extension[index];
									}
									else return widget.itemBuilder(context, snapshot.data[index - index_scynchronizer], index);
								} else return widget.itemBuilder(context, snapshot.data[index - index_scynchronizer], index);
							},
						);
					}
				}
			}
		},
	);
	
	Widget _getFirstRefreshWidget() {
		if ( widget.skeleton != null ) {
			return new ListView.builder(
				itemCount: widget.controller.items_per_page,
				scrollDirection: widget.scroll_direction,
				itemBuilder: ( final BuildContext context, final int index ) {
					if ( widget.items_extension != null ) {
						if ( widget.items_extension.containsKey(index) ) return widget.items_extension[index];
						else return widget.skeleton;
					} else return widget.skeleton;
				},
			);
		}
		else {
			if ( widget.empty_widget != null ) return widget.empty_widget; else return new CircularProgressIndicator();
		}
	}
	
	Future<void> _onRefresh() async {
		try {
			await widget.controller.refresh();
		} catch ( error, st ) {
			print(st);
			if ( widget.onError != null ) widget.onError(error, st);
		}
	}
	
	@override
	void initState() {
		new Future.delayed(Duration.zero, _onRefresh);
		super.initState();
	}
	
	@override
	void didUpdateWidget(AxisListView<T> oldWidget) {
		super.didUpdateWidget(oldWidget);
		if ( widget.controller != oldWidget.controller ) {
			new Future.delayed(Duration.zero, _onRefresh);
		}
	}
}