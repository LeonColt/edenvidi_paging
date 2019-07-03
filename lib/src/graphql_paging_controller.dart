import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'definitions.dart';
import 'page_info.dart';
import 'paging_controller.dart';

class GraphQLPagingController<T> extends PagingController<T> {
	final QueryOptions query_options;
	final Transformer<T>transformer;
	final BehaviorSubject<Map<int, List<T>>> _paging_subject = new BehaviorSubject.seeded(const {});
	GraphQLClient _client;
	
	GraphQLPagingController( {
		@required final BuildContext context,
		@required this.transformer,
		@required this.query_options,
		@required final int items_per_page,
	}): assert( context != null ), assert( transformer != null ), super( items_per_page: items_per_page ) {
		_paging_subject.listen( ( final Map<int, List<T>> data )  {
			final List<T> list = new List();
			for ( int i = 1; i <= page; ++i ) {
				if ( data.containsKey(i) ) list.addAll(data[i]);
			}
			item_subject.add(list);
		});
		new Future.delayed(Duration.zero, () => _client = GraphQLProvider.of(context).value );
	}
	
	@override
	Future<void> load() async {
		if ( query_options == null ) return;
		final completer = await lock();
		try {
			final QueryResult result = await _client.query(_getNextOptions());
			
			if ( result.hasErrors ) {
				throw new Exception( result.errors.map( ( final error ) => error.toString() ).join("\r\n"), );
			}
			else {
				final ListWithPageInfo<T> data = transformer( result.data as Map<String, dynamic> );
				if ( data.list.isNotEmpty ) {
					page = data.meta.page + ( data.list.length >= items_per_page ? 1 : 0 );
					max_page = data.meta.total_pages;
					final new_data = _paging_subject.value;
					new_data[page] = data.list;
					_paging_subject.add(new_data);
				}
				else {
					page = data.meta.page;
					max_page = data.meta.total_pages;
				}
			}
		} catch (error) {
			rethrow;
		} finally {
			unlock(completer);
		}
	}
	
	@override
	Future<void> refresh() async {
		if ( query_options == null ) return;
		final completer = await lock();
		try {
			page = 1;
			
			final QueryResult result = await _client.query(_getNextOptions());
			
			if ( result.hasErrors ) {
				throw new Exception( result.errors.map( ( final error ) => error.toString() ).join("\r\n"), );
			}
			else {
				page = 1;
				final ListWithPageInfo<T> data = transformer( result.data as Map<String, dynamic> );
				page = data.meta.page + ( data.list.length >= items_per_page ? 1 : 0 );
				max_page = data.meta.total_pages;
				_paging_subject.add({
					page: data.list,
				});
			}
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
	
	QueryOptions _getNextOptions() {
		final Map<String, dynamic> variables = query_options.variables ?? new Map();
		variables.addAll(new ArgPageInfo(page: page, per_page: items_per_page).toJson());
		return new QueryOptions(
			document: query_options.document,
			context: query_options.context,
			pollInterval: query_options.pollInterval,
			errorPolicy: query_options.errorPolicy,
			fetchPolicy: query_options.fetchPolicy,
			optimisticResult: query_options.optimisticResult,
			variables: variables,
		);
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