import 'package:json_annotation/json_annotation.dart';
part 'page_info.g.dart';

@JsonSerializable()
class ArgPageInfo {
	@JsonKey(required: true, nullable: true, disallowNullValue: false)
	final int page;
	@JsonKey(required: true, nullable: true, disallowNullValue: false)
	final int per_page;
	const ArgPageInfo({ this.page, this.per_page }) : assert( page != null ), assert( per_page != null ), assert( page > 0 ), assert( per_page > 0 );
	
	factory ArgPageInfo.fromJson( Map<String, dynamic> json ) => _$ArgPageInfoFromJson(json);
	Map<String, dynamic> toJson() => _$ArgPageInfoToJson(this);
}

@JsonSerializable()
class PageInfo {
	@JsonKey(required: true, nullable: true, disallowNullValue: false)
	final int page;
	
	@JsonKey(required: true, nullable: true, disallowNullValue: false)
	final int per_page;
	
	@JsonKey(required: true, nullable: true, disallowNullValue: false)
	final int total_pages;
	
	@JsonKey(required: true, nullable: false, disallowNullValue: true)
	final int total_result;
	PageInfo({this.page, this.per_page, this.total_pages, this.total_result});
	
	factory PageInfo.fromJson( Map<String, dynamic> json ) => _$PageInfoFromJson(json);
	Map<String, dynamic> toJson() => _$PageInfoToJson(this);
}

class ListWithPageInfo<T> {
	@JsonKey(required: true, nullable: false, disallowNullValue: true)
	PageInfo page_info;
	
	@JsonKey(required: true, nullable: false, disallowNullValue: true)
	List<T> list;
	
	ListWithPageInfo(this.page_info, this.list);
}