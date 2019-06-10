import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'page_info.dart';
import 'paging_controller.dart';
import 'definitions.dart';

class RestPagingController<T> extends PagingController<T> {
	final BehaviorSubject<Map<int, List<T>>> _paging_subject = new BehaviorSubject.seeded(const {});
	final OnRequestPage<T> onRequestPage;
	RestPagingController({
		@required final int items_per_page,
		@required this.onRequestPage,
	}) : super( items_per_page: items_per_page ) {
		_paging_subject.listen( ( final Map<int, List<T>> data )  {
			final List<T> list = new List();
			for ( int i = 1; i <= page; ++i ) {
				if ( data.containsKey(i) ) list.addAll(data[i]);
			}
			item_subject.add(list);
		});
	}
	@override
	Future<void> load() async {
		if( onRequestPage == null ) return;
		final completer = await lock();
		try {
			final ListWithPageInfo<T> data = await onRequestPage( new ArgPageInfo(page: page, per_page: items_per_page) );
			if( data.list.isNotEmpty ) {
				page = data.page_info.page + ( data.list.length >= items_per_page ? 1 : 0 );
				max_page = data.page_info.total_pages;
				final new_data = _paging_subject.value;
				new_data[page] = data.list;
				_paging_subject.add(new_data);
			} else if( page == 0 && max_page == 1 ) {
				page = data.page_info.page;
				max_page = data.page_info.total_pages;
			}
			if ( page < max_page ) page++;
		} catch (error) {
			rethrow;
		} finally {
			unlock(completer);
		}
	}
	@override
	Future<void> refresh() async {
		if( onRequestPage == null ) return;
		final completer = await lock();
		try {
			page = 1;
			final ListWithPageInfo<T> data = await onRequestPage( new ArgPageInfo(page: page, per_page: items_per_page) );
			page = data.page_info.page + ( data.list.length >= items_per_page ? 1 : 0 );
			max_page = data.page_info.total_pages;
			_paging_subject.add({
				page: data.list,
			});
		} catch (error) {
			rethrow;
		} finally {
			unlock(completer);
		}
	}
	
	@override
	void dispose() {
		_paging_subject.close();
		super.dispose();
	}
	
	@override
	void removeWhere(bool Function(T element) test) async {
		final completer = await lock();
		_paging_subject.add( _paging_subject.value.map( ( final int index, final List<T> items ) {
			return new MapEntry(
				index,
				items..removeWhere(test),
			);
		}) );
		unlock(completer);
	}
}