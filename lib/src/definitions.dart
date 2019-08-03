import 'page_info.dart';

typedef ListWithPageInfo<T> Transformer<T>( Map<String, dynamic> json );
typedef Future<ListWithPageInfo<T>> OnRequestPage<T>( final ArgPageInfo meta_page );