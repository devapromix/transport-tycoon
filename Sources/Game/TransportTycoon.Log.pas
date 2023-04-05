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
    procedure Add(const AMessage: string); overload;
    procedure Add(const AMessage, AValue: string); overload;
  end;

var
  Log: TLog;

implementation

{ TLog }

procedure TLog.Add(const AMessage: string);
begin
  FLog.Append(Trim(AMessage));
end;

procedure TLog.Add(const AMessage, AValue: string);
begin
  Add(AMessage + ': ' + AValue);
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
