﻿unit TransportTycoon.Company;

interface

type
  TCompany = class(TObject)
  private
    FName: string;
    FInavgurated: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    property Name: string read FName;
    property Inavgurated: Integer read FInavgurated;
    procedure Clear;
  end;

implementation

uses
  Math,
  TransportTycoon.City,
  TransportTycoon.Game;

procedure TCompany.Clear;
begin
  FName := Game.Map.City[Math.RandomRange(0, Length(Game.Map.City))].Name +
    ' TRANSPORT';
  FInavgurated := Game.Calendar.Year;
end;

constructor TCompany.Create;
begin

end;

destructor TCompany.Destroy;
begin

  inherited;
end;

end.
