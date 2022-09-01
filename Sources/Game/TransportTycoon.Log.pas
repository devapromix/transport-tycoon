unit TransportTycoon.Log;

interface

uses
  SysUtils,
  Classes;

type

  { TLog }

  TLog = class(TObject)
  private
    FLog: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(S: string); overload;
    procedure Add(S, V: string); overload;
  end;

var
  Log: TLog;

implementation

{ TLog }

procedure TLog.Add(S: string);
begin
  FLog.Append(Trim(S));
end;

procedure TLog.Add(S, V: string);
begin
  Add(S + ': ' + V);
end;

constructor TLog.Create;
begin
  FLog := TStringList.Create;
end;

destructor TLog.Destroy;
begin
  with FLog do
    if (FLog.Count > 0) then
      SaveToFile('errors.txt');
  FreeAndNil(FLog);
  inherited;
end;

initialization

Log := TLog.Create;

finalization

FreeAndNil(Log);

end.
