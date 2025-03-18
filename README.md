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
		  , number      integer   -- order number of item started from 1
		  , key         string    -- pair key / null for others
		  , value       string    -- item (pair) value 
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
	    json  string  -- JSON to be enchanced
	  , key   string  -- new pair key 
	  , value string  -- new pair (item) value
	)returns  string; -- enchanced JSON 

	
Appends a new pair or item to the JSON string. The ***json*** must be an object or an array or null or empty. If null or empty new object or array is created depending on key presents.

Note! You can use this function to add multiple pairs with the same key. The JSON standard does not require the key to be unique.

## function put

	function put(
	    json  string  -- JSON object to be modified
	  , key   string  -- pair key 
	  , value string  -- new pair value
	)returns  string; -- modified JSON object

Updates JSON object pair or inserts new pair if not found. The ***json*** must be an object or null or empty. If null or empty new object is created. The ***key*** must not be null or empty.


## Limitations

This module provides simple JSON support without JPath. The solution may not be very convenient and fast but it is sufficient for most tasks.


## Installation

0. Download a release package.

1. Copy *fb_json.dll* to %firebird%\plugins\udr
   where %firebird% is Firebird (>=3.0) server root directory.
   Make sure library module matches the Firebird bitness.

2. Get script fb_json.sql. Modify the script if you need another parameters/returns string types.

3. Connect to target database and execute the script.


## Using

You can use binaries as you see fit.

If you get code or part of code please keep my name and a link [here](https://github.com/shalamyansky/fb_json).   

