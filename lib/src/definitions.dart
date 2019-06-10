import 'package:flutter/widgets.dart';

import 'page_info.dart';

typedef ListWithPageInfo<T> Transformer<T>( Map<String, dynamic> json );
typedef Widget ItemBuilder<T>( final BuildContext context, final T item, final int index );
typedef void OnError( dynamic error, StackTrace stack_trace );

typedef Future<ListWithPageInfo<T>> OnRequestPage<T>( final ArgPageInfo meta_page );