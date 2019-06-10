// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArgPageInfo _$ArgPageInfoFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['page', 'per_page']);
  return ArgPageInfo(
      page: json['page'] as int, per_page: json['per_page'] as int);
}

Map<String, dynamic> _$ArgPageInfoToJson(ArgPageInfo instance) =>
    <String, dynamic>{'page': instance.page, 'per_page': instance.per_page};

PageInfo _$PageInfoFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['page', 'per_page', 'total_pages', 'total_result'],
      disallowNullValues: const ['total_result']);
  return PageInfo(
      page: json['page'] as int,
      per_page: json['per_page'] as int,
      total_pages: json['total_pages'] as int,
      total_result: json['total_result'] as int);
}

Map<String, dynamic> _$PageInfoToJson(PageInfo instance) => <String, dynamic>{
      'page': instance.page,
      'per_page': instance.per_page,
      'total_pages': instance.total_pages,
      'total_result': instance.total_result
    };
