import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

abstract class PagingController<T> {
	@protected
	final BehaviorSubject<List<T>> item_subject = new BehaviorSubject.seeded(const []);
	
	final int items_per_page;
	
	@protected int page = 0;
	
	@protected int max_page = 1;
	
	@protected Future<Null> _lock_items = null;
	
	PagingController({ @required this.items_per_page }) : assert( items_per_page != null ), assert( items_per_page > 0 );
	
	Stream<List<T>> get itemStream => item_subject.stream;
	
	Future<void> load();
	Future<void> refresh();
	
	@protected
	void unlock(Completer<Null> completer) async {
		completer.complete();
		_lock_items = null;
		completer = null;
	}
	
	@protected
	Future<Completer<Null>> lock() async {
		if( _lock_items != null ) await _lock_items;
		final Completer<Null> completer = new Completer<Null>();
		_lock_items = completer.future;
		return completer;
	}
	
	void removeWhere( bool test( T element ) );
	
	@protected
	@mustCallSuper
	void dispose() {
		item_subject.close();
	}
}