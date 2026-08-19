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

TJsonParamType = (
    JSON_PARAM_UNKNOWN
  , JSON_PARAM_POINTER
  , JSON_PARAM_STRING
);{ TJsonParamType }

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


{ TCreateJsonProcedure }

TCreateJsonProcedureFactory = class( TBwrProcedureFactory )
  public
    function newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalProcedure; override;
end;{ TCreateJsonProcedureFactory }

TCreateJsonProcedure = class( TBwrSelectiveProcedure )
  const
    INPUT_FIELD_JSON    = 0;
    OUTPUT_FIELD_HANDLE = 0;
  protected
    class function GetBwrResultSetClass:TBwrResultSetClass; override;
end;{ TCreateJsonProcedure }

TCreateJsonResultSet = class( TBwrResultSet )
  private
    fSource  : TJSonValue;
    fType    : SMALLINT;
    fFetched : BOOLEAN;
  public
    constructor Create( ASelectiveProcedure:TBwrSelectiveProcedure; AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER ); override;
    destructor  Destroy; override;
    function    fetch( AStatus:IStatus ):BOOLEAN; override;
    procedure   ReleaseDoc;
end;{ TCreateJsonResultSet }


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
    INPUT_FIELD_TYPE    = 3;
    OUTPUT_FIELD_RESULT = 0;
  private
    fJsonParamType : TJsonParamType;
  public
    constructor Create( AStatus:IStatus; RoutineMetadata:IRoutineMetadata ); virtual;
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
    INPUT_FIELD_TYPE    = 3;
    OUTPUT_FIELD_RESULT = 0;
  private
    fJsonParamType : TJsonParamType;
  public
    constructor Create( AStatus:IStatus; RoutineMetadata:IRoutineMetadata ); virtual;
    procedure execute( AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER ); override;
end;{ TPutFunction }


{ TSerializeFunction }

TSerializeFunctionFactory = class( TBwrFunctionFactory )
  public
    function newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction; override;
end;{ TSerializeFunctionFactory }

TSerializeFunction = class( TBwrFunction )
  const
    INPUT_FIELD_JSON    = 0;
    OUTPUT_FIELD_RESULT = 0;
  public
    procedure execute( AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER ); override;
end;{ TSerializeFunction }



{ TRemoveFunction }

TRemoveFunctionFactory = class( TBwrFunctionFactory )
  public
    function newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction; override;
end;{ TRemoveFunctionFactory }

TRemoveFunction = class( TBwrFunction )
  const
    INPUT_FIELD_JSON    = 0;
    INPUT_FIELD_KEY     = 1;
    OUTPUT_FIELD_RESULT = 0;
  public
    procedure execute( AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER ); override;
end;{ TRemoveFunction }


{ TArrayToObjectFunction }

TArrayToObjectFunctionFactory = class( TBwrFunctionFactory )
  public
    function newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction; override;
end;{ TArrayToObjectFunctionFactory }

TArrayToObjectFunction = class( TBwrFunction )
  const
    INPUT_FIELD_JSON       = 0;
    INPUT_FIELD_KEY_NAME   = 1;
    INPUT_FIELD_VALUE_NAME = 2;
    OUTPUT_FIELD_RESULT    = 0;
  public
    procedure execute( AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER ); override;
end;{ TArrayToObjectFunction }

{ TObjectToArrayFunction }

TObjectToArrayFunctionFactory = class( TBwrFunctionFactory )
  public
    function newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction; override;
end;{ TArrayToObjectFunctionFactory }

TObjectToArrayFunction = class( TBwrFunction )
  const
    INPUT_FIELD_JSON       = 0;
    INPUT_FIELD_KEY_NAME   = 1;
    INPUT_FIELD_VALUE_NAME = 2;
    OUTPUT_FIELD_RESULT    = 0;
  public
    procedure execute( AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER ); override;
end;{ TObjectToArrayFunction }


implementation

function Clone( Value:TJSONValue ):TJSONValue;
begin
    Result := nil;
    if( ( Value <> nil ) and ( Value is TJSONValue ) )then begin
        Result := TJSONValue( Value.Clone );
    end;
end;{ Clone }

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

function CreateJsonValue( Value:UnicodeString; ValueType:SMALLINT ):TJSonValue;
begin
    Result := nil;
    case ValueType of
        JSON_NULL   : begin
            Result := TJSonNull.Create;
        end;
        JSON_BOOL   : begin
            Result := TJsonValue.ParseJSONValue( Value );
            if( not ( Result is TJSonBool ) )then begin
                FreeAndNil( Result );
            end;
        end;
        JSON_NUMBER : begin
            if( Trim( Value ) <> '' )then begin
                Result := TJSonNumber.Create( Value );
            end;
        end;
        JSON_STRING : begin
            Result := TJSonString.Create( Value );
        end;
        JSON_OBJECT : begin
            Result := TJsonValue.ParseJSONValue( Value );
            if( not ( Result is TJSonObject ) )then begin
                FreeAndNil( Result );
            end;
        end;
        JSON_ARRAY  : begin
            Result := TJsonValue.ParseJSONValue( Value );
            if( not ( Result is TJSonArray ) )then begin
                FreeAndNil( Result );
            end;
        end;
    end;
end;{ CreateJsonValue }

function encode( S:UnicodeString ):UnicodeString;
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
end;{ encode }

function decode( S:UnicodeString ):UnicodeString;
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
end;{ decode }

function h_append( JsonValue:TJSonValue; Key, Value : UnicodeString; ValueType:SMALLINT ):BOOLEAN;
var
    ChildValue : TJSonValue;
begin
    Result := FALSE;
    if( Key <> '' )then begin  //Json must be object
        if( JsonValue is TJsonObject )then begin
            try
                ChildValue := nil;
                ChildValue := CreateJsonValue( Value, ValueType );
                if( ChildValue <> nil )then begin
                    TJSonObject( JsonValue ).AddPair( Key, ChildValue );
                    Result := TRUE;
                end;
            finally
                if( not Result )then begin
                    FreeAndNil( ChildValue );
                end;
            end;
        end;
    end else begin             //Json must be array
        if( JsonValue is TJSonArray )then begin
            try
                ChildValue := nil;
                ChildValue := CreateJsonValue( Value, ValueType );
                if( ChildValue <> nil )then begin
                    TJSonArray( JsonValue ).AddElement( ChildValue );
                    Result := TRUE;
                end;
            finally
                if( not Result )then begin
                    FreeAndNil( ChildValue );
                end;
            end;
        end;
    end;
end;{ h_append }

function append( Json, Key, Value : UnicodeString; ValueType : SMALLINT ):UnicodeString;
var
    JsonValue : TJSonValue;
begin
    Result := Json;
    try
        JsonValue  := nil;
        if( Json <> '' )then begin
            JsonValue := TJsonValue.ParseJSONValue( Json );
        end else begin
            case Key = '' of
                FALSE : JsonValue := TJsonObject.Create;
                TRUE  : JsonValue := TJsonArray.Create;
            end;
        end;
        if( h_append( JsonValue, Key, Value, ValueType ) )then begin
            Result := ToString( JsonValue );
        end;
    finally
        FreeAndNil( JsonValue );
    end;
end;{ append }

function h_put( JsonValue:TJSonValue; Key, Value : UnicodeString; ValueType:SMALLINT ):BOOLEAN;
var
    ChildValue   : TJSonValue;
    Pair         : TJSonPair;
    ChildApplied : BOOLEAN;
begin
    Result       := FALSE;
    ChildApplied := FALSE;
    if( Key = '' )then begin
        exit;
    end;
    try
        ChildValue := nil;
        ChildValue := CreateJsonValue( Value, ValueType );
        if( ChildValue <> nil )then begin
            if( JsonValue is TJSonObject )then begin
                Pair := TJSonObject( JsonValue ).Get( Key );
                if( Pair = nil )then begin
                    TJSonObject( JsonValue ).AddPair( Key, ChildValue );
                end else begin
                    Pair.JsonValue := ChildValue;
                end;
                ChildApplied := TRUE;
                Result       := TRUE;
            end;
        end else begin
            if( JsonValue is TJSonObject )then begin
                TJsonObject( JsonValue ).RemovePair( Key );
                Result    := TRUE;
            end;
        end;
    finally
        if( not ChildApplied )then begin
            FreeAndNil( ChildValue );
        end;
    end;
end;{ h_put }

function put( Json, Key, Value : UnicodeString; ValueType : SMALLINT ):UnicodeString;
var
    JsonValue : TJSonValue;
begin
    Result := Json;
    try
        JsonValue  := nil;
        if( Json <> '' )then begin
            JsonValue := TJsonValue.ParseJSONValue( Json );
        end else begin
            JsonValue := TJsonObject.Create;
        end;
        if( h_put( JsonValue, Key, Value, ValueType ) )then begin
            Result := ToString( JsonValue );
        end;
    finally
        FreeAndNil( JsonValue );
    end;
end;{ put }

function remove( Json, Key : UnicodeString ):UnicodeString;
var
    JsonValue : TJSonValue;
begin
    Result := Json;
    try
        JsonValue := TJsonValue.ParseJSONValue( Json );
        TJSonObject( JsonValue ).RemovePair( Key );
        Result := ToString( JsonValue );
    finally
        FreeAndNil( JsonValue );
    end;
end;{ remove }

function array_to_object( Json, KeyName, ValueName : UnicodeString ):UnicodeString;
var
    JsonValue, Item, KeyJson, ValueJson : TJSonValue;
    JsonArray  : TJSonArray absolute JsonValue;
    i          : LONGINT;
    JsonResult : TJsonObject;
begin
    Result     := '';
    JsonValue  := nil;
    JsonResult := nil;
    try
        JsonValue := TJsonValue.ParseJSONValue( Json );
        if( ( JsonValue <> nil ) and ( JsonValue is TJsonArray ) )then begin
            JsonResult := TJsonObject.Create;
            for i := 0 to JsonArray.Count - 1 do begin
                Item := JsonArray.Items[ i ];
                if( ( Item <> nil ) and ( Item is TJsonObject ) )then begin
                    KeyJson := TJsonObject( Item ).GetValue( KeyName );
                    if( ( KeyJson <> nil ) and ( KeyJson is TJsonString ) )then begin
                        ValueJson := TJsonObject( Item ).GetValue( ValueName );
                        JsonResult.AddPair( TJsonString( KeyJson ).Value, Clone( ValueJson ) );
                    end;
                end;
            end;
            Result := ToString( JsonResult );
        end;
    finally
        FreeAndNil( JsonResult );
        FreeAndNil( JsonValue  );
    end;
end;{ array_to_object }

function object_to_array( Json, KeyName, ValueName : UnicodeString ):UnicodeString;
var
    JsonValue, ValueJson : TJSonValue;
    JsonObject : TJSonObject absolute JsonValue;
    Item       : TJsonObject;
    Pair       : TJsonPair;
    i          : LONGINT;
    KeyJson    : TJsonString;
    JsonResult : TJsonArray;
begin
    Result     := '';
    JsonValue  := nil;
    JsonResult := nil;
    try
        JsonValue := TJsonValue.ParseJSONValue( Json );
        if( ( JsonValue <> nil ) and ( JsonValue is TJsonObject ) )then begin
            JsonResult := TJsonArray.Create;
            for i := 0 to JsonObject.Count - 1 do begin
                Pair := JsonObject.Pairs[ i ];
                if( ( Pair <> nil ) and ( Pair is TJsonPair ) )then begin
                    KeyJson := Pair.JsonString;
                    if( KeyJson <> nil )then begin
                        ValueJson := Pair.JsonValue;
                        Item := TJsonObject.Create;
                        Item.AddPair( KeyName,   Clone( KeyJson )   );
                        Item.AddPair( ValueName, Clone( ValueJson ) );
                        JsonResult.Add( Item );
                    end;
                end;
            end;
            Result := ToString( JsonResult );
        end;
    finally
        FreeAndNil( JsonResult );
        FreeAndNil( JsonValue  );
    end;
end;{ object_to_array }


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


{ TCreateJsonProcedureFactory }

function TCreateJsonProcedureFactory.newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalProcedure;
begin
    Result := TCreateJsonProcedure.create( AMetadata );
end;{ TCreateJsonProcedureFactory.newItem }

{ TCreateJsonProcedure }

class function TCreateJsonProcedure.GetBwrResultSetClass:TBwrResultSetClass;
begin
    Result := TCreateJsonResultSet;
end;{ TCreateJsonProcedure.GetBwrResultSetClass }

{ TCreateJsonResultSet }

constructor TCreateJsonResultSet.Create( ASelectiveProcedure:TBwrSelectiveProcedure; AStatus:IStatus; AContext:IExternalContext; AInMsg:POINTER; AOutMsg:POINTER );
var
    Json       : UnicodeString;
    JsonNull   : WORDBOOL;
    JsonOk     : BOOLEAN;
begin
    inherited Create( ASelectiveProcedure, AStatus, AContext, AInMsg, AOutMsg );
    fSource  := nil;
    fType    := JSON_NONE;
    fFetched := FALSE;

    JsonOk := RoutineContext.ReadInputString( AStatus, TCreateJsonProcedure.INPUT_FIELD_JSON, Json, JsonNull );
    if( not JsonNull )then begin
        Json := Trim( Json );
    end;
    if( Json <> '' )then begin
        fSource := TJSonValue.ParseJSONValue( Json, True, True );
    end else begin
        fSource := TJsonObject.Create;
    end;
    fType := GetJsonType( fSource );
end;{ TCreateJsonResultSet.Create }

destructor TCreateJsonResultSet.Destroy;
begin
    ReleaseDoc;
    inherited Destroy;
end;{ TCreateJsonResultSet.Destroy; }

procedure TCreateJsonResultSet.ReleaseDoc;
begin
    FreeAndNil( fSource );
    fType    := JSON_NONE;
    fFetched := TRUE;
end;{ TCreateJsonResultSet.ReleaseDoc }

function TCreateJsonResultSet.fetch( AStatus:IStatus ):BOOLEAN;
var
    Handle     : INT64;
    HandleNull : WORDBOOL;
    HandleOk   : BOOLEAN;
begin
    Result     := FALSE;
    Handle     := -1;
    HandleNull := TRUE;
    HandleOk   := FALSE;
    if( ( fSource <> nil ) and ( not fFetched ) )then begin
        Handle     := INT64( POINTER( fSource ) );
        HandleNull := FALSE;
        fFetched   := TRUE;
        Result     := TRUE;
    end else begin
        Result     := FALSE;
        ReleaseDoc;
    end;
    HandleOk := RoutineContext.WriteOutputBigint( AStatus, TCreateJsonProcedure.OUTPUT_FIELD_HANDLE, Handle, HandleNull );
end;{ TCreateJsonResultSet.fetch }


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
    Result := TAppendFunction.create( AStatus, AMetadata );
end;{ TAppendFunctionFactory.newItem }

constructor TAppendFunction.Create( AStatus:IStatus; RoutineMetadata:IRoutineMetadata );
var
    InputType, OutputType : UINT64;
begin
    inherited Create( RoutineMetadata );

    fJsonParamType := JSON_PARAM_UNKNOWN;
    InputType  := TRoutineContext.GetFieldType( AStatus, INPUT_MESSAGE,  INPUT_FIELD_JSON,    RoutineMetadata );
    OutputType := TRoutineContext.GetFieldType( AStatus, OUTPUT_MESSAGE, OUTPUT_FIELD_RESULT, RoutineMetadata );
    if(
            ( InputType  = FB_BIGINT )
        and ( OutputType = FB_BIGINT )
    )then begin
        fJsonParamType := JSON_PARAM_POINTER;
    end else if(
            ( ( InputType  = FB_CHAR ) or ( InputType  = FB_VARCHAR ) or ( InputType  = FB_BLOB ) )
        and ( ( OutputType = FB_CHAR ) or ( OutputType = FB_VARCHAR ) or ( OutputType = FB_BLOB ) )
    )then begin
        fJsonParamType := JSON_PARAM_STRING;
    end;
end;{ TAppendFunction.Create }

procedure TAppendFunction.execute( AStatus:IStatus; AContext:IExternalContext; aInMsg:POINTER; aOutMsg:POINTER );
var
    Json,                 Key,     Value,               Result     : UnicodeString;
              Handle                                               : INT64;
              JsonValue                                            : TJsonValue absolute Handle;
                                              Type_                : SMALLINT;
    JsonNull, HandleNull, KeyNull, ValueNull, TypeNull, ResultNull : WORDBOOL;
    JsonOk,   HandleOk,   KeyOk,   ValueOk,   TypeOk,   ResultOk   : BOOLEAN;
begin
    inherited execute( AStatus, AContext, aInMsg, aOutMsg );
    System.Finalize( Json   );
    Handle := 0;
    System.Finalize( Result );
    ResultNull := TRUE;
    ResultOk   := FALSE;
    KeyOk      := RoutineContext.ReadInputString(   AStatus, TAppendFunction.INPUT_FIELD_KEY,   Key,   KeyNull   );
    ValueOk    := RoutineContext.ReadInputString(   AStatus, TAppendFunction.INPUT_FIELD_VALUE, Value, ValueNull );
    TypeOk     := RoutineContext.ReadInputSmallint( AStatus, TAppendFunction.INPUT_FIELD_TYPE,  Type_, TypeNull  );

    if( ValueNull or TypeNull or ( Type_ = JSON_NONE ) )then begin
        Type_ := JSON_NULL;
    end;

    case fJsonParamType of
        JSON_PARAM_POINTER : begin
            HandleOk   := RoutineContext.ReadInputBigint( AStatus, TAppendFunction.INPUT_FIELD_JSON, Handle, HandleNull );
            HandleNull := TRUE; //for output
            if( h_append( JsonValue, Key, Value, Type_ ) )then begin
                HandleNull := ( POINTER( Handle ) = nil );
            end;
            Handle     := 0;
            HandleNull := TRUE;
            HandleOk   := RoutineContext.WriteOutputBigint( AStatus, TAppendFunction.OUTPUT_FIELD_RESULT, Handle, HandleNull );
        end;
        JSON_PARAM_STRING : begin
            JsonOk     := RoutineContext.ReadInputString( AStatus, TAppendFunction.INPUT_FIELD_JSON, Json, JsonNull );
            Result     := append( Json, Key, Value, Type_ );
            ResultNull := ( Result = '' );
            ResultOk   := RoutineContext.WriteOutputString( AStatus, TAppendFunction.OUTPUT_FIELD_RESULT, Result, ResultNull );
        end;
    end;

end;{ TAppendFunction.execute }


{ TPutFunction }

function TPutFunctionFactory.newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction;
begin
    Result := TPutFunction.create( AStatus, AMetadata );
end;{ TPutFunctionFactory.newItem }

constructor TPutFunction.Create( AStatus:IStatus; RoutineMetadata:IRoutineMetadata );
var
    InputType, OutputType : UINT64;
begin
    inherited Create( RoutineMetadata );

    fJsonParamType := JSON_PARAM_UNKNOWN;
    InputType  := TRoutineContext.GetFieldType( AStatus, INPUT_MESSAGE,  INPUT_FIELD_JSON,    RoutineMetadata );
    OutputType := TRoutineContext.GetFieldType( AStatus, OUTPUT_MESSAGE, OUTPUT_FIELD_RESULT, RoutineMetadata );
    if(
            ( InputType  = FB_BIGINT )
        and ( OutputType = FB_BIGINT )
    )then begin
        fJsonParamType := JSON_PARAM_POINTER;
    end else if(
            ( ( InputType  = FB_CHAR ) or ( InputType  = FB_VARCHAR ) or ( InputType  = FB_BLOB ) )
        and ( ( OutputType = FB_CHAR ) or ( OutputType = FB_VARCHAR ) or ( OutputType = FB_BLOB ) )
    )then begin
        fJsonParamType := JSON_PARAM_STRING;
    end;
end;{ TPutFunction.Create }

procedure TPutFunction.execute( AStatus:IStatus; AContext:IExternalContext; aInMsg:POINTER; aOutMsg:POINTER );
var
    Json,                 Key,     Value,               Result     : UnicodeString;
              Handle                                               : INT64;
              JsonValue                                            : TJsonValue absolute Handle;
                                              Type_                : SMALLINT;
    JsonNull, HandleNull, KeyNull, ValueNull, TypeNull, ResultNull : WORDBOOL;
    JsonOk,   HandleOk,   KeyOk,   ValueOk,   TypeOk,   ResultOk   : BOOLEAN;
begin
    inherited execute( AStatus, AContext, aInMsg, aOutMsg );
    System.Finalize( Json   );
    Handle := 0;
    System.Finalize( Result );
    ResultNull := TRUE;
    ResultOk   := FALSE;
    KeyOk      := RoutineContext.ReadInputString(   AStatus, TAppendFunction.INPUT_FIELD_KEY,   Key,   KeyNull   );
    ValueOk    := RoutineContext.ReadInputString(   AStatus, TAppendFunction.INPUT_FIELD_VALUE, Value, ValueNull );
    TypeOk     := RoutineContext.ReadInputSmallint( AStatus, TAppendFunction.INPUT_FIELD_TYPE,  Type_, TypeNull  );

    if( ValueNull or TypeNull or ( Type_ = JSON_NONE ) )then begin
        Type_ := JSON_NULL;
    end;

    case fJsonParamType of
        JSON_PARAM_POINTER : begin
            HandleOk   := RoutineContext.ReadInputBigint( AStatus, TAppendFunction.INPUT_FIELD_JSON, Handle, HandleNull );
            HandleNull := TRUE; //for output
            if( h_put( JsonValue, Key, Value, Type_ ) )then begin
                HandleNull := ( POINTER( Handle ) = nil );
            end;
            Handle     := 0;
            HandleNull := TRUE;
            HandleOk   := RoutineContext.WriteOutputBigint( AStatus, TAppendFunction.OUTPUT_FIELD_RESULT, Handle, HandleNull );
        end;
        JSON_PARAM_STRING : begin
            JsonOk     := RoutineContext.ReadInputString( AStatus, TAppendFunction.INPUT_FIELD_JSON, Json, JsonNull );
            Result     := put( Json, Key, Value, Type_ );
            ResultNull := ( Result = '' );
            ResultOk   := RoutineContext.WriteOutputString( AStatus, TAppendFunction.OUTPUT_FIELD_RESULT, Result, ResultNull );
        end;
    end;

end;{ TPutFunction.execute }


{ TSerializeFunction }

function TSerializeFunctionFactory.newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction;
begin
    Result := TSerializeFunction.create( AMetadata );
end;{ TSerializeFunctionFactory.newItem }

procedure TSerializeFunction.execute( AStatus:IStatus; AContext:IExternalContext; aInMsg:POINTER; aOutMsg:POINTER );
var
    Handle                 : INT64;
                Result     : UnicodeString;
    HandleNull, ResultNull : WORDBOOL;
    HandleOk,   ResultOk   : BOOLEAN;
begin
    inherited execute( AStatus, AContext, aInMsg, aOutMsg );
    Handle     := 0;
    HandleNull := TRUE;
    System.Finalize( Result );
    ResultNull := TRUE;
    ResultOk   := FALSE;
    HandleOk   := RoutineContext.ReadInputBigint( AStatus, TSerializeFunction.INPUT_FIELD_JSON, Handle, HandleNull  );

    if( HandleOk and ( not HandleNull ) and ( Handle <> 0 ) )then begin
        Result := fbjson.ToString( TJsonValue( POINTER( Handle ) ) );
    end;
    ResultNull := ( Result = '' );

    ResultOk := RoutineContext.WriteOutputString( AStatus, TSerializeFunction.OUTPUT_FIELD_RESULT, Result, ResultNull );
end;{ TSerializeFunction.execute }


{ TRemoveFunction }

function TRemoveFunctionFactory.newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction;
begin
    Result := TRemoveFunction.create( AMetadata );
end;{ TRemoveFunctionFactory.newItem }

procedure TRemoveFunction.execute( AStatus:IStatus; AContext:IExternalContext; aInMsg:POINTER; aOutMsg:POINTER );
var
    Json,     Key,     Result     : UnicodeString;
    JsonNull, KeyNull, ResultNull : WORDBOOL;
    JsonOk,   KeyOk,   ResultOk   : BOOLEAN;
begin
    inherited execute( AStatus, AContext, aInMsg, aOutMsg );
    System.Finalize( Json   );
    System.Finalize( Result );
    ResultNull := TRUE;
    ResultOk   := FALSE;
    JsonOk     := RoutineContext.ReadInputString(   AStatus, TRemoveFunction.INPUT_FIELD_JSON,    Json,   JsonNull   );
    KeyOk      := RoutineContext.ReadInputString(   AStatus, TRemoveFunction.INPUT_FIELD_KEY,     Key,    KeyNull    );

    Result     := remove( Json, Key );
    ResultNull := ( Result = '' );

    ResultOk   := RoutineContext.WriteOutputString( AStatus, TRemoveFunction.OUTPUT_FIELD_RESULT, Result, ResultNull );
end;{ TRemoveFunction.execute }


{ TArrayToObjectFunction }

function TArrayToObjectFunctionFactory.newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction;
begin
    Result := TArrayToObjectFunction.create( AMetadata );
end;{ TArrayToObjectFunctionFactory.newItem }

procedure TArrayToObjectFunction.execute( AStatus:IStatus; AContext:IExternalContext; aInMsg:POINTER; aOutMsg:POINTER );
var
    Json,     KeyName, ValueName, Result     : UnicodeString;
    JsonNull, KeyNull, ValueNull, ResultNull : WORDBOOL;
    JsonOk,   KeyOk,   ValueOk,   ResultOk   : BOOLEAN;
begin
    inherited execute( AStatus, AContext, aInMsg, aOutMsg );
    System.Finalize( Json   );
    System.Finalize( Result );
    ResultNull := TRUE;
    ResultOk   := FALSE;
    JsonOk     := RoutineContext.ReadInputString( AStatus, TArrayToObjectFunction.INPUT_FIELD_JSON,       Json,      JsonNull  );
    KeyOk      := RoutineContext.ReadInputString( AStatus, TArrayToObjectFunction.INPUT_FIELD_KEY_NAME,   KeyName,   KeyNull   );
    ValueOk    := RoutineContext.ReadInputString( AStatus, TArrayToObjectFunction.INPUT_FIELD_VALUE_NAME, ValueName, ValueNull );

    Result     := array_to_object( Json, KeyName, ValueName );
    ResultNull := ( Result = '' );

    ResultOk   := RoutineContext.WriteOutputString( AStatus, TArrayToObjectFunction.OUTPUT_FIELD_RESULT, Result, ResultNull );
end;{ TArrayToObjectFunction.execute }


{ TObjectToArrayFunction }

function TObjectToArrayFunctionFactory.newItem( AStatus:IStatus; AContext:IExternalContext; AMetadata:IRoutineMetadata ):IExternalFunction;
begin
    Result := TObjectToArrayFunction.create( AMetadata );
end;{ TObjectToArrayFunctionFactory.newItem }

procedure TObjectToArrayFunction.execute( AStatus:IStatus; AContext:IExternalContext; aInMsg:POINTER; aOutMsg:POINTER );
var
    Json,     KeyName, ValueName, Result     : UnicodeString;
    JsonNull, KeyNull, ValueNull, ResultNull : WORDBOOL;
    JsonOk,   KeyOk,   ValueOk,   ResultOk   : BOOLEAN;
begin
    inherited execute( AStatus, AContext, aInMsg, aOutMsg );
    System.Finalize( Json   );
    System.Finalize( Result );
    ResultNull := TRUE;
    ResultOk   := FALSE;
    JsonOk     := RoutineContext.ReadInputString( AStatus, TObjectToArrayFunction.INPUT_FIELD_JSON,       Json,      JsonNull  );
    KeyOk      := RoutineContext.ReadInputString( AStatus, TObjectToArrayFunction.INPUT_FIELD_KEY_NAME,   KeyName,   KeyNull   );
    ValueOk    := RoutineContext.ReadInputString( AStatus, TObjectToArrayFunction.INPUT_FIELD_VALUE_NAME, ValueName, ValueNull );

    Result     := object_to_array( Json, KeyName, ValueName );
    ResultNull := ( Result = '' );

    ResultOk   := RoutineContext.WriteOutputString( AStatus, TObjectToArrayFunction.OUTPUT_FIELD_RESULT, Result, ResultNull );
end;{ TObjectToArrayFunction.execute }


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
