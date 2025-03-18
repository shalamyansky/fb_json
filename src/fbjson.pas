(*
    Unit     : fbjson
    Date     : 2023-01-10
    Compiler : Delphi 12
    Author   : Shalamyansky Mikhail Arkadievich
    Contents : Firebird UDR JSON support procedure
    Project  : https://github.com/shalamyansky/fb_json
    Company  : BWR
*)

unit fbjson;

interface

uses
    SysUtils
  , firebird  // https://github.com/shalamyansky/fb_common
  , fbudr     // https://github.com/shalamyansky/fb_common
  , JSON
;

const
  JSON_NONE   = 0;
  JSON_NULL   = 1;
  JSON_BOOL   = 2;
  JSON_NUMBER = 3;
  JSON_STRING = 4;
  JSON_PAIR   = 5;
  JSON_OBJECT = 6;
  JSON_ARRAY  = 7;

type

{ TParseProcedure }

TParseProcedureFactory = class( TBwrProcedureFactory )
  public
    function newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalProcedure; override;
end;{ TParseProcedureFactory }

TParseProcedure = class( TBwrSelectiveProcedure )
  const
    INPUT_FIELD_JSON    = 0;
    OUTPUT_FIELD_SOURCE = 0;
    OUTPUT_FIELD_NUMBER = 1;
    OUTPUT_FIELD_KEY    = 2;
    OUTPUT_FIELD_VALUE  = 3;
    OUTPUT_FIELD_TYPE   = 4;
  protected
    class function GetBwrResultSetClass:TBwrResultSetClass; override;
end;{ TParseProcedure }

TParseResultSet = class( TBwrResultSet )
  private
    fSource : TJSonValue;
    fType   : SMALLINT;
    fCount  : LONGINT;
    fNumber : LONGINT;
  public
    constructor Create( ASelectiveProcedure:TBwrSelectiveProcedure; AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER ); override;
    destructor Destroy; override;
    function  fetch( AStatus:IStatus ):BOOLEAN; override;
    procedure ReleaseDoc;
end;{ TParseResultSet }

{ TEncodeFunction }

TEncodeFunctionFactory = class( TBwrFunctionFactory )
  public
    function newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction; override;
end;{ TEncodeFunctionFactory }

TEncodeFunction = class( TBwrFunction )
  const
    INPUT_FIELD_STRING  = 0;
    OUTPUT_FIELD_RESULT = 0;
  public
    procedure execute( AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER ); override;
end;{ TEncodeFunction }

{ TDecodeFunction }

TDecodeFunctionFactory = class( TBwrFunctionFactory )
  public
    function newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction; override;
end;{ TDecodeFunctionFactory }

TDecodeFunction = class( TBwrFunction )
  const
    INPUT_FIELD_STRING  = 0;
    OUTPUT_FIELD_RESULT = 0;
  public
    procedure execute( AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER ); override;
end;{ TDecodeFunction }

{ TAppendFunction }

TAppendFunctionFactory = class( TBwrFunctionFactory )
  public
    function newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction; override;
end;{ TAppendFunctionFactory }

TAppendFunction = class( TBwrFunction )
  const
    INPUT_FIELD_JSON    = 0;
    INPUT_FIELD_KEY     = 1;
    INPUT_FIELD_VALUE   = 2;
    OUTPUT_FIELD_RESULT = 0;
  public
    procedure execute( AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER ); override;
end;{ TAppendFunction }

{ TPutFunction }

TPutFunctionFactory = class( TBwrFunctionFactory )
  public
    function newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction; override;
end;{ TPutFunctionFactory }

TPutFunction = class( TBwrFunction )
  const
    INPUT_FIELD_JSON    = 0;
    INPUT_FIELD_KEY     = 1;
    INPUT_FIELD_VALUE   = 2;
    OUTPUT_FIELD_RESULT = 0;
  public
    procedure execute( AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER ); override;
end;{ TPutFunction }


implementation


function GetJsonType( Value:TJSONAncestor ):SMALLINT;
begin
    Result := JSON_NONE;
    if( Value = nil )then begin
        ;
    end else if( Value is TJsonNull )then begin
        Result := JSON_NULL;
    end else if( Value is TJsonBool )then begin
        Result := JSON_BOOL;
    end else if( Value is TJsonNumber )then begin
        Result := JSON_NUMBER;
    end else if( Value is TJsonString )then begin
        Result := JSON_STRING;
    end else if( Value is TJsonPair )then begin
        Result := JSON_PAIR;
    end else if( Value is TJsonObject )then begin
        Result := JSON_OBJECT;
    end else if( Value is TJsonArray )then begin
        Result := JSON_ARRAY;
    end;
end;{ GetJsonType }

function ToString( Value:TJSONAncestor ):UnicodeString;
begin
    System.Finalize( Result );
    if( Value = nil )then begin
        ;
    end else if(
         ( Value is TJsonNull   )
      or ( Value is TJsonBool   )
      or ( Value is TJsonNumber )
      or ( Value is TJsonString )
    )then begin
        Result := Value.Value;
    end else if(
         ( Value is TJsonPair   )
      or ( Value is TJsonObject )
      or ( Value is TJsonArray )
    )then begin
        Result := Value.ToJSON( [ TJSONAncestor.TJSONOutputOption.EncodeBelow32 ] );
    end;
end;{ ToString }

function GetJsonCount( Value:TJSONAncestor ):LONGINT;
begin
    Result := 0;
    if( Value = nil )then begin
        ;
    end else if(
         ( Value is TJsonNull   )
      or ( Value is TJsonBool   )
      or ( Value is TJsonNumber )
      or ( Value is TJsonString )
      or ( Value is TJsonPair   )
    )then begin
        Result := 1;
    end else if( Value is TJsonObject )then begin
        Result := TJsonObject( Value ).Count;
    end else if( Value is TJsonArray )then begin
        Result := TJsonArray( Value ).Count;
    end;
end;{ GetJsonCount }

function Encode( S:UnicodeString ):UnicodeString;
var
    JsonString : TJSonString;
begin
    Result := S;
    if( S <> '' )then begin
        try
            JsonString := nil;
            JsonString := TJSonString.Create( S );
            Result := JsonString.ToJSON( [ TJSONAncestor.TJSONOutputOption.EncodeBelow32 ] );
        finally
            FreeAndNil( JsonString );
        end;
    end;
end;{ Decode }

function Decode( S:UnicodeString ):UnicodeString;
var
    JsonString : TJSonString;
    JsonValue  : TJSonValue;
begin
    Result := S;
    if( S <> '' )then begin
        try
            JsonValue := nil;
            JsonValue := TJSonValue.ParseJSONValue( S, True, True );
            Result    := JsonValue.Value;
        finally
            FreeAndNil( JsonValue );
        end;
    end;
end;{ Decode }

function Append( Json, Key, Value : UnicodeString ):UnicodeString;
var
    JsonValue  : TJSonValue;
begin
    Result := '';
    try
        JsonValue := nil;
        if( Json <> '' )then begin
            JsonValue := TJsonValue.ParseJSONValue( Json );
        end;
        if( Key <> '' )then begin  //Json must be object
            if( JsonValue = nil )then begin
                JsonValue := TJsonObject.Create;
            end;
            if( JsonValue is TJsonObject )then begin
                TJSonObject( JsonValue ).AddPair( Key, Value );
            end;
        end else begin             //Json must be array
            if( JsonValue = nil )then begin
                JsonValue := TJsonArray.Create;
            end;
            if( JsonValue is TJSonArray )then begin
                TJSonArray( JsonValue ).Add( Value );
            end;
        end;
        Result := ToString( JsonValue );
    finally
        FreeAndNil( JsonValue );
    end;
end;{ Append }

function put( Json, Key, Value : UnicodeString ):UnicodeString;
var
    JsonValue : TJSonValue;
    Pair      : TJSonPair;
begin
    Result := '';
    if( Key = '' )then begin
        exit;
    end;
    try
        JsonValue := nil;
        if( Json <> '' )then begin
            JsonValue := TJsonValue.ParseJSONValue( Json );
        end;
        if( JsonValue = nil )then begin
            JsonValue := TJsonObject.Create;
            TJSonObject( JsonValue ).AddPair( Key, Value );
        end else begin
            Pair := TJSonObject( JsonValue ).Get( Key );
            if( Pair = nil )then begin
                TJSonObject( JsonValue ).AddPair( Key, Value );
            end else begin
                Pair.JsonValue := TJsonString.Create( Value );
            end;
        end;
        Result := ToString( JsonValue );
    finally
        FreeAndNil( JsonValue );
    end;
end;{ put }


{ TParseProcedureFactory }

function TParseProcedureFactory.newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalProcedure;
begin
    Result := TParseProcedure.create( AMetadata );
end;{ TParseProcedureFactory.newItem }

{ TParseProcedure }

class function TParseProcedure.GetBwrResultSetClass:TBwrResultSetClass;
begin
    Result := TParseResultSet;
end;{ TParseProcedure.GetBwrResultSetClass }


{ TParseResultSet }

constructor TParseResultSet.Create( ASelectiveProcedure:TBwrSelectiveProcedure; AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER );
var
    Json       : UnicodeString;
    JsonNull   : WORDBOOL;
    JsonOk     : BOOLEAN;
begin
    inherited Create( ASelectiveProcedure, AStatus, AContext, AInMsg, AOutMsg );
    fSource := nil;
    fType   := JSON_NONE;
    fCount  := 0;
    fNumber := 0;

    JsonOk := RoutineContext.ReadInputString( AStatus, TParseProcedure.INPUT_FIELD_JSON, Json, JsonNull );
    if( not JsonNull )then begin
        Json := Trim( Json );
    end;
    if( Json <> '' )then begin
        fSource := TJSonValue.ParseJSONValue( Json, True, True );
        fType   := GetJsonType( fSource );
        fCount  := GetJsonCount( fSource );
    end;
end;{ TParseResultSet.Create }

destructor TParseResultSet.Destroy;
begin
    ReleaseDoc;
    inherited Destroy;
end;{ TJsonResultSet.Destroy; }

procedure TParseResultSet.ReleaseDoc;
begin
    FreeAndNil( fSource );
    fType   := JSON_NONE;
    fCount  := 0;
    fNumber := 0;
end;{ TParseResultSet.ReleaseDoc }

function TParseResultSet.fetch( AStatus:IStatus ):BOOLEAN;
var
    Key, Value : UnicodeString;
    ValueType  : SMALLINT;
    SourceNull, NumberNull, KeyNull, ValueNull, TypeNull : WORDBOOL;
    SourceOk,   NumberOk,   KeyOk,   ValueOk,   TypeOk   : BOOLEAN;
    Pair : TJSonPair;
    Item : TJSonValue;
begin
    Result     := FALSE;
    SourceNull := TRUE;
    NumberNull := TRUE;
    System.Finalize( Key );
    KeyNull    := TRUE;
    System.Finalize( Value );
    ValueNull  := TRUE;
    ValueType  := 0;
    TypeNull   := TRUE;
    if( ( fSource <> nil ) and ( fNumber < fCount ) and ( fType > JSON_NONE ) )then begin
        SourceNull := FALSE;
        case fType of
            JSON_NULL, JSON_BOOL, JSON_NUMBER, JSON_STRING : begin
                ValueType := fType;
                TypeNull  := FALSE;
                Value     := fSource.Value;
                ValueNull := FALSE;
            end;
            JSON_PAIR : begin
                Key       := TJSonPair( fSource ).JsonString.Value;
                KeyNull   := FALSE;
                ValueType := fType;
                TypeNull  := FALSE;
                Value     := fSource.Value;
                ValueNull := FALSE;
            end;
            JSON_OBJECT : begin
                Pair  := TJsonObject( fSource ).Pairs[ fNumber ];
                Key   := Pair.JsonString.Value;
                if( Key <> '' )then begin
                    KeyNull   := FALSE;
                    ValueType := fbjson.GetJsonType( Pair.JSonValue );
                    TypeNull  := ( ValueType = JSON_NONE );
                    Value     := fbjson.ToString( Pair.JSonValue );
                    ValueNull := ( Value = '' ) and ( ValueType <> JSON_STRING );
                end;
            end;
            JSON_ARRAY : begin
                Item      := TJsonArray( fSource ).Items[ fNumber ];
                ValueType := fbjson.GetJsonType( Item );
                TypeNull  := ( ValueType = JSON_NONE );
                Value     := fbjson.ToString( Item );
                ValueNull := ( Value = '' ) and ( ValueType <> JSON_STRING );
            end;
        end;
        Inc( fNumber );
        NumberNull := FALSE;
        Result     := TRUE;
    end else begin
        Result := FALSE;
        ReleaseDoc;
    end;
    SourceOk := RoutineContext.WriteOutputSmallint( AStatus, TParseProcedure.OUTPUT_FIELD_SOURCE, fType,     SourceNull );
    NumberOk := RoutineContext.WriteOutputLongint(  AStatus, TParseProcedure.OUTPUT_FIELD_NUMBER, fNumber,   NumberNull );
    KeyOk    := RoutineContext.WriteOutputString(   AStatus, TParseProcedure.OUTPUT_FIELD_KEY,    Key,       KeyNull    );
    ValueOk  := RoutineContext.WriteOutputString(   AStatus, TParseProcedure.OUTPUT_FIELD_VALUE,  Value,     ValueNull  );
    TypeOk   := RoutineContext.WriteOutputSmallint( AStatus, TParseProcedure.OUTPUT_FIELD_TYPE,   ValueType, TypeNull   );
end;{ TParseResultSet.fetch }


{ TEncodeFunction }

function TEncodeFunctionFactory.newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction;
begin
    Result := TEncodeFunction.create( AMetadata );
end;{ TEncodeFunctionFactory.newItem }

procedure TEncodeFunction.execute( AStatus:IStatus; AContext:IExternalContext; aInMsg:POINTER; aOutMsg:POINTER );
var
    Str,     Result     : UnicodeString;
    StrNull, ResultNull : WORDBOOL;
    StrOk,   ResultOk   : BOOLEAN;
begin
    inherited execute( AStatus, AContext, aInMsg, aOutMsg );
    System.Finalize( Str    );
    System.Finalize( Result );
    ResultNull := TRUE;
    ResultOk   := FALSE;
    StrOk      := RoutineContext.ReadInputString( AStatus, TEncodeFunction.INPUT_FIELD_STRING, Str, StrNull );

    Result     := Str;
    ResultNull := StrNull;
    if( not StrNull )then begin
        Result := Encode( Str );
    end;
    ResultOk := RoutineContext.WriteOutputString( AStatus, TEncodeFunction.OUTPUT_FIELD_RESULT, Result, ResultNull );
end;{ TEncodeFunction.execute }

{ TDecodeFunction }

function TDecodeFunctionFactory.newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction;
begin
    Result := TDecodeFunction.create( AMetadata );
end;{ TDecodeFunctionFactory.newItem }

procedure TDecodeFunction.execute( AStatus:IStatus; AContext:IExternalContext; aInMsg:POINTER; aOutMsg:POINTER );
var
    Str,     Result     : UnicodeString;
    StrNull, ResultNull : WORDBOOL;
    StrOk,   ResultOk   : BOOLEAN;
begin
    inherited execute( AStatus, AContext, aInMsg, aOutMsg );
    System.Finalize( Str    );
    System.Finalize( Result );
    ResultNull := TRUE;
    ResultOk   := FALSE;
    StrOk      := RoutineContext.ReadInputString( AStatus, TDecodeFunction.INPUT_FIELD_STRING, Str, StrNull );

    Result     := Str;
    ResultNull := StrNull;
    if( not StrNull )then begin
        Result := Decode( Str );
    end;
    ResultOk := RoutineContext.WriteOutputString( AStatus, TDecodeFunction.OUTPUT_FIELD_RESULT, Result, ResultNull );
end;{ TDecodeFunction.execute }

{ TAppendFunction }

function TAppendFunctionFactory.newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction;
begin
    Result := TAppendFunction.create( AMetadata );
end;{ TAppendFunctionFactory.newItem }

procedure TAppendFunction.execute( AStatus:IStatus; AContext:IExternalContext; aInMsg:POINTER; aOutMsg:POINTER );
var
    Json,     Key,     Value,     Result     : UnicodeString;
    JsonNull, KeyNull, ValueNull, ResultNull : WORDBOOL;
    JsonOk,   KeyOk,   ValueOk,   ResultOk   : BOOLEAN;
begin
    inherited execute( AStatus, AContext, aInMsg, aOutMsg );
    System.Finalize( Json   );
    System.Finalize( Result );
    ResultNull := TRUE;
    ResultOk   := FALSE;
    JsonOk     := RoutineContext.ReadInputString( AStatus, TAppendFunction.INPUT_FIELD_JSON, Json,   JsonNull  );
    KeyOk      := RoutineContext.ReadInputString( AStatus, TAppendFunction.INPUT_FIELD_KEY,  Key,    KeyNull   );
    ValueOk    := RoutineContext.ReadInputString( AStatus, TAppendFunction.INPUT_FIELD_VALUE, Value, ValueNull );

    Result     := Append( Json, Key, Value );
    ResultNull := ( Result = '' );

    ResultOk := RoutineContext.WriteOutputString( AStatus, TAppendFunction.OUTPUT_FIELD_RESULT, Result, ResultNull );
end;{ TAppendFunction.execute }

{ TPutFunction }

function TPutFunctionFactory.newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction;
begin
    Result := TPutFunction.create( AMetadata );
end;{ TPutFunctionFactory.newItem }

procedure TPutFunction.execute( AStatus:IStatus; AContext:IExternalContext; aInMsg:POINTER; aOutMsg:POINTER );
var
    Json,     Key,     Value,     Result     : UnicodeString;
    JsonNull, KeyNull, ValueNull, ResultNull : WORDBOOL;
    JsonOk,   KeyOk,   ValueOk,   ResultOk   : BOOLEAN;
begin
    inherited execute( AStatus, AContext, aInMsg, aOutMsg );
    System.Finalize( Json   );
    System.Finalize( Result );
    ResultNull := TRUE;
    ResultOk   := FALSE;
    JsonOk     := RoutineContext.ReadInputString( AStatus, TPutFunction.INPUT_FIELD_JSON, Json,   JsonNull  );
    KeyOk      := RoutineContext.ReadInputString( AStatus, TPutFunction.INPUT_FIELD_KEY,  Key,    KeyNull   );
    ValueOk    := RoutineContext.ReadInputString( AStatus, TPutFunction.INPUT_FIELD_VALUE, Value, ValueNull );

    Result     := put( Json, Key, Value );
    ResultNull := ( Result = '' );

    ResultOk := RoutineContext.WriteOutputString( AStatus, TPutFunction.OUTPUT_FIELD_RESULT, Result, ResultNull );
end;{ TPutFunction.execute }


procedure InitProc;
begin
end;{ InitProc }

procedure FinalProc;
begin
end;{ FinalProc }

initialization
begin
    InitProc;
end;{ initialization }

finalization
begin
    FinalProc;
end;{ finalization }

end.
