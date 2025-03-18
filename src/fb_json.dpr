(*
    Unit     : fb_json
    Date     : 2025-03-10
    Compiler : Delphi 12
    Author   : Shalamyansky Mikhail Arkadievich
    Contents : Firebird UDR JSON support procedure plugin module
    Project  : https://github.com/shalamyansky/fb_json
    Company  : BWR
*)

{$DEFINE NO_FBCLIENT}
(*
Define NO_FBCLIENT in your .dproj file to take effect on firebird.pas
*)

library fb_json;

uses
  {$IFDEF FastMM}
    {$DEFINE ClearLogFileOnStartup}
    {$DEFINE EnableMemoryLeakReporting}
    FastMM5,
  {$ENDIF}
  fbjson_register
;

{$R *.res}

exports
    firebird_udr_plugin
;

begin
end.
