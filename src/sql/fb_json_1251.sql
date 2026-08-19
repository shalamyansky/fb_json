set term ^ ;

create or alter package json
as
begin

procedure parse(
    json        varchar(32765)      character set WIN1251
)returns(
    source_type smallint
  , number      integer
  , key         varchar(32765)      character set WIN1251
  , value_      varchar(32765)      character set WIN1251
  , value_type  smallint
)
;

procedure parse_blob(
    json        blob sub_type text character set WIN1251
)returns(
    source_type smallint
  , number      integer
  , key         varchar(32765)     character set WIN1251
  , value_      blob sub_type text character set WIN1251
  , value_type  smallint
)
;

function json_type(
    json_type smallint
)returns      varchar(6)
;

function encode(
    str  varchar(32765) character set WIN1251
)returns varchar(32765) character set WIN1251
;

function decode(
    str  varchar(32765) character set WIN1251
)returns varchar(32765) character set WIN1251
;

procedure h_create(
    json   varchar(32765) character set WIN1251
)returns(
    handle bigint
)
;

function append(
    json   varchar(32765) character set WIN1251
  , key    varchar(32765) character set WIN1251
  , value_ varchar(32765) character set WIN1251
  , type_  smallint
)returns   varchar(32765) character set WIN1251
;

function h_append(
    handle bigint
  , key    varchar(32765) character set WIN1251
  , value_ varchar(32765) character set WIN1251
  , type_  smallint
)returns   bigint
;

function append_blob(
    json   blob sub_type text character set WIN1251
  , key    varchar(32765)     character set WIN1251
  , value_ blob sub_type text character set WIN1251
  , type_  smallint
)returns   blob sub_type text character set WIN1251
;

function put(
    json   varchar(32765) character set WIN1251
  , key    varchar(32765) character set WIN1251
  , value_ varchar(32765) character set WIN1251
  , type_  smallint
)returns   varchar(32765) character set WIN1251
;

function h_put(
    handle bigint
  , key    varchar(32765) character set WIN1251
  , value_ varchar(32765) character set WIN1251
  , type_  smallint
)returns   bigint
;

function put_blob(
    json   blob sub_type text character set WIN1251
  , key    varchar(32765)     character set WIN1251
  , value_ blob sub_type text character set WIN1251
  , type_  smallint
)returns   blob sub_type text character set WIN1251
;

function remove(
    json   varchar(32765) character set WIN1251
  , key    varchar(32765) character set WIN1251
)returns   varchar(32765) character set WIN1251
;

function remove_blob(
    json   blob sub_type text character set WIN1251
  , key    varchar(32765)     character set WIN1251
)returns   blob sub_type text character set WIN1251
;

function array_to_object(
    json       varchar(32765) character set WIN1251
  , key_name   varchar(32765) character set WIN1251
  , value_name varchar(32765) character set WIN1251
)returns       varchar(32765) character set WIN1251
;

function array_to_object_blob(
    json       blob sub_type text character set WIN1251
  , key_name   varchar(32765)     character set WIN1251
  , value_name varchar(32765)     character set WIN1251
)returns       blob sub_type text character set WIN1251
;

function object_to_array(
    json       varchar(32765) character set WIN1251
  , key_name   varchar(32765) character set WIN1251
  , value_name varchar(32765) character set WIN1251
)returns       varchar(32765) character set WIN1251
;

function object_to_array_blob(
    json       blob sub_type text character set WIN1251
  , key_name   varchar(32765)     character set WIN1251
  , value_name varchar(32765)     character set WIN1251
)returns       blob sub_type text character set WIN1251
;

function h_serialize(
    handle bigint
)returns   varchar(32765) character set WIN1251
;

end^

recreate package body json
as
begin

procedure parse(
    json        varchar(32765)      character set WIN1251
)returns(
    source_type smallint
  , number      integer
  , key         varchar(32765)      character set WIN1251
  , value_      varchar(32765)      character set WIN1251
  , value_type  smallint
)
external name
    'fb_json!parse'
engine
    udr
;

procedure parse_blob(
    json        blob sub_type text character set WIN1251
)returns(
    source_type smallint
  , number      integer
  , key         varchar(32765)     character set WIN1251
  , value_      blob sub_type text character set WIN1251
  , value_type  smallint
)
external name
    'fb_json!parse'
engine
    udr
;

function json_type(
    json_type smallint
)returns      varchar(6)
as
begin
    return
        case json_type
            when 1 then 'null'
            when 2 then 'bool'
            when 3 then 'number'
            when 4 then 'string'
            when 5 then 'pair'
            when 6 then 'object'
            when 7 then 'array'
            else        null
        end
    ;
end

function encode(
    str  varchar(32765) character set WIN1251
)returns varchar(32765) character set WIN1251
external name
    'fb_json!encode'
engine
    udr
;

function decode(
    str  varchar(32765) character set WIN1251
)returns varchar(32765) character set WIN1251
external name
    'fb_json!decode'
engine
    udr
;

procedure h_create(
    json   varchar(32765) character set WIN1251
)returns(
    handle bigint
)
external name
    'fb_json!create'
engine
    udr
;

function append(
    json   varchar(32765) character set WIN1251
  , key    varchar(32765) character set WIN1251
  , value_ varchar(32765) character set WIN1251
  , type_  smallint
)returns   varchar(32765) character set WIN1251
external name
    'fb_json!append'
engine
    udr
;

function h_append(
    handle bigint
  , key    varchar(32765) character set WIN1251
  , value_ varchar(32765) character set WIN1251
  , type_  smallint
)returns   bigint
external name
    'fb_json!append'
engine
    udr
;

function append_blob(
    json   blob sub_type text character set WIN1251
  , key    varchar(32765)     character set WIN1251
  , value_ blob sub_type text character set WIN1251
  , type_  smallint
)returns   blob sub_type text character set WIN1251
external name
    'fb_json!append'
engine
    udr
;

function put(
    json   varchar(32765) character set WIN1251
  , key    varchar(32765) character set WIN1251
  , value_ varchar(32765) character set WIN1251
  , type_  smallint
)returns   varchar(32765) character set WIN1251
external name
    'fb_json!put'
engine
    udr
;

function h_put(
    handle bigint
  , key    varchar(32765) character set WIN1251
  , value_ varchar(32765) character set WIN1251
  , type_  smallint
)returns   bigint
external name
    'fb_json!put'
engine
    udr
;

function put_blob(
    json   blob sub_type text character set WIN1251
  , key    varchar(32765)     character set WIN1251
  , value_ blob sub_type text character set WIN1251
  , type_  smallint
)returns   blob sub_type text character set WIN1251
external name
    'fb_json!put'
engine
    udr
;

function remove(
    json   varchar(32765) character set WIN1251
  , key    varchar(32765) character set WIN1251
)returns   varchar(32765) character set WIN1251
external name
    'fb_json!remove'
engine
    udr
;

function remove_blob(
    json   blob sub_type text character set WIN1251
  , key    varchar(32765)     character set WIN1251
)returns   blob sub_type text character set WIN1251
external name
    'fb_json!remove'
engine
    udr
;

function array_to_object(
    json       varchar(32765) character set WIN1251
  , key_name   varchar(32765) character set WIN1251
  , value_name varchar(32765) character set WIN1251
)returns       varchar(32765) character set WIN1251
external name
    'fb_json!array_to_object'
engine
    udr
;

function array_to_object_blob(
    json       blob sub_type text character set WIN1251
  , key_name   varchar(32765)     character set WIN1251
  , value_name varchar(32765)     character set WIN1251
)returns       blob sub_type text character set WIN1251
external name
    'fb_json!array_to_object'
engine
    udr
;

function object_to_array(
    json       varchar(32765) character set WIN1251
  , key_name   varchar(32765) character set WIN1251
  , value_name varchar(32765) character set WIN1251
)returns       varchar(32765) character set WIN1251
external name
    'fb_json!object_to_array'
engine
    udr
;

function object_to_array_blob(
    json       blob sub_type text character set WIN1251
  , key_name   varchar(32765)     character set WIN1251
  , value_name varchar(32765)     character set WIN1251
)returns       blob sub_type text character set WIN1251
external name
    'fb_json!object_to_array'
engine
    udr
;

function h_serialize(
    handle bigint
)returns   varchar(32765) character set WIN1251
external name
    'fb_json!serialize'
engine
    udr
;

end^

set term ; ^
