import 'package:flutter/material.dart';

import 'definitions.dart';
import 'paging_controller.dart';

class AxisGridView<T> extends StatefulWidget {
	final ItemBuilder<T> itemBuilder;
	final PagingController<T> controller;
	final SliverGridDelegate grid_delegate;
	final Widget skeleton;
	final Widget empty_widget;
	final ScrollController outer_scroll_controller;
	final OnError onError;
	final Axis scroll_direction;
	const AxisGridView({
		Key key,
		@required this.controller,
		@required this.itemBuilder,
		this.skeleton,
		this.empty_widget,
		this.outer_scroll_controller,
		this.onError,
		this.grid_delegate,
		this.scroll_direction = Axis.vertical,
	}) : assert( controller != null ),
				assert( itemBuilder != null ),
				super(key: key);
	@override State<StatefulWidget> createState() => _AxisGridViewState<T>();
}

class _AxisGridViewState<T> extends State<AxisGridView<T>> {
	@override
	Widget build(BuildContext context) => new StreamBuilder<List<T>>(
		stream: widget.controller?.itemStream,
		builder: ( _, snapshot ) {
			if ( snapshot.connectionState == ConnectionState.waiting ) {
				if ( widget.skeleton != null ) {
					return new GridView.builder(
						itemCount: widget.controller.items_per_page,
						gridDelegate: widget.grid_delegate,
						scrollDirection: widget.scroll_direction,
						itemBuilder: ( _, __ ) => widget.skeleton,
					);
				}
				else {
					if ( widget.empty_widget != null ) return widget.empty_widget; else return new CircularProgressIndicator();
				}
			}
			else {
				if ( widget.empty_widget != null ) {
					if ( snapshot.hasData && snapshot.data.isNotEmpty ) {
						return new GridView.builder(
							itemCount: snapshot.data.length,
							gridDelegate: widget.grid_delegate,
							scrollDirection: widget.scroll_direction,
							itemBuilder: ( final BuildContext context, final int index ) => widget.itemBuilder(context, snapshot.data[index], index),
						);
					}
					else {
						return widget.empty_widget;
					}
				}
				else {
					return new GridView.builder(
						itemCount: snapshot.hasData ? snapshot.data.length : 0,
						gridDelegate: widget.grid_delegate,
						scrollDirection: widget.scroll_direction,
						itemBuilder: ( final BuildContext context, final int index ) => widget.itemBuilder(context, snapshot.data[index], index),
					);
				}
			}
		},
	);
	
	@override
	void initState() {
		super.initState();
		new Future.delayed(Duration.zero, _onRefresh);
	}
	
	@override
	void didUpdateWidget( AxisGridView<T> oldWidget ) {
		super.didUpdateWidget(oldWidget);
		if ( widget.controller != oldWidget.controller ) new Future.delayed(Duration.zero, _onRefresh);
	}
	
	Future<void> _onRefresh() async {
		try {
			await widget.controller.refresh();
		} catch ( error, st ) {
			print(st);
			widget.onError(error, st);
		}
	}
}