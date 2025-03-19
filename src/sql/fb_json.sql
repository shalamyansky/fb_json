set term ^;

create or alter package json
as begin

procedure parse(
    json        blob sub_type text character set UTF8
)returns(
    source_type smallint
  , number      integer
  , key         varchar(8191)      character set UTF8
  , value_      blob sub_type text character set UTF8
  , value_type  smallint
);

function json_type(
    json_type smallint
)returns      varchar(6)
;

function encode(
    str  varchar(8191) character set UTF8
)returns varchar(8191) character set UTF8
;

function decode(
    str  varchar(8191) character set UTF8
)returns varchar(8191) character set UTF8
;

function append(
    json   blob sub_type text character set UTF8
  , key    varchar(8191)      character set UTF8
  , value_ blob sub_type text character set UTF8
)returns   blob sub_type text character set UTF8
;

function put(
    json   blob sub_type text character set UTF8
  , key    varchar(8191)      character set UTF8
  , value_ blob sub_type text character set UTF8
)returns   blob sub_type text character set UTF8
;

end^

recreate package body json
as
begin

procedure parse(
    json        blob sub_type text character set UTF8
)returns(
    source_type smallint
  , number      integer
  , key         varchar(8191)      character set UTF8
  , value_      blob sub_type text character set UTF8
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
    str  varchar(8191) character set UTF8
)returns varchar(8191) character set UTF8
external name
    'fb_json!encode'
engine
    udr
;

function decode(
    str  varchar(8191) character set UTF8
)returns varchar(8191) character set UTF8
external name
    'fb_json!decode'
engine
    udr
;

function append(
    json   blob sub_type text character set UTF8
  , key    varchar(8191)      character set UTF8
  , value_ blob sub_type text character set UTF8
)returns   blob sub_type text character set UTF8
external name
    'fb_json!append'
engine
    udr
;

function put(
    json   blob sub_type text character set UTF8
  , key    varchar(8191)      character set UTF8
  , value_ blob sub_type text character set UTF8
)returns   blob sub_type text character set UTF8
external name
    'fb_json!put'
engine
    udr
;

end^

set term ;^
