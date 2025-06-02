# fb_json
Firebird UDR module to support JSON parsing and composing

## Basis

JSON support is based on bundled Delphi System.JSON library (since Delphi 10).

## Routines

Routines are assembled into package ***json***. Pseudotype ***string*** marks any of string type ***char***, ***varchar*** or ***blob sub_type text***. All the routines can accept and return any string type.

## procedure *parse*

        procedure parse(
            json        string    -- JSON to be parsed
        )returns(
            source_type smallint  -- source JSON entity type 
          , number      integer   -- order number of item (pair) started from 1
          , key         string    -- pair key / null for others
          , value_      string    -- item (pair) value 
          , value_type  smallint  -- item (pair) value JSON entity type
        );

        JSON entity types are:
         0 - not a JSON entity
         1 - null
         2 - bool
         3 - number
         4 - string
         5 - pair
         6 - object
         7 - array

This selective procedure returns a set of pairs or items, depending on the source type (object or array). For simple sources (null, bool, number, string) it returns single record.

## function json_type

    function json_type(
        json_type smallint
    )returns      varchar(6);

Auxiliary PSQL function for viewing a string description of a type.

## function encode

    function encode(
        str  string
    )returns string;
  
Converts string into JSON string. I.e. quoted it, escapes inner quotas etc.

## function decode

    function decode(
        str  string
    )returns string;
  
Converts JSON string into common string. I.e. unquoted it and clear inner escapes.

## function append

    function append(
        json   string   -- JSON to be enhanced
      , key    string   -- new pair key 
      , value_ string   -- new pair (item) value
      , type_  smallint -- value type
    )returns   string;  -- enhanced JSON 

    
Appends a new pair or item to the JSON string. The ***json*** must be an object or an array or null or empty. If null or empty new object or array is created depending on key presents.

If ***value*** is not conform ***type*** it is ignored.

Note! You can use this function to add multiple pairs with the same key. The JSON standard does not require the key to be unique.

## function put

    function put(
        json   string   -- JSON object to be modified
      , key    string   -- pair key 
      , value_ string   -- new pair value
      , type_  smallint -- value type
    )returns   string;  -- modified JSON object

Updates JSON object pair or inserts new pair if not found. The ***json*** must be an object or null or empty. If null or empty new object is created. The ***key*** must not be null or empty.

If ***type*** does not match ***value*** (e.g. ***type=0*** ) the pair is removed.

## function remove

    function remove(
        json   string   -- JSON object to be modified
      , key    string   -- pair key 
    )returns   string;  -- modified JSON object

Removes pair from JSON object if found.

## function array_to_object

    function array_to_object(
        json       string   -- JSON array to be converted
      , key_name   string   -- key field name 
      , value_name string   -- value field name
    )returns       string;  -- JSON object

This function accepts array like

	[
	    { "name": "propertyName1", "value": "propertyValue2" }
	  , { "name": "propertyName2", "value": "propertyValue2" }
	]
	  key_name = 'name', value_name = 'value'	

and converts it into object like  

	{
	    "propertyName1": "propertyValue2"
	  , "propertyName2": "propertyValue2"
	}

## function object_to_array

    function object_to_array(
        json       string   -- JSON array to be converted
      , key_name   string   -- key field name
      , value_name string   -- value field name
    )returns       string;  -- JSON object

Parses any JSON object onto array like

	[
	    { "name": "propertyName1", "value": "propertyValue2" }
	  , { "name": "propertyName2", "value": "propertyValue2" }
	]
	  key_name = 'name', value_name = 'value'	
.


## Limitations

This module provides simple JSON support without JPath. The solution may not be very convenient and fast but it is sufficient for most tasks.


## Installation

0. Download a release package.

1. Copy **fb_json.dll** to **%firebird%\plugins\udr**
   where **%firebird%** is Firebird (>=3.0) server root directory.
   Make sure library module matches the Firebird bitness.

2. Get script **fb_json.sql**. Modify the script if you need another parameters/returns string types.

3. Connect to target database and execute the script.


## Using

You can use binaries as you see fit.

If you get code or part of code please keep my name and a link [here](https://github.com/shalamyansky/fb_json).   


## Examples

**Parse JSON object:**

    select
          json.json_type( j.source_type ) as json_type
        , j.number
        , j.key
        , j.value_
        , json.json_type( j.value_type )  as value_type
      from
        json.parse( '
          {
              "null"   : null
            , "bool"   : true
            , "number" : 123
            , "string" : "123"
            , "object" : { "a" : "b" }
            , "array"  : [ 1, 2, 3 ]
          }
        ') j
    ;
    
    JSON_TYPE  NUMBER  KEY      VALUE_    VALUE_TYPE
    =========  ======  =======  =======   ==========
    object          1  null     null      null
    object          2  bool     true      bool
    object          3  number   123       number
    object          4  string   123       string
    object          5  object   {"a":"b"} object
    object          6  array    [1,2,3]   array
    
Note: strings returned dequoted (decoded).

**Parse JSON array:**

    select
          json.json_type( j.source_type ) as json_type
        , j.number
        , j.key
        , j.value_
        , json.json_type( j.value_type )  as value_type
      from
        json.parse( '
          [
              null
            , true
            , 123
            , "123"
            , { "a" : "b" }
            , [ 1, 2, 3 ]
          ]
        ') j
    ;
    
    JSON_TYPE  NUMBER  KEY      VALUE_    VALUE_TYPE
    =========  ======  =======  =======   ==========
    array           1  <null>   null      null
    array           2  <null>   true      bool
    array           3  <null>   123       number
    array           4  <null>   123       string
    array           5  <null>   {"a":"b"} object
    array           6  <null>   [1,2,3]   array

**Encode string for JSON:**

    select
        json.encode( '{ "a" : "b" }' )
      from
        rdb$database
    ;
    
    ENCODE
    ====================
    "{ \"a\" : \"b\" }"

**Decode JSON string:**

    select
        json.decode( '"{ \"a\" : \"b\" }"' )
      from
        rdb$database
    ;
    
    DECODE
    ====================
    { "a" : "b" }

**Append pairs to JSON object:**

    select
        json.append(
            null
          , 'a'
          , 'b'
          , 4
        )
      from
        rdb$database
    ;

    APPEND
    ==========
    {"a":"b"}

    select
        json.append(
            '{"a":"b"}'
          , 'x'
          , 'y'
          , 4
        )
      from
        rdb$database
    ;
    
    APPEND
    ==================
    {"a":"b","x":"y"}

**Set pair value in JSON object:**

    select
        json.put(
            '{"a":"b","x":"y"}'
          , 'x'
          , 'z'
          , 4
        )
      from
        rdb$database
    ;

    PUT
    ==================
    {"a":"b","x":"z"}

**Remove pair from JSON object:**

    select
        json.remove(
            '{"a":"b","x":"y"}'
          , 'x'
        )
      from
        rdb$database
    ;

    REMOVE
    ==========
    {"a":"b"}

**Convert name/value array into object:**

    select
        json.array_to_object(
            '[ {"name":"a","value":"x"}, {"name":"b","value":"y"} ]'
          , 'name'
          , 'value'
        )
      from
        rdb$database
    ;

    ARRAY_TO_OBJECT
    =================
    {"a":"x","b":"y"}

**Convert object into name/value array:**

    select
        json.object_to_array(
            '{"a":"x","b":"y"}'
          , 'name'
          , 'value'
        )
      from
        rdb$database
    ;

    OBJECT_TO_ARRAY
    ======================================================
    [ {"name":"a","value":"x"}, {"name":"b","value":"y"} ]
