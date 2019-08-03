import 'package:flutter/material.dart';

import 'paging_controller.dart';

mixin Paging<C extends StatefulWidget, T> on State<C> {
	PagingController<T> _paging_controller;
	
	Widget getChild( final BuildContext context, AsyncSnapshot<List<T>> snapshot );
	
	@mustCallSuper
	@override
	Widget build(BuildContext context) => new StreamBuilder<List<T>>(
		stream: _paging_controller?.itemStream,
		builder: getChild,
	);
	
	@protected
	Future<void> onRefresh() async {
		try {
			await _paging_controller.refresh();
		} catch ( error, st ) {
			onError(error, st);
		}
	}
	
	@protected
	Future<void> onLoad() async {
		try {
			await _paging_controller.load();
		} catch ( error, st ) {
			onError(error, st);
		}
	}
	
	@override
	void initState() {
		_paging_controller = getPagingController();
		super.initState();
	}
	
	@override
	void dispose() {
		_paging_controller.dispose();
		super.dispose();
	}
	
	@protected
	PagingController<T> getPagingController();
	
	@protected
	void onError( dynamic error, StackTrace stack_trace );
}