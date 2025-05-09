SET TERM ^ ;

CREATE OR ALTER package JSON
AS
begin

procedure parse(
    json        varchar(8191)                         character set UTF8
)returns(
    source_type smallint
  , number      integer
  , key         varchar(8191)                         character set UTF8
  , value_      varchar(8191)                         character set UTF8
  , value_type  smallint
);

procedure parse_blob(
    json        blob sub_type text segment size 16384 character set UTF8
)returns(
    source_type smallint
  , number      integer
  , key         varchar(8191)                         character set UTF8
  , value_      blob sub_type text segment size 16384 character set UTF8
  , value_type  smallint
);

function json_type(
    json_type smallint
)returns
    varchar(6)
;

function encode(
    str blob sub_type text segment size 16384 character set UTF8
)returns
        blob sub_type text segment size 16384 character set UTF8
;

function decode(
    str blob sub_type text segment size 16384 character set UTF8
)returns
        blob sub_type text segment size 16384 character set UTF8
;

function append(
    json   blob sub_type text segment size 16384 character set UTF8
  , key    varchar(8191)                         character set UTF8
  , value_ blob sub_type text segment size 16384 character set UTF8
  , type_  smallint
)returns   blob sub_type text segment size 16384 character set UTF8
;

function put(
    json   blob sub_type text segment size 16384 character set UTF8
  , key    varchar(8191)                         character set UTF8
  , value_ blob sub_type text segment size 16384 character set UTF8
  , type_  smallint
)returns   blob sub_type text segment size 16384 character set UTF8
;

function remove(
    json   blob sub_type text character set UTF8
  , key    varchar(8191)      character set UTF8
)returns   blob sub_type text character set UTF8
;

end^

RECREATE package body JSON
as
begin

procedure parse(
    json        varchar(8191)                         character set UTF8
)returns(
    source_type smallint
  , number      integer
  , key         varchar(8191)                         character set UTF8
  , value_      varchar(8191)                         character set UTF8
  , value_type  smallint
)
external name
    'fb_json!parse'
engine
    udr
;

procedure parse_blob(
    json        blob sub_type text segment size 16384 character set UTF8
)returns(
    source_type smallint
  , number      integer
  , key         varchar(8191)                         character set UTF8
  , value_      blob sub_type text segment size 16384 character set UTF8
  , value_type  smallint
)
external name
    'fb_json!parse'
engine
    udr
;

function json_type(
    json_type smallint
)returns
    varchar(6)
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
    str blob sub_type text segment size 16384 character set UTF8
)returns
        blob sub_type text segment size 16384 character set UTF8
external name
    'fb_json!encode'
engine
    udr
;

function decode(
    str blob sub_type text segment size 16384 character set UTF8
)returns
        blob sub_type text segment size 16384 character set UTF8
external name
    'fb_json!decode'
engine
    udr
;

function append(
    json   blob sub_type text segment size 16384 character set UTF8
  , key    varchar(8191)                         character set UTF8
  , value_ blob sub_type text segment size 16384 character set UTF8
  , type_  smallint
)returns   blob sub_type text segment size 16384 character set UTF8
external name
    'fb_json!append'
engine
    udr
;

function put(
    json   blob sub_type text segment size 16384 character set UTF8
  , key    varchar(8191)                         character set UTF8
  , value_ blob sub_type text segment size 16384 character set UTF8
  , type_  smallint
)returns   blob sub_type text segment size 16384 character set UTF8
external name
    'fb_json!put'
engine
    udr
;

function remove(
    json   blob sub_type text character set UTF8
  , key    varchar(8191)      character set UTF8
)returns   blob sub_type text character set UTF8
external name
    'fb_json!remove'
engine
    udr
;

end
^

SET TERM ; ^
