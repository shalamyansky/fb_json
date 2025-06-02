(*
    Unit     : fbjson_register
    Date     : 2025-03-10
    Compiler : Delphi 12
    Author   : Shalamyansky Mikhail Arkadievich
    Contents : Register UDR function for fb_json module
    Project  : https://github.com/shalamyansky/fb_json
    Company  : BWR
*)
(*
    References and thanks:

    Denis Simonov. Firebird UDR writing in Pascal.
                   2019, IBSurgeon

*)
//DDL definition
(*
set term ^;

create or alter package json
as begin

procedure parse(
    json        varchar(8191)      character set UTF8
)returns(
    source_type smallint
  , number      integer
  , key         varchar(8191)      character set UTF8
  , value_      varchar(8191)      character set UTF8
  , value_type  smallint
)
;

procedure parse_blob(
    json        blob sub_type text character set UTF8
)returns(
    source_type smallint
  , number      integer
  , key         varchar(8191)      character set UTF8
  , value_      blob sub_type text character set UTF8
  , value_type  smallint
)
;

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
  , type_  smallint
)returns   blob sub_type text character set UTF8
;

function put(
    json   blob sub_type text character set UTF8
  , key    varchar(8191)      character set UTF8
  , value_ blob sub_type text character set UTF8
  , type_  smallint
)returns   blob sub_type text character set UTF8
;

function remove(
    json   blob sub_type text character set UTF8
  , key    varchar(8191)      character set UTF8
)returns   blob sub_type text character set UTF8
;

function array_to_object(
    json       blob sub_type text character set UTF8
  , key_name   varchar(8191)      character set UTF8
  , value_name varchar(8191)      character set UTF8
)returns       blob sub_type text character set UTF8
;

function object_to_array(
    json       blob sub_type text character set UTF8
  , key_name   varchar(8191)      character set UTF8
  , value_name varchar(8191)      character set UTF8
)returns       blob sub_type text character set UTF8
;

end^

recreate package body json
as
begin

procedure parse(
    json        varchar(8191)      character set UTF8
)returns(
    source_type smallint
  , number      integer
  , key         varchar(8191)      character set UTF8
  , value_      varchar(8191)      character set UTF8
  , value_type  smallint
)
external name
    'fb_json!parse'
engine
    udr
;

procedure parse_blob(
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
  , type_  smallint
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
  , type_  smallint
)returns   blob sub_type text character set UTF8
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

function array_to_object(
    json       blob sub_type text character set UTF8
  , key_name   varchar(8191)      character set UTF8
  , value_name varchar(8191)      character set UTF8
)returns       blob sub_type text character set UTF8
external name
    'fb_json!array_to_object'
engine
    udr
;

function object_to_array(
    json       blob sub_type text character set UTF8
  , key_name   varchar(8191)      character set UTF8
  , value_name varchar(8191)      character set UTF8
)returns       blob sub_type text character set UTF8
external name
    'fb_json!object_to_array'
engine
    udr
;

end^

set term ;^
*)
unit fbjson_register;

interface

uses
    firebird
;

function firebird_udr_plugin( AStatus:IStatus; AUnloadFlagLocal:BooleanPtr; AUdrPlugin:IUdrPlugin ):BooleanPtr; cdecl;


implementation


uses
    fbjson
;

var
    myUnloadFlag    : BOOLEAN;
    theirUnloadFlag : BooleanPtr;

function firebird_udr_plugin( AStatus:IStatus; AUnloadFlagLocal:BooleanPtr; AUdrPlugin:IUdrPlugin ):BooleanPtr; cdecl;
begin
    AUdrPlugin.registerProcedure( AStatus, 'parse',           fbjson.TParseProcedureFactory.Create()        );
    AUdrPlugin.registerFunction(  AStatus, 'encode',          fbjson.TEncodeFunctionFactory.Create()        );
    AUdrPlugin.registerFunction(  AStatus, 'decode',          fbjson.TDecodeFunctionFactory.Create()        );
    AUdrPlugin.registerFunction(  AStatus, 'append',          fbjson.TAppendFunctionFactory.Create()        );
    AUdrPlugin.registerFunction(  AStatus, 'put',             fbjson.TPutFunctionFactory.Create()           );
    AUdrPlugin.registerFunction(  AStatus, 'remove',          fbjson.TRemoveFunctionFactory.Create()        );
    AUdrPlugin.registerFunction(  AStatus, 'array_to_object', fbjson.TArrayToObjectFunctionFactory.Create() );
    AUdrPlugin.registerFunction(  AStatus, 'object_to_array', fbjson.TObjectToArrayFunctionFactory.Create() );

    theirUnloadFlag := AUnloadFlagLocal;
    Result          := @myUnloadFlag;
end;{ firebird_udr_plugin }

procedure InitalizationProc;
begin
    IsMultiThread := TRUE;
    myUnloadFlag  := FALSE;
end;{ InitalizationProc }

procedure FinalizationProc;
begin
    if( ( theirUnloadFlag <> nil ) and ( not myUnloadFlag ) )then begin
        theirUnloadFlag^ := TRUE;
    end;
end;{ FinalizationProc }

initialization
begin
    InitalizationProc;
end;

finalization
begin
    FinalizationProc;
end;

end.
